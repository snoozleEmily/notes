#include <iostream>
#include <cstdlib>  // for rand() and srand()
#include <ctime>    // for time()

int rollDice() {
    return rand() % 6 + 1; // Generates a number between 1 and 6
}

int main() {
    // Seed the random number generator
    std::srand(static_cast<unsigned int>(std::time(0)));

    char playAgain;
    do {
        int result = rollDice();
        std::cout << "You rolled a: " << result << std::endl;

        std::cout << "Roll again? (y/n): ";
        std::cin >> playAgain;
    } while (playAgain == 'y' || playAgain == 'Y');

    std::cout << "Thanks for playing!" << std::endl;
    return 0;
}