--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

Player = Class{__includes = Entity}

function Player:init(def)
    Entity.init(self, def)
end

function Player:update(dt)
    Entity.update(self, dt)
end

function Player:collides(target)
    local selfY, selfHeight = self.y + self.height / 2, self.height - self.height / 2
    
    return not (self.x + self.width < target.x or self.x > target.x + target.width or
                selfY + selfHeight < target.y or selfY > target.y + target.height)
end

function Player:render()
    Entity.render(self)
    -- love.graphics.setColor(1, 0, 1)
    -- love.graphics.rectangle('line', self.x, self.y, self.width, self.height)
    -- love.graphics.setColor(1, 1, 1)
end

function Player.CheckObjectPickup(self, objects)
    -- figure out what object they want to pick up
    for k, object in pairs(objects) do
        if object.pickUp then
            if self.direction == "left" then
                -- difference between obj and player distance is close
                if math.abs(self.x - (object.x + object.width)) < 3 and 
                    math.abs(self.y - object.y) < 18 then
                        table.remove(objects, k)
                        gSounds["pickup"]:play()
                        self:changeState("pickup", object)
                        return
                end
            elseif self.direction == "right" then
                if math.abs(self.x + self.width - object.x) < 3 and 
                    math.abs(self.y - object.y) < 18 then
                        table.remove(objects, k)
                        gSounds["pickup"]:play()                        
                        self:changeState("pickup", object)
                        return                        
                end
            elseif self.direction == "up" then
                if math.abs((self.y + 9) - (object.y + object.height)) < 3 and 
                    math.abs(self.x - object.x) < 8 then
                        table.remove(objects, k)
                        gSounds["pickup"]:play()
                        self:changeState("pickup", object)
                        return                        
                end
            elseif self.direction == "down" then
                if math.abs(self.y + self.height - (object.y)) < 3 and 
                    math.abs(self.x - object.x) < 8 then
                        table.remove(objects, k)
                        gSounds["pickup"]:play()
                        self:changeState("pickup", object)
                        return                        
                end
            end
        end
    end
end