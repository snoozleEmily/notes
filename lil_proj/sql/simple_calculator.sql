-- PLSQL
CREATE OR REPLACE FUNCTION power(base NUMBER, exponent NUMBER) RETURN NUMBER IS
  result NUMBER := 1;
BEGIN
    FOR i IN 1..exponent LOOP
        result := result * base; -- Multiply the base by itself
    END LOOP;
END;
/

CREATE OR REPLACE FUNCTION is_prime_check(p_number IN INTEGER) RETURN BOOLEAN IS
    i INTEGER;
BEGIN
    IF p_number < 2 THEN
        RETURN FALSE;
    END IF;
    FOR i IN 2..FLOOR(SQRT(p_number)) LOOP
        IF p_number MOD i = 0 THEN
            RETURN FALSE;
        END IF;
    END LOOP;
    RETURN TRUE;
END;
/

DECLARE
  first_number NUMBER := 10;
  second_number NUMBER := 3;
  third_number NUMBER := 25;
  result NUMBER;
BEGIN 
    -- Overflow Check
  IF (first_number > 68 OR second_number > 68 OR third_number > 68) THEN
    RAISE_APPLICATION_ERROR(-20001, 'The given numbers cannot be greater than 68.');
  ELSIF (first_number + second_number = 162) THEN
    RAISE_APPLICATION_ERROR(-20002, 'The sum of the first and second numbers cannot be 162.');
  END IF;
  
  -- Addition
  result := first_number + second_number;
  DBMS_OUTPUT.PUT_LINE('ADDITION: ' || result); 

  -- Subtraction
  result := first_number - second_number;
  DBMS_OUTPUT.PUT_LINE('SUBTRACTION: ' || result);

  -- Multiplication
  result := first_number * second_number;
  DBMS_OUTPUT.PUT_LINE('MULTIPLICATION: ' || result);
  
  -- Division
  result := ROUND(first_number / second_number, 2);
  DBMS_OUTPUT.PUT_LINE('DIVISION: ' || result);
  
  -- Remainder Of Division
  result := MOD(first_number, second_number);
  DBMS_OUTPUT.PUT_LINE('MODULUS: ' || result);
  
  -- Exponentiation (Power)
  result := power(first_number, second_number);
  DBMS_OUTPUT.PUT_LINE('POWER: ' || result);
  
  -- Rule of three 
  result := ROUND((first_number + second_number + third_number) / 3, 2);
  DBMS_OUTPUT.PUT_LINE('RULE OF THREE: ' || result);

  -- Square Root of First Number
  result := ROUND(SQRT(first_number), 2);
  DBMS_OUTPUT.PUT_LINE('SQUARE ROOT (First Number): ' || result);

  -- Natural Logarithm of Second Number
  result := ROUND(LOG(second_number), 2);
  DBMS_OUTPUT.PUT_LINE('NATURAL LOG (Second Number): ' || result);

  -- Base-10 Logarithm of Third Number
  result := ROUND(LOG(10, third_number), 2);
  DBMS_OUTPUT.PUT_LINE('BASE-10 LOG (Third Number): ' || result);

  -- Sum of Squares of All Numbers
  result := POWER(first_number, 2) + POWER(second_number, 2) + POWER(third_number, 2);
  DBMS_OUTPUT.PUT_LINE('SUM OF SQUARES: ' || result);

  -- Geometric Mean
  result := ROUND(EXP((LOG(first_number) + LOG(second_number) + LOG(third_number)) / 3), 2);
  DBMS_OUTPUT.PUT_LINE('GEOMETRIC MEAN: ' || result);

  -- Harmonic Mean
  result := ROUND(3 / (1 / first_number + 1 / second_number + 1 / third_number), 2);
  DBMS_OUTPUT.PUT_LINE('HARMONIC MEAN: ' || result);

END
/