--[[
    GD50
    Breakout Remake

    -- PlayState Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Represents the state of the game in which we are actively playing;
    player should control the paddle, with the ball actively bouncing between
    the bricks, walls, and the paddle. If the ball goes below the paddle, then
    the player should lose one point of health and be taken either to the Game
    Over screen if at 0 health or the Serve screen otherwise.
]]

PlayState = Class{__includes = BaseState}

local next = next
--[[
    We initialize what's in our PlayState via a state table that we pass between
    states as we go from playing to serving.
]]
function PlayState:enter(params)
    self.paddle = params.paddle
    self.bricks = params.bricks
    self.health = params.health
    self.score = params.score
    self.highScores = params.highScores
    self.balls = params.balls
    self.level = params.level

    self.recoverPoints = params.recoverPoints and params.recoverPoints or 5000

    self.powerups = {}
    self.timer = 0
    self.timerMax = 30 -- every 30 seconds give a powerup
    self.pointsGained = 0
    self.pointsThreshold = 5000 -- every 5000 points give a powerup
    self.tillGrowPaddle = 10000 -- every 10000 points grow paddle
    self.breakLock = params.breakLock -- if locked bricks can be broken
    self.nextKeyPowerup = not self.breakLock and math.random(5, 8) or nil -- give a key powerup after x ball powerups
    -- give ball random starting velocity (there should only be one ball after servestate)
    self.balls[1].dx = math.random(-200, 200)
    self.balls[1].dy = math.random(-50, -60)
end

