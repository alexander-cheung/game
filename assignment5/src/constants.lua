--[[
    GD50
    Legend of Zelda

    -- constants --

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

VIRTUAL_WIDTH = 384
VIRTUAL_HEIGHT = 216

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

TILE_SIZE = 16

--
-- entity constants
--
PLAYER_WALK_SPEED = 60

--
-- map constants
--
MAP_WIDTH = VIRTUAL_WIDTH / TILE_SIZE - 2
MAP_HEIGHT = math.floor(VIRTUAL_HEIGHT / TILE_SIZE) - 2

MAP_RENDER_OFFSET_X = (VIRTUAL_WIDTH - (MAP_WIDTH * TILE_SIZE)) / 2
MAP_RENDER_OFFSET_Y = (VIRTUAL_HEIGHT - (MAP_HEIGHT * TILE_SIZE)) / 2

--
-- tile IDs
--
TILE_TOP_LEFT_CORNER = 4
TILE_TOP_RIGHT_CORNER = 5
TILE_BOTTOM_LEFT_CORNER = 23
TILE_BOTTOM_RIGHT_CORNER = 24

TILE_EMPTY = 19

TILE_FLOORS = {
    7, 8, 9, 10, 11, 12, 13,
    26, 27, 28, 29, 30, 31, 32,
    45, 46, 47, 48, 49, 50, 51,
    64, 65, 66, 67, 68, 69, 70,
    88, 89, 107, 108
}

TILE_TOP_WALLS = {58, 59, 60}
TILE_BOTTOM_WALLS = {79, 80, 81}
TILE_LEFT_WALLS = {77, 96, 115}
TILE_RIGHT_WALLS = {78, 97, 116}

OMIT = {
    {x = 10, y = 1},    
    {x = 11, y = 1},    
    {x = 10, y = 9},    
    {x = 11, y = 9},    
    {x = 1, y = 4},    
    {x = 1, y = 5},    
    {x = 20, y = 4},    
    {x = 20, y = 5},
    {x = 10, y = 5},
    {x = 11, y = 5},
    {x = 10, y = 6},
    {x = 11, y = 6}
}

PLAYER_THROW_LENGTH = 64

LEFT_WALL = MAP_RENDER_OFFSET_X + TILE_SIZE
RIGHT_WALL = VIRTUAL_WIDTH - TILE_SIZE * 2
TOP_WALL = MAP_RENDER_OFFSET_Y - 4 -- for player point of view
BOTTOM_WALL = VIRTUAL_HEIGHT - (VIRTUAL_HEIGHT - MAP_HEIGHT * TILE_SIZE) + MAP_RENDER_OFFSET_Y - TILE_SIZE