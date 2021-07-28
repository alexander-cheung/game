PlayerThrowState = Class{__includes = BaseState}

function PlayerThrowState:init(player, dungeon)
	self.entity = player
	self.dungeon = dungeon
    self.timer = 0
	self.entity:changeAnimation("throw-"..self.entity.direction)
end

function PlayerThrowState:enter(object)
	-- object player is carrying
    object:fire(200, self.entity.direction, PLAYER_THROW_LENGTH)
	table.insert(self.dungeon.currentRoom.objects, object)
end

function PlayerThrowState:update(dt)
    self.timer = self.timer + dt
    if self.timer > 0.15 then -- throwing animation has played out
        self.entity:changeState("idle")
    end
end

function PlayerThrowState:render()
    -- certain animation
    local anim = self.entity.currentAnimation
    love.graphics.draw(gTextures[anim.texture], gFrames[anim.texture][anim:getCurrentFrame()],
        math.floor(self.entity.x - self.entity.offsetX), math.floor(self.entity.y - self.entity.offsetY))
end