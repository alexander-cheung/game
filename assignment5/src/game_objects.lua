--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

GAME_OBJECT_DEFS = {
    ['switch'] = {
        type = 'switch',
        texture = 'switches',
        quad = 'switches',
        frame = 2,
        width = 16,
        height = 16,
        solid = false,
        defaultState = 'unpressed',
        consumable = false,
        states = {
            ['unpressed'] = {
                frame = 2
            },
            ['pressed'] = {
                frame = 1
            }
        }
    },
    ["heart"] = {
        type = "heart",
        texture = "hearts",
        quad = "hearts",
        frame = 5,
        width = 4,
        height = 4,
        solid = false,
        scaleX = 0.25,
        scaleY = 0.25,
        consumable = true
    },

    ['pot'] = {
        type = "pot",
        texture = "tiles",
        quad = "pots",
        frame = math.random(1, 2),
        width = 12, -- slightly smaller
        height = 16,
        solid = true,
        offsetX = 3.09,
        pickUp = true
    }
}