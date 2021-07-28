-- a powerup that the paddle can hit in order to gain some special effect

Powerup = Class{}

function Powerup:init(kind)
	self.type = kind and kind or 7 -- default is ball powerup
	-- width and height of a powerup
	self.width = 16
	self.height = 16
	self.x = math.random(0, VIRTUAL_WIDTH - self.width) -- a random x to spawn the powerup
	self.y = 16
	self.dy = 100
	self.inScreen = true
end

function Powerup:update(dt)
	self.y = self.y + self.dy * dt -- update position of powerup
	-- if powerup is under the bottom of the screen despawn it
	if self.y >= VIRTUAL_HEIGHT then
		self.inScreen = false
	end
end

function Powerup:collides(target)
	-- regular box collision, target should be the paddle
	if self.x <= target.x + target.width and self.x + self.width >= target.x
	and self.y <= target.y + target.height and self.y + self.height >= target.y then
		self.inScreen = false
		return true
	end
	return false
end

function Powerup:special(PlayState)
	-- if powerup is extra balls add 2 balls at end of table
	if self.type == 7 then
		-- i should be the end of the table array
		for i = #PlayState + 1, #PlayState + 2 do
			table.insert(PlayState.balls, i, Ball(math.random(7)))
			PlayState.balls[i].dx = math.random(-200, 200)
    		PlayState.balls[i].dy = math.random(-50, -60)
    	end
    -- if powerup is key allow locked bricks to break
    elseif self.type == 10 then
		PlayState.breakLock = true
	end
end

function Powerup:render()
	-- only render the powerup while in screen
	if self.inScreen then
		love.graphics.draw(gTextures["main"], gFrames["powerups"][self.type], self.x, self.y)
	end
end