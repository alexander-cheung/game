--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

GameObject = Class{}

function GameObject:init(def, x, y)
    -- string identifying this object type
    self.type = def.type

    self.texture = def.texture
    self.quad = def.quad
    self.frame = def.frame or 1

    -- whether it acts as an obstacle or not
    self.solid = def.solid
    -- can be projectile
    self.pickUp = def.pickUp or false
    
    self.defaultState = def.defaultState
    self.state = self.defaultState
    self.states = def.states

    -- dimensions
    self.x = x
    self.y = y
    self.width = def.width
    self.height = def.height

    -- offset image
    self.offsetX = def.offsetX or 0
    self.offsetY = def.offsetY or 0

    -- scale of image
    self.scaleX = def.scaleX or 1
    self.scaleY = def.scaleY or 1

    -- consumable object or not
    self.consumable = def.consumable

    -- default empty collision callback
    self.onCollide = function() end
    self.onConsume = function() end

    self.orientation = 0
    self.fired = false
    self.travel = 0
end

function GameObject:update(dt)
    if self.fired then
        local distance = self.velocity * dt
        -- amount of distance that projectile can travel that is left
        self.travel = self.travel - distance
        -- move pot in direction
        if self.direction == "left" then
            self.x = self.x - distance
        elseif self.direction == "right" then
            self.x = self.x + distance
        elseif self.direction == "up" then
            self.y = self.y - distance
        elseif self.direction == "down" then
            self.y = self.y + distance
        end

        Timer.tween(0.15, {
            [self] = {orientation = math.random(-7, 7)}
        })
    end
end

function GameObject:fire(velocity, direction, travel)
    self.fired = true
    self.velocity = velocity
    self.travel = travel
    self.direction = direction
end

function GameObject:collides(target)
    return not (self.x + self.width < target.x or self.x > target.x + target.width or
                self.y + self.height < target.y or self.y > target.y + target.height)
end

function GameObject:render(adjacentOffsetX, adjacentOffsetY)
    if self.fired then -- render from center and make random spin on projectile
        love.graphics.draw(gTextures[self.texture],
            gFrames[self.quad][self.state and self.states[self.state].frame or self.frame],
            self.x + self.width / 2 + adjacentOffsetX - self.offsetX, self.y + self.height / 2 + adjacentOffsetY - self.offsetY,
            self.orientation, self.scaleX, self.scaleY, self.width / 2, self.height / 2)
    else
        love.graphics.draw(gTextures[self.texture],
            gFrames[self.quad][self.state and self.states[self.state].frame or self.frame],
            self.x + adjacentOffsetX - self.offsetX, self.y + adjacentOffsetY - self.offsetY,
            0, self.scaleX, self.scaleY)
    end
end