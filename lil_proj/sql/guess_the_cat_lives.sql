CREATE OR REPLACE PROCEDURE guess_cat_lives IS
    -- Declare variables
    cat_lives INTEGER := 9;  -- The cat starts with 9 lives.
    user_guess INTEGER;
    attempts INTEGER := 0;
    max_attempts INTEGER := 3;
    message VARCHAR2(100);
BEGIN
    -- Display welcome message
    DBMS_OUTPUT.PUT_LINE('Welcome to the Guess the Cat''s Lives Game!');
    DBMS_OUTPUT.PUT_LINE('The cat starts with 9 lives.');
    DBMS_OUTPUT.PUT_LINE('You have ' || max_attempts || ' attempts to guess the correct number of lives.');

    -- Start game loop
    LOOP
        -- Prompt the user for a guess
        DBMS_OUTPUT.PUT_LINE('Guess how many lives the cat has left (between 1 and 9):');
        
        -- Read the user's guess (In real-world scenarios, this could be read from a UI or terminal input)
        -- For now, simulate the guess with a random number
        user_guess := ROUND(DBMS_RANDOM.VALUE(1, 9));  -- Generate a random number between 1 and 9

        -- Check the user's guess
        IF user_guess = cat_lives THEN
            DBMS_OUTPUT.PUT_LINE('Congratulations! You guessed correctly! The cat has ' || cat_lives || ' lives left.');
            EXIT;
        ELSIF attempts >= max_attempts THEN
            DBMS_OUTPUT.PUT_LINE('Game Over! You used up all your attempts. The correct number was ' || cat_lives || '.');
            EXIT;
        ELSE
            attempts := attempts + 1;
            message := 'Wrong guess! You have ' || (max_attempts - attempts) || ' attempts left.';
            DBMS_OUTPUT.PUT_LINE(message);
        END IF;
    END LOOP;
END guess_cat_lives;
/
