-- This library management system allows members to borrow and return books. 
-- It consists of three main tables: 
-- 1. Books: Stores information about each book, including its title, author, and availability status.
-- 2. Members: Contains details about library members, such as their names and join dates.
-- 3. BorrowRecords: Tracks borrowing activities, linking books to members with dates for when the books were borrowed and returned.

-- Usage (see the end of the code):
-- * To borrow a book, call the `BorrowBook` procedure with the desired book ID and member ID. 
--   If the book is available, a new record is created in `BorrowRecords`, and the book's status is updated to unavailable.
-- * To return a book, use the `ReturnBook` procedure with the book ID and member ID. 
--   This updates the return date in `BorrowRecords` and marks the book as available again.
-- * A trigger logs each borrowing event, providing feedback on which member borrowed which book.

--PLSQL
-- Table for storing book information
CREATE TABLE Books (
    book_id NUMBER PRIMARY KEY,
    title VARCHAR2(100),
    author VARCHAR2(100),
    is_available CHAR(1) DEFAULT 'Y' -- Y for Yes, N for No
);

-- Table for storing member information
CREATE TABLE Members (
    member_id NUMBER PRIMARY KEY,
    member_name VARCHAR2(100),
    join_date DATE
);

-- Table to record borrowing
CREATE TABLE BorrowRecords (
    borrow_id NUMBER PRIMARY KEY,
    book_id NUMBER,
    member_id NUMBER,
    borrow_date DATE,
    return_date DATE,
    FOREIGN KEY (book_id) REFERENCES Books(book_id),
    FOREIGN KEY (member_id) REFERENCES Members(member_id)
);

-- Create a sequence for generating unique borrow record IDs, for BorrowRecords
CREATE SEQUENCE BorrowRecords_seq START WITH 1 INCREMENT BY 1;

-- Adding data into the Members table
INSERT INTO Members (member_id, member_name, join_date) VALUES (1, 'Alice Hawking Vulcano', TO_DATE('2023-01-15', 'YYYY-MM-DD'));
INSERT INTO Members (member_id, member_name, join_date) VALUES (2, 'Bobby Lactea Ferentight', TO_DATE('2023-05-22', 'YYYY-MM-DD'));
INSERT INTO Members (member_id, member_name, join_date) VALUES (3, 'Clara Sodium Europa', TO_DATE('2023-07-10', 'YYYY-MM-DD'));
INSERT INTO Members (member_id, member_name, join_date) VALUES (4, 'David Helios Quasar', TO_DATE('2023-08-12', 'YYYY-MM-DD'));
INSERT INTO Members (member_id, member_name, join_date) VALUES (5, 'Evelyn Mars Nova', TO_DATE('2023-09-01', 'YYYY-MM-DD'));
INSERT INTO Members (member_id, member_name, join_date) VALUES (6, 'Frankie Pluto Meteor', TO_DATE('2023-09-15', 'YYYY-MM-DD'));
INSERT INTO Members (member_id, member_name, join_date) VALUES (7, 'Georgia Titan Oxygen', TO_DATE('2023-09-20', 'YYYY-MM-DD'));
INSERT INTO Members (member_id, member_name, join_date) VALUES (8, 'Henry Electrum Pulsar', TO_DATE('2023-09-25', 'YYYY-MM-DD'));
INSERT INTO Members (member_id, member_name, join_date) VALUES (9, 'Isla Cosmos Wave', TO_DATE('2023-10-01', 'YYYY-MM-DD'));
INSERT INTO Members (member_id, member_name, join_date) VALUES (10, 'Jack Hydrogen Aurora', TO_DATE('2023-10-05', 'YYYY-MM-DD'));
INSERT INTO Members (member_id, member_name, join_date) VALUES (11, 'Kira Nebula Spectrum', TO_DATE('2023-10-10', 'YYYY-MM-DD'));
INSERT INTO Members (member_id, member_name, join_date) VALUES (12, 'Leo Mercury Cascade', TO_DATE('2023-10-12', 'YYYY-MM-DD'));
INSERT INTO Members (member_id, member_name, join_date) VALUES (13, 'Maya Lithium Tectonic', TO_DATE('2023-10-15', 'YYYY-MM-DD'));
INSERT INTO Members (member_id, member_name, join_date) VALUES (14, 'Nina Comet Fission', TO_DATE('2023-10-20', 'YYYY-MM-DD'));
INSERT INTO Members (member_id, member_name, join_date) VALUES (15, 'Oliver Geode Rift', TO_DATE('2023-10-22', 'YYYY-MM-DD'));
INSERT INTO Members (member_id, member_name, join_date) VALUES (16, 'Paula Nebulon Tide', TO_DATE('2023-10-25', 'YYYY-MM-DD'));
INSERT INTO Members (member_id, member_name, join_date) VALUES (17, 'Quinn Helium Mirage', TO_DATE('2023-10-30', 'YYYY-MM-DD'));
INSERT INTO Members (member_id, member_name, join_date) VALUES (18, 'Riley Pyxis Gravity', TO_DATE('2023-11-02', 'YYYY-MM-DD'));
INSERT INTO Members (member_id, member_name, join_date) VALUES (19, 'Sophie Pulsar Quake', TO_DATE('2023-11-05', 'YYYY-MM-DD'));
INSERT INTO Members (member_id, member_name, join_date) VALUES (20, 'Tyler Vortex Abyss', TO_DATE('2023-11-10', 'YYYY-MM-DD'));

