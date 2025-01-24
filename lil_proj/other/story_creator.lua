-- Get user input
function input(prompt)
    io.write(prompt .. ": ")
    return io.read()
end

-- Variables
local adjective = input("Write an adjective")
local tone = input("Choose tone of the story (1) funny (2) dark (3) basic")
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
        "Once upon a time, there was a %s dragon named %s who loved to dance. " ..
        "One day, in %s, %s decided to %s with a magical %s that made everyone laugh. " ..
        "Suddenly, %s was joined by a playful %s who suggested they embark on an adventure to %s. " ..
        "Along the way, they encountered the unexpected: %s, leading to hilarious antics that filled the land with joy.",
        adjective, name, location, pronoun, verb, item, pronoun, companion, goal, event
    ),

    ["2"] = string.format(
        "In a desolate land, a %s shadow named %s haunted the night. " ..
        "With a chilling whisper, %s would %s through the eerie forest, searching for the lost %s that held the secrets of the dark. " ..
        "One fateful evening, %s stumbled upon a forbidden path that led to a hidden realm. " ..
        "There, a mysterious figure revealed a terrifying truth: %s. " ..
        "This revelation would forever change the fate of the land.",
        adjective, name, pronoun, verb, item, pronoun, event
    ),

    ["3"] = string.format(
        "The %s cat named %s sat on the windowsill, watching the world go by. " ..
        "Every evening, %s would %s to find a mysterious %s that appeared only at dusk. " ..
        "One night, %s discovered a secret passage leading to a magical world. " ..
        "With %s by %s side, they set out to %s. " ..
        "But little did they know, they would soon face a challenge: %s. " ..
        "Together, they would learn the true meaning of courage and friendship.",
        adjective, name, pronoun, verb, item, pronoun, companion, pronoun, goal, event
    ),
}

local story = stories[tone] or "Invalid tone choice."

print(story)
