PlayerObjectIdleState = Class{__includes = BaseState}

function PlayerObjectIdleState:init(player)
	self.entity = player
    self.entity:changeAnimation('object-idle-' .. self.entity.direction)	
end

function PlayerObjectIdleState:enter(object)
	-- object player is carrying
	self.object = object
end

function PlayerObjectIdleState:update(dt)
    if love.keyboard.isDown('left') or love.keyboard.isDown('right') or
       love.keyboard.isDown('up') or love.keyboard.isDown('down') then
        self.entity:changeState('carry-walk', self.object)
    end

    -- player tries to throw object it is holding
    if love.keyboard.wasPressed("enter") or love.keyboard.wasPressed("return") then
        self.entity:changeState("throw", self.object)
    end

end

function PlayerObjectIdleState:render()
    local anim = self.entity.currentAnimation
    love.graphics.draw(gTextures[anim.texture], gFrames[anim.texture][anim:getCurrentFrame()],
        math.floor(self.entity.x - self.entity.offsetX), math.floor(self.entity.y - self.entity.offsetY))
    
    self.object:render(0, 0)
end