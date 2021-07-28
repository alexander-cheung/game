PlayerPickupState = Class{__includes = BaseState}

function PlayerPickupState:init(player, dungeon)
    self.entity = player
    self.dungeon = dungeon
    -- play lift animation
    self.entity:changeAnimation("lift-"..self.entity.direction)
end

function PlayerPickupState:enter(object)
    -- object player is carrying
    self.object = object
end

function PlayerPickupState:exit()
end

function PlayerPickupState:update(dt)
    -- tween object to above character, when finished transition to object idle state
    Timer.tween(0.15, {
        -- object x is centered
        [self.object] = {x = self.entity.x + self.entity.width / 2 - self.object.width / 2,
         y = self.entity.y - self.object.height + 8}
    }):finish(self.entity:changeState("carry-idle", self.object))
end

function PlayerPickupState:render()
    -- certain animation
    local anim = self.entity.currentAnimation
    love.graphics.draw(gTextures[anim.texture], gFrames[anim.texture][anim:getCurrentFrame()],
        math.floor(self.entity.x - self.entity.offsetX), math.floor(self.entity.y - self.entity.offsetY))

    self.object:render(0, 0)
end