-- PLSQL
-- 1. Main Tables
CREATE TABLE ACCOUNTS (
    id NUMBER PRIMARY KEY,
    us_name VARCHAR2(50) NOT NULL,
    us_email VARCHAR2(50) NOT NULL UNIQUE,
    us_password NUMBER
);

CREATE TABLE PASSWORD (
    us_account NUMBER PRIMARY KEY,
    us_password NUMBER NOT NULL,
    pr_breach NUMBER DEFAULT 0,
    ts_created TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ts_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fl_encrypted NUMBER(1) DEFAULT 1,
    FOREIGN KEY (us_account) REFERENCES ACCOUNTS(id)
);

-- 2. Breach History Tracking
CREATE TABLE BREACH_HISTORY (
    breach_id NUMBER GENERATED ALWAYS AS IDENTITY,
    us_account NUMBER NOT NULL,
    breach_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    breach_type VARCHAR2(50),
    FOREIGN KEY (us_account) REFERENCES ACCOUNTS(id)
);

-- 3. Views for Reporting
CREATE OR REPLACE VIEW CURRENT_BREACH_STATUS AS
SELECT 
    a.id AS account_id,
    a.us_name,
    a.us_email,
    p.pr_breach AS breach_count,
    (
        SELECT MAX(breach_date) 
        FROM BREACH_HISTORY 
        WHERE us_account = a.id
        ) AS last_breach_date,
    p.fl_encrypted
FROM ACCOUNTS a
JOIN PASSWORD p ON a.id = p.us_account;

CREATE OR REPLACE VIEW BREACH_TIMELINE AS
SELECT 
    a.us_name,
    a.us_email,
    bh.breach_date,
    bh.breach_type,
    ROW_NUMBER() OVER (
        PARTITION BY bh.us_account 
        ORDER BY bh.breach_date DESC
        ) AS breach_sequence
FROM BREACH_HISTORY bh
JOIN ACCOUNTS a ON bh.us_account = a.id;

-- 4. Triggers for Automatic Tracking
CREATE OR REPLACE TRIGGER TRG_PASSWORD_BREACH
AFTER UPDATE OF pr_breach ON PASSWORD
FOR EACH ROW
WHEN (NEW.pr_breach > OLD.pr_breach)
BEGIN
    -- Record each new breach in history
    INSERT INTO BREACH_HISTORY (us_account, breach_type)
    VALUES (:NEW.us_account, 'Password compromise');
    
    -- Update the breach count
    :NEW.ts_updated := CURRENT_TIMESTAMP;
END;
/

-- 5. Validator Function
CREATE OR REPLACE FUNCTION VALIDATOR RETURN BOOLEAN AS
    v_breach_count NUMBER;
BEGIN
    -- Check for password reuse (simple breach detection)
    FOR rec IN (
        SELECT us_account, us_password
        FROM PASSWORD
        WHERE us_password IN (
            SELECT us_password 
            FROM PASSWORD 
            GROUP BY us_password 
            HAVING COUNT(*) > 1
        )
    ) LOOP
        UPDATE PASSWORD
        SET pr_breach = pr_breach + 1
        WHERE us_account = rec.us_account;
        
        v_breach_count := v_breach_count + 1;
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('Validator processed ' || v_breach_count || ' potential breaches');
    RETURN TRUE;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Validator error: ' || SQLERRM);
        RETURN FALSE;
END;
/

-- 6. Security Check Procedure
CREATE OR REPLACE PROCEDURE CHECK_SECURITY AS
    v_critical_count NUMBER := 0;
BEGIN
    -- Check for unencrypted passwords
    FOR rec IN (
        SELECT a.id, a.us_name
        FROM ACCOUNTS a
        JOIN PASSWORD p ON a.id = p.us_account
        WHERE p.fl_encrypted = 0
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('SECURITY ALERT: Account ' || rec.us_name || 
                           ' (ID: ' || rec.id || ') has unencrypted password!');
        v_critical_count := v_critical_count + 1;
    END LOOP;
    
    -- Check for breached accounts
    FOR rec IN (
        SELECT a.id, a.us_name, p.pr_breach
        FROM ACCOUNTS a
        JOIN PASSWORD p ON a.id = p.us_account
        WHERE p.pr_breach > 0
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('SECURITY WARNING: Account ' || rec.us_name || 
                           ' (ID: ' || rec.id || ') has ' || rec.pr_breach || ' breaches');
        v_critical_count := v_critical_count + rec.pr_breach;
    END LOOP;
    
    -- Summary report
    DBMS_OUTPUT.PUT_LINE('Security check complete. Found ' || v_critical_count || ' critical issues.');
    
    -- Optional: Auto-fix simple issues
    -- UPDATE PASSWORD SET fl_encrypted = 1 WHERE fl_encrypted = 0;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Security check failed: ' || SQLERRM);
END;
/

-- 7. Debugging View
CREATE OR REPLACE VIEW VIEW_ACCOUNT_DEBUG AS
SELECT 
    -- Core account info
    a.id AS account_id,
    a.us_name,
    a.us_email,
    
    -- Password status
    p.us_password AS current_password_hash,
    p.ol_password AS previous_password_hash,
    p.fl_encrypted,
    p.pr_breach AS breach_count,
    
    -- Timestamp analysis
    a.ts_created AS account_creation_date,
    p.ts_created AS password_creation_date,
    p.ts_updated AS password_last_updated,
    
    -- Breach analysis
    (
        SELECT MAX(breach_date) 
        FROM BREACH_HISTORY bh 
        WHERE bh.us_account = a.id
    ) AS last_breach_date,
    (
        SELECT COUNT(*) 
        FROM BREACH_HISTORY bh 
        WHERE bh.us_account = a.id
    ) AS total_breaches,
    
    -- Security health indicators
    CASE 
        WHEN p.fl_encrypted = 0 THEN 'UNENCRYPTED'
        WHEN p.ol_password IS NOT NULL THEN 'PASSWORD_REUSED'
        WHEN (SYSDATE - p.ts_created) > 90 THEN 'PASSWORD_EXPIRED'
        ELSE 'SECURE'
    END AS security_status,
    
    -- Debugging helpers
    (SYSDATE - p.ts_created) AS password_age_days,
    (
        SELECT COUNT(*) 
        FROM PASSWORD p2 
        WHERE p2.us_password = p.us_password
        ) AS password_reuse_count,
    
    -- Diagnostic metadata
    SYSTIMESTAMP AS debug_timestamp,
    SYS_CONTEXT('USERENV', 'SESSION_USER') AS queried_by,
    DBMS_UTILITY.FORMAT_ERROR_STACK AS last_error
    
FROM 
    ACCOUNTS a
    JOIN PASSWORD p ON a.id = p.us_account
    LEFT JOIN BREACH_HISTORY bh ON a.id = bh.us_account
WITH READ ONLY;

-- 8. Workflow
/*
-- Initialize test data
INSERT INTO ACCOUNTS VALUES (1, 'Fulano Brasil', 'fulano.bra@example.com', 123456);
INSERT INTO ACCOUNTS VALUES (2, 'Beltrano Argentina', 'beltrano.arg@example.com', 789012); 
INSERT INTO PASSWORD VALUES (1, 123456, 0, DEFAULT, DEFAULT, 1);
INSERT INTO PASSWORD VALUES (2, 789012, 0, DEFAULT, DEFAULT, 1);

-- Check security status
EXEC CHECK_SECURITY();

-- View breach history
SELECT * FROM BREACH_HISTORY;

-- View current status
SELECT * FROM CURRENT_BREACH_STATUS;

-- View timeline
SELECT * FROM BREACH_TIMELINE ORDER BY us_name, breach_date DESC;
*/


-- 9. Full Mapping of All Acronyms:
Prefix	      Meaning	          Example Columns
us_	          User	              us_name, us_email, us_account
fl_	          Flag	              fl_encrypted
pr_	          Property	          pr_breach
ts_	          Timestamp	          ts_created, ts_updated
ol_	          Old/Previous	      ol_password
bh_	          Breach History      bh.breach_id, bh.breach_date
a.	          Accounts alias      a.id, a.us_name
p.	          Password alias	  p.pr_breach, p.fl_encrypted
v_	          Variable	          v_breach_count