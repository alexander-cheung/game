--[[
    GD50
    Match-3 Remake

    -- Tile Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    The individual tiles that make up our game board. Each Tile can have a
    color and a variety, with the varietes adding extra points to the matches.
]]

Tile = Class{}

function Tile:init(x, y, color, variety, isShiny)
    
    -- board positions
    self.gridX = x
    self.gridY = y

    -- coordinate positions
    self.x = (self.gridX - 1) * 32
    self.y = (self.gridY - 1) * 32

    -- tile appearance/points
    self.color = color
    self.variety = variety

    -- if tile is a shiny tile
    self.isShiny = isShiny
    -- make particle system for shiny tiles
    if self.isShiny then
        -- particles for if the block is shiny
        self.psystem = love.graphics.newParticleSystem(gTextures['particle'], 10)
        -- lasts between 1 - 2 seconds
        self.psystem:setParticleLifetime(1, 2)
        -- won't move anywhere
        self.psystem:setLinearAcceleration(0, 0, 0, 0)
        -- 10 pixels radius to spread
        self.psystem:setEmissionArea('normal', 5, 5)
        -- white particle, goes from dim to bright to dim
        self.psystem:setColors(
            1, 1, 1, 0,
            1, 1, 1, 1,
            1, 1, 1, 0
        )
        -- timer for particle effect
        self.timer = Timer.every(2, function()
            self.psystem:emit(10)
        end)
    end

    -- base point value of 50, adds 20 each time variety increases
    self.pointValue = 50 + (self.variety - 1) * 20
end

function Tile:update(dt)
    self.psystem:update(dt)
end

function Tile:render(x, y)
    -- draw shadow
    love.graphics.setColor(34 / 255, 32 / 255, 52 / 255)
    love.graphics.draw(gTextures['main'], gFrames['tiles'][self.color][self.variety],
        self.x + x + 2, self.y + y + 2)

    -- draw tile itself
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(gTextures['main'], gFrames['tiles'][self.color][self.variety],
        self.x + x, self.y + y)
end

function Tile:renderParticles()
        -- render particles on tile
        love.graphics.draw(self.psystem, self.x + 16 + (VIRTUAL_WIDTH - 272), self.y + 32)
end