function PlayState:update(dt)
    if self.paused then
        if love.keyboard.wasPressed('space') then
            self.paused = false
            gSounds['pause']:play()
        else
            return
        end
    elseif love.keyboard.wasPressed('space') then
        self.paused = true
        gSounds['pause']:play()
        return
    end

    -- add time passed to timer
    self.timer = self.timer + dt

    -- update positions based on velocity
    self.paddle:update(dt)

    -- for each ball, update position and detect collison with bricks or paddle 
    -- go through the table backwards to prevent skipping an index if we delete a ball
    for i = #self.balls, 1, -1 do
        self.balls[i]:update(dt)
    
        if self.balls[i]:collides(self.paddle) then
            -- raise ball above paddle in case it goes below it, then reverse dy
            self.balls[i].y = self.paddle.y - 8
            self.balls[i].dy = -self.balls[i].dy

            --
            -- tweak angle of bounce based on where it hits the paddle
            --

            -- if we hit the paddle on its left side while moving left...
            if self.balls[i].x < self.paddle.x + (self.paddle.width / 2) and self.paddle.dx < 0 then
                self.balls[i].dx = -50 + -(8 * (self.paddle.x + self.paddle.width / 2 - self.balls[i].x))
            
            -- else if we hit the paddle on its right side while moving right...
            elseif self.balls[i].x > self.paddle.x + (self.paddle.width / 2) and self.paddle.dx > 0 then
                self.balls[i].dx = 50 + (8 * math.abs(self.paddle.x + self.paddle.width / 2 - self.balls[i].x))
            end

            gSounds['paddle-hit']:play()
        end

        -- detect collision across all bricks with the ball
        for k, brick in pairs(self.bricks) do
            -- only check collision if we're in play
            if brick.inPlay and self.balls[i]:collides(brick) then
                -- only add to score/check for victory if unlocked bricks
                if not brick.isLockBrick or self.breakLock then
                    -- add to score
                    local MorePoints = brick.tier * 200 + brick.color * 25
                    self.score = self.score + MorePoints
                    self.pointsGained = self.pointsGained + MorePoints
                    self.tillGrowPaddle = self.tillGrowPaddle - MorePoints
                    -- trigger the brick's hit function, which removes it from play
                    brick:hit()

                    -- go to our victory screen if there are no more bricks left
                    if self:checkVictory() then
                        gSounds['victory']:play()

                        gStateMachine:change('victory', {
                            level = self.level,
                            paddle = self.paddle,
                            health = self.health,
                            score = self.score,
                            highScores = self.highScores,
                            balls = self.balls,
                            recoverPoints = self.recoverPoints
                        })
                    end
                end
                --
                -- collision code for bricks
                --
                -- we check to see if the opposite side of our velocity is outside of the brick;
                -- if it is, we trigger a collision on that side. else we're within the X + width of
                -- the brick and should check to see if the top or bottom edge is outside of the brick,
                -- colliding on the top or bottom accordingly 
                --

                -- left edge; only check if we're moving right, and offset the check by a couple of pixels
                -- so that flush corner hits register as Y flips, not X flips
                if self.balls[i].x + 2 < brick.x and self.balls[i].dx > 0 then
                    
                    -- flip x velocity and reset position outside of brick
                    self.balls[i].dx = -self.balls[i].dx
                    self.balls[i].x = brick.x - 8
                
                -- right edge; only check if we're moving left, , and offset the check by a couple of pixels
                -- so that flush corner hits register as Y flips, not X flips
                elseif self.balls[i].x + 6 > brick.x + brick.width and self.balls[i].dx < 0 then
                    
                    -- flip x velocity and reset position outside of brick
                    self.balls[i].dx = -self.balls[i].dx
                    self.balls[i].x = brick.x + 32
                
                -- top edge if no X collisions, always check
                elseif self.balls[i].y < brick.y then
                    
                    -- flip y velocity and reset position outside of brick
                    self.balls[i].dy = -self.balls[i].dy
                    self.balls[i].y = brick.y - 8
                
                -- bottom edge if no X collisions or top collision, last possibility
                else
                    -- flip y velocity and reset position outside of brick
                    self.balls[i].dy = -self.balls[i].dy
                    self.balls[i].y = brick.y + 16
                end

                -- slightly scale the y velocity to speed up the game, capping at +- 150
                if math.abs(self.balls[i].dy) < 150 then
                    self.balls[i].dy = self.balls[i].dy * 1.02
                end

                -- only allow colliding with one brick, for corners
                break
            end
        end

        -- if ball goes below bounds remove the ball
        if self.balls[i].y >= VIRTUAL_HEIGHT then
            table.remove(self.balls, i)
        end
    end

    -- for rendering particle systems
    for k, brick in pairs(self.bricks) do
        brick:update(dt)
    end

    -- update existing powerups 
    if self.powerups then
        for k, powerup in pairs(self.powerups) do
            powerup:update(dt)
            -- if powerup hits paddle add special effect
            if powerup:collides(self.paddle) then
                gSounds['powerup']:play()
                powerup:special(self)
            end
            -- delete powerups not in screen
            if not powerup.inScreen then
                table.remove(self.powerups, k)
            end
        end
    end

    -- if we have enough points, recover a point of health
    if self.score > self.recoverPoints then
        -- if gaining health
        if self.health > 2 then
            -- play recover sound effect
            gSounds['recover']:play()
        end
        -- can't go above 3 health
        self.health = math.min(3, self.health + 1)

        -- multiply recover points by 2
        self.recoverPoints = math.min(100000, self.recoverPoints * 2)

    end

    -- if no balls are left go to serve/gameover state and subtract hearts
    if not next(self.balls) then
        self.health = self.health - 1
        gSounds['hurt']:play()
        -- decrease paddle size
        self.paddle.size = math.max(1, self.paddle.size - 1)
        self.paddle.width = self.paddle.size * 32

        if self.health == 0 then
           gStateMachine:change('game-over', {
                score = self.score,
                highScores = self.highScores
            })
        else
            gStateMachine:change('serve', {
                paddle = self.paddle,
                bricks = self.bricks,
                health = self.health,
                score = self.score,
                highScores = self.highScores,
                level = self.level,
                recoverPoints = self.recoverPoints,
                breakLock = self.breakLock
            })
        end
    end

    -- if the pointsThreshold has been passed, spawn a powerup and reset pointsGained
    -- also decrement powerups till next key powerup, but only if there are locked bricks
    if self.pointsGained >= self.pointsThreshold then
        self.nextKeyPowerup = not self.breakLock and self.nextKeyPowerup - 1 or nil
        table.insert(self.powerups, Powerup())
        self.pointsGained = self.pointsGained - self.pointsThreshold
    end
    -- if timerMax is passed, spawn powerup and reset timer
    if self.timer >= self.timerMax then
        self.nextKeyPowerup = not self.breakLock and self.nextKeyPowerup - 1 or nil
        table.insert(self.powerups, Powerup())
        self.timer = self.timer - self.timerMax
    end
    -- spawn key powerup after some ball powerups, if there are locked bricks
    if not self.breakLock then
        if self.nextKeyPowerup <= 0 then
            self.nextKeyPowerup = math.random(5, 8)
            table.insert(self.powerups, Powerup(10))
        end
    end

    -- if enough points have been gained, grow paddle
    if self.tillGrowPaddle <= 0 then 
        self.paddle.size = math.min(4, self.paddle.size + 1)
        self.paddle.width = self.paddle.size * 32
        self.tillGrowPaddle = 10000
    end

    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
end

function PlayState:render()
    -- render bricks
    for k, brick in pairs(self.bricks) do
        brick:render()
    end

    -- render all particle systems
    for k, brick in pairs(self.bricks) do
        brick:renderParticles()
    end

    if self.powerups then
        for k, powerup in pairs(self.powerups) do
            powerup:render()
        end
    end

    self.paddle:render()

    -- render each ball
    if self.balls then
        for k, ball in pairs(self.balls) do
            ball:render()
        end   
    end

    renderScore(self.score)
    renderHealth(self.health)

    -- pause text, if paused
    if self.paused then
        love.graphics.setFont(gFonts['large'])
        love.graphics.printf("PAUSED", 0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH, 'center')
    end
end

function PlayState:checkVictory()
    for k, brick in pairs(self.bricks) do
        if brick.inPlay then
            return false
        end 
    end

    return true
end