-- Adding data into the Books table
INSERT INTO Books (book_id, title, author) VALUES (1, 'The Republic', 'Plato');
INSERT INTO Books (book_id, title, author) VALUES (2, 'Meditations', 'Marcus Aurelius');
INSERT INTO Books (book_id, title, author) VALUES (3, 'Nicomachean Ethics', 'Aristotle');
INSERT INTO Books (book_id, title, author) VALUES (4, 'Beyond Good and Evil', 'Friedrich Nietzsche');
INSERT INTO Books (book_id, title, author) VALUES (5, 'Critique of Pure Reason', 'Immanuel Kant');
INSERT INTO Books (book_id, title, author) VALUES (6, 'The Prince', 'Niccolò Machiavelli');
INSERT INTO Books (book_id, title, author) VALUES (7, 'Being and Time', 'Martin Heidegger');
INSERT INTO Books (book_id, title, author) VALUES (8, 'The Tao Te Ching', 'Laozi');
INSERT INTO Books (book_id, title, author) VALUES (9, 'The Structure of Scientific Revolutions', 'Thomas Kuhn');
INSERT INTO Books (book_id, title, author) VALUES (10, 'The Myth of Sisyphus', 'Albert Camus');
INSERT INTO Books (book_id, title, author) VALUES (11, 'Phenomenology of Spirit', 'Georg Wilhelm Friedrich Hegel');
INSERT INTO Books (book_id, title, author) VALUES (12, 'The Social Contract', 'Jean-Jacques Rousseau');


-- Stored Procedures

-- Borrowing Books
CREATE OR REPLACE PROCEDURE BorrowBook (
    p_book_id IN NUMBER,
    p_member_id IN NUMBER
) IS
    v_is_available CHAR(1);
BEGIN
    -- Check if the book is available
    SELECT is_available INTO v_is_available FROM Books WHERE book_id = p_book_id;
    
    IF v_is_available = 'Y' THEN
        -- Insert record into BorrowRecords
        INSERT INTO BorrowRecords (borrow_id, book_id, member_id, borrow_date)
        VALUES (BorrowRecords_seq.NEXTVAL, p_book_id, p_member_id, SYSDATE);
        
        -- Mark the book as unavailable
        UPDATE Books SET is_available = 'N' WHERE book_id = p_book_id;
        
        DBMS_OUTPUT.PUT_LINE('Book borrowed successfully.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Book is not available.');
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Book not found.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
END;
/

-- Return Books
CREATE OR REPLACE PROCEDURE ReturnBook (
    p_book_id IN NUMBER,
    p_member_id IN NUMBER
) IS
BEGIN
    -- Update the return date in BorrowRecords
    UPDATE BorrowRecords
    SET return_date = SYSDATE
    WHERE book_id = p_book_id AND member_id = p_member_id AND return_date IS NULL;
    
    -- Mark the book as available
    UPDATE Books SET is_available = 'Y' WHERE book_id = p_book_id;
    
    DBMS_OUTPUT.PUT_LINE('Book returned successfully.');
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Borrow record not found.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
END;
/

-- Logs Trigger
CREATE OR REPLACE TRIGGER LogBorrowEvent
AFTER INSERT ON BorrowRecords
FOR EACH ROW
DECLARE
    v_member_name VARCHAR2(100);
BEGIN
    -- Get the member name
    SELECT member_name INTO v_member_name
    FROM Members
    WHERE member_id = :NEW.member_id;

    DBMS_OUTPUT.PUT_LINE('The member ' || v_member_name || ' borrowed the book of ID ' || :NEW.book_id || ' on ' || :NEW.borrow_date);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Member not found for the ID ' || :NEW.member_id);
    
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
END;
/


-- Usage Of System

-- Visualise Main Tables (commented out for testing)
--SELECT * FROM Members;
--SELECT * FROM Books;

-- Borrowing Books (example usage)
BEGIN
    BorrowBook(1, 1); -- Alice borrows 'The Republic'
    BorrowBook(2, 2); -- Bobby borrows 'Meditations'
    BorrowBook(3, 3); -- Clara borrows 'Nicomachean Ethics'
END;
/

-- Returning books (example usage)
BEGIN
    ReturnBook(2, 2); -- Bobby returns 'Meditations'
END;
/