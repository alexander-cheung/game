--[[
    GD50
    Breakout Remake

    -- StartState Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Represents the state that the game is in when we've just completed a level.
    Very similar to the ServeState, except here we increment the level 
]]

VictoryState = Class{__includes = BaseState}

function VictoryState:enter(params)
    self.level = params.level
    self.score = params.score
    self.highScores = params.highScores
    self.paddle = params.paddle
    self.health = params.health
    self.balls = params.balls
    self.recoverPoints = params.recoverPoints
end

function VictoryState:update(dt)
    self.paddle:update(dt)

    -- sum of x length of all balls 
    local TotalBallX = #self.balls * 8
    -- x for current ball (centered on paddle)
    local BallX = self.paddle.x + (self.paddle.width / 2) - TotalBallX / 2
    -- if too many balls and balls are out of screen, set ballx to edge of left/right screen
    if BallX < 0 then
        BallX = 0
    elseif BallX + TotalBallX > VIRTUAL_WIDTH then
        BallX = VIRTUAL_WIDTH - TotalBallX
    end

    -- have the ball track the player
    for k, ball in pairs(self.balls) do
        -- assign ball x and y
        ball.x = BallX
        ball.y = self.paddle.y - ball.width
        -- update ball x for next ball
        BallX = BallX + ball.width
    end

    -- go to play screen if the player presses Enter
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        local level = self.level + 1
        -- if game can have locked bricks
        local lock = (math.random(0, 1) == 0 and level > 10) and true or false
        local LevelMakerReturn = LevelMaker.createMap(level, lock)
        -- return paddle to default size
        self.paddle.size = 2
        self.paddle.width = self.paddle.size * 32
        gStateMachine:change('serve', {
            level = level,
            bricks = LevelMakerReturn["bricks"],
            -- if there are any locked bricks in the game, spawn keys
            breakLock = not LevelMakerReturn["HasLockedBricks"],
            paddle = self.paddle,
            health = self.health,
            score = self.score,
            highScores = self.highScores,
            recoverPoints = self.recoverPoints
        })
    end
end

function VictoryState:render()
    self.paddle:render()
    -- render each ball in the correct spot
    for k, ball in pairs(self.balls) do
        ball:render()
    end

    renderHealth(self.health)
    renderScore(self.score)

    -- level complete text
    love.graphics.setFont(gFonts['large'])
    love.graphics.printf("Level " .. tostring(self.level) .. " complete!",
        0, VIRTUAL_HEIGHT / 4, VIRTUAL_WIDTH, 'center')

    -- instructions text
    love.graphics.setFont(gFonts['medium'])
    love.graphics.printf('Press Enter to serve!', 0, VIRTUAL_HEIGHT / 2,
        VIRTUAL_WIDTH, 'center')
end