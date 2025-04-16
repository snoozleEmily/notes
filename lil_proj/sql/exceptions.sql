-- PLSQL
DECLARE
    -- Variables
    num1         NUMBER := 10;
    num2         NUMBER := 0;
    result       NUMBER;

    -- User-defined exception
    ex_custom_exception EXCEPTION;

BEGIN
    -- Example 1: ZERO_DIVIDE predefined exception
    BEGIN
        result := num1 / num2; -- This will raise ZERO_DIVIDE
    EXCEPTION
        WHEN ZERO_DIVIDE THEN
            DBMS_OUTPUT.PUT_LINE('Error: Division by zero is not allowed.');
    END;

    -- Example 2: NO_DATA_FOUND predefined exception
    BEGIN
        SELECT COUNT(*) 
        INTO result
        FROM employees
        WHERE employee_id = -9999; -- Invalid employee_id
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Error: No data found for the given query.');
    END;

    -- Example 3: TOO_MANY_ROWS predefined exception
    BEGIN
        SELECT department_id
        INTO result
        FROM employees; -- This query returns multiple rows and raises TOO_MANY_ROWS
    EXCEPTION
        WHEN TOO_MANY_ROWS THEN
            DBMS_OUTPUT.PUT_LINE('Error: Query returned more than one row.');
    END;

    -- Example 4: VALUE_ERROR predefined exception
    BEGIN
        result := TO_NUMBER('INVALID_NUMBER'); -- Raises VALUE_ERROR
    EXCEPTION
        WHEN VALUE_ERROR THEN
            DBMS_OUTPUT.PUT_LINE('Error: Invalid number format.');
    END;

    -- Example 5: CURSOR_ALREADY_OPEN predefined exception
    DECLARE
        cursor_test CURSOR IS SELECT * FROM employees;
    BEGIN
        OPEN cursor_test; -- First open
        OPEN cursor_test; -- Second open raises CURSOR_ALREADY_OPEN
    EXCEPTION
        WHEN CURSOR_ALREADY_OPEN THEN
            DBMS_OUTPUT.PUT_LINE('Error: Cursor is already open.');
    END;

    -- Example 6: User-defined exception
    BEGIN
        IF num1 > 5 THEN
            RAISE ex_custom_exception; -- Manually raise the exception
        END IF;
    EXCEPTION
        WHEN ex_custom_exception THEN
            DBMS_OUTPUT.PUT_LINE('Error: Custom exception triggered.');
    END;

    -- Example 7: DUP_VAL_ON_INDEX predefined exception
    BEGIN
        INSERT INTO employees (employee_id, first_name) VALUES (1, 'John'); -- Assuming employee_id 1 already exists
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            DBMS_OUTPUT.PUT_LINE('Error: Duplicate value on unique index.');
    END;

    -- Example 8: INVALID_CURSOR predefined exception
    DECLARE
        cursor_test2 CURSOR IS SELECT * FROM employees;
    BEGIN
        OPEN cursor_test2;
        CLOSE cursor_test2;
        CLOSE cursor_test2; -- Raises INVALID_CURSOR
    EXCEPTION
        WHEN INVALID_CURSOR THEN
            DBMS_OUTPUT.PUT_LINE('Error: Invalid cursor operation.');
    END;

    -- Example 9: PROGRAM_ERROR predefined exception
    BEGIN
        RAISE_APPLICATION_ERROR(-20000, 'Simulated program error.'); -- Simulate a program error
    EXCEPTION
        WHEN PROGRAM_ERROR THEN
            DBMS_OUTPUT.PUT_LINE('Error: A program error occurred.');
    END;

    -- Example 10: SUBSCRIPT_OUTSIDE_LIMIT predefined exception
    DECLARE
        TYPE num_array IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
        arr num_array;
    BEGIN
        arr(1) := 10;
        DBMS_OUTPUT.PUT_LINE(arr(2)); -- Raises SUBSCRIPT_OUTSIDE_LIMIT