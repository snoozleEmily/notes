-- To play this game, copy the code below and paste on:
-- https://www.tutorialspoint.com/execute_lua_online.php

function input(prompt)
    io.write(prompt .. ": ")
    return io.read()
end

-- Introduction
print("Welcome to the Interactive Story Game!")
print("You will provide words, and based on your choices, a unique and immersive story will be created.")
print("Choose your inputs wisely and embark on an adventure filled with mystery, excitement, and surprises!")
print("Your choices will shape the outcome, so let your imagination run wild.")
print("--------------------------------------------------")

-- Variables
local adjective = input("Write an adjective")
local tone = input("Choose the tone of the story (1) funny (2) dark (3) basic (4) adventure (5) sci-fi")
local name = input("Enter a name")
local pronoun = input("Choose a pronoun (he/she/they)")
local verb = input("Enter a verb")
local location = input("Enter a location")
local item = input("Enter an item")
local event = input("Enter a surprising event")
local companion = input("Enter a companion (e.g., friend, animal)")
local goal = input("Enter a goal (e.g., find treasure, defeat a monster)")

-- Dictionary of stories
local stories = {
    ["1"] = string.format(
        "Once upon a time, in a world filled with laughter and joy, there was a %s dragon named %s who loved to dance. " ..
        "One fateful day, in the bustling streets of %s, %s decided to %s with a magical %s that had the power to make everyone laugh uncontrollably. " ..
        "Suddenly, %s was joined by a mischievous %s who had a knack for pulling pranks. They embarked on an unexpected adventure to %s, " ..
        "where they encountered a kingdom ruled by jesters. But their journey took an even wilder turn when %s happened, causing mayhem across the land. " ..
        "With wit, humor, and a bit of luck, they would soon discover that laughter could be the key to solving the kingdom's greatest mystery.",
        adjective, name, location, pronoun, verb, item, pronoun, companion, goal, event
    ),

    ["2"] = string.format(
        "In the forgotten corners of %s, where shadows loomed and secrets whispered through the wind, a %s figure named %s emerged from the darkness. " ..
        "Legends spoke of a cursed %s, said to possess forbidden knowledge, hidden deep within the abyss of time. " ..
        "With a quiet resolve, %s would %s through the eerie ruins, uncovering cryptic messages that hinted at an ancient power. " ..
        "One fateful evening, under the pale moonlight, %s stumbled upon a forsaken path that led to a realm beyond mortal comprehension. " ..
        "There, a cloaked figure revealed a terrifying truth: %s. Now, the balance of the world rested in %s hands, and every decision could lead to salvation—or doom.",
        location, adjective, name, item, pronoun, verb, pronoun, event, pronoun
    ),

    ["3"] = string.format(
        "The %s cat named %s sat on the windowsill, observing the world with knowing eyes. " ..
        "Each night, as the stars began to twinkle, %s would %s in pursuit of the elusive %s, a mysterious artifact that appeared only at dusk. " ..
        "One fateful evening, a strange gust of wind carried whispers of an ancient legend. Following the clues, %s discovered a hidden passage beneath the city. " ..
        "With %s by %s side, they ventured into a forgotten world teeming with enchanted creatures and lost secrets. " ..
        "As they pressed on, their quest to %s became even more perilous when they faced an unexpected twist: %s. " ..
        "Through courage, determination, and unwavering trust, they would uncover a secret that would change their world forever.",
        adjective, name, pronoun, verb, item, pronoun, companion, pronoun, goal, event
    ),

    ["4"] = string.format(
        "Deep in the heart of %s, where towering trees touched the sky and rivers whispered forgotten tales, a %s explorer named %s set off on an epic quest. " ..
        "Guided by ancient scrolls and an unwavering spirit, %s and %s embarked on a perilous journey to retrieve the legendary %s, an artifact of immeasurable power. " ..
        "As they ventured deeper into uncharted lands, they encountered creatures from myth and lore, each holding a piece of the puzzle. " ..
        "But their adventure took a dangerous turn when %s transpired, threatening everything they held dear. " ..
        "Now, facing impossible odds, they had to unravel the mysteries of the past and prove their worth to achieve their ultimate goal: %s.",
        location, adjective, name, pronoun, companion, item, event, goal
    ),

    ["5"] = string.format(
        "In the distant reaches of the universe, far beyond the known stars, the cosmic city of %s stood as a beacon of advanced civilization. " ..
        "A brilliant yet eccentric inventor named %s, known for their %s ingenuity, had spent years designing a spacecraft unlike any other. " ..
        "With %s as their trusted co-pilot, they set off to %s, an unexplored sector rumored to contain the legendary %s. " ..
        "But as they ventured deeper into the cosmos, a sudden and catastrophic event occurred: %s. " ..
        "Now, with time running out and the fate of their mission in jeopardy, they had to navigate treacherous wormholes, decode alien messages, and outwit galactic adversaries. " ..
        "Would they unravel the mysteries of space and secure their place among the stars? Or would the secrets of the universe remain forever beyond their grasp?",
        location, name, adjective, companion, verb, item, event
    ),
}

local story = stories[tone] or "Invalid tone choice. Please restart and select a valid option."

print("\nHere is your story:")
print("--------------------------------------------------")
print(story)
