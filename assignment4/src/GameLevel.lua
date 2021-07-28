--[[
    GD50
    Super Mario Bros. Remake

    -- GameLevel Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

GameLevel = Class{}

function GameLevel:init(entities, objects, tilemap, lockindex)
    self.entities = entities
    self.objects = objects
    self.tileMap = tilemap
    -- generated when lock brick is broken
    self.flag = false
    self.flagColor = nil
    -- fuuck this i dont care anymore
    self.doesthelockthingneedtounexist = false
    self.lockindex = lockindex
end

--[[
    Remove all nil references from tables in case they've set themselves to nil.
]]
function GameLevel:clear()
    for i = #self.objects, 1, -1 do
        if not self.objects[i] then
            table.remove(self.objects, i)
        end
    end

    for i = #self.entities, 1, -1 do
        if not self.objects[i] then
            table.remove(self.objects, i)
        end
    end
end

function GameLevel:update(dt)
    self.tileMap:update(dt)

    for k, object in pairs(self.objects) do
        object:update(dt)
    end

    for k, entity in pairs(self.entities) do
        entity:update(dt)
    end

    if self.doesthelockthingneedtounexist then
        self.doesthelockthingneedtounexist = false
        table.remove(self.objects, self.lockindex)
        self:clear()
    end
end

function GameLevel:render()
    self.tileMap:render()

    for k, object in pairs(self.objects) do
        object:render()
    end

    for k, entity in pairs(self.entities) do
        entity:render()
    end

    if self.flag then
        love.graphics.draw(gTextures['flags'], gFrames['flags'][self.flagColor], self.tileMap.width * TILE_SIZE - 10, 60, 0, -1)
    end
end