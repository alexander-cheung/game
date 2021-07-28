--[[
    ScoreState Class
    Author: Colton Ogden
    cogden@cs50.harvard.edu

    A simple state used to display the player's score before they
    transition back into the play state. Transitioned to from the
    PlayState when they collide with a Pipe.
]]

ScoreState = Class{__includes = BaseState}

-- medals
goldMedal = love.graphics.newImage("gold.png")
silverMedal = love.graphics.newImage("silver.png")
bronzeMedal = love.graphics.newImage("bronze.png")

-- minimum score for each medal
local BRONZE = 5
local SILVER = 10
local GOLD = 15

-- medal placement
local medal_x = (VIRTUAL_WIDTH - goldMedal:getWidth()) / 2
local medal_y = VIRTUAL_HEIGHT * 0.63
--[[
    When we enter the score state, we expect to receive the score
    from the play state so we know what to render to the State.
]]
function ScoreState:enter(params)
    self.score = params.score
end

function ScoreState:update(dt)
    -- go back to play if enter is pressed
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        gStateMachine:change('countdown')
    end
end

function ScoreState:render()
    -- simply render the score to the middle of the screen
    love.graphics.setFont(flappyFont)
    love.graphics.printf('Oof! You lost!', 0, 64, VIRTUAL_WIDTH, 'center')

    love.graphics.setFont(mediumFont)
    love.graphics.printf('Score: ' .. tostring(self.score), 0, 100, VIRTUAL_WIDTH, 'center')

    love.graphics.printf('Press Enter to Play Again!', 0, 160, VIRTUAL_WIDTH, 'center')
    if self.score >= GOLD then
        love.graphics.draw(goldMedal, medal_x, medal_y)
    elseif self.score >= SILVER then
        love.graphics.draw(silverMedal, medal_x, medal_y)
    elseif self.score >= BRONZE then
        love.graphics.draw(bronzeMedal, medal_x, medal_y)
    end
end