CREATE ANALYST_DATA (
    analyst_id INT PRIMARY KEY,
    analyst_name VARCHAR(50),
    analyst_email VARCHAR(50),
    analyst_phone VARCHAR(50),
    analyst_address VARCHAR(50),
    analyst_city VARCHAR(50),
    analyst_state VARCHAR(50),
    analyst_zip VARCHAR(50),
    analyst_country VARCHAR(50),
    analyst_notes TEXT
)

CREATE ANALYST_HISTORY(
    analyst_id INT FOREIGN KEY,
    analyst_name VARCHAR(50),
    analyst_tickets INT,
    analyst_mistakes INT,
    analyst_notes TEXT,
    employee_of_the_month BOOLEAN,
    employee_status BOOLEAN,
    history TEXT
)