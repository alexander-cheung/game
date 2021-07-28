LevelUpState = Class{__includes = BaseState}

function LevelUpState:init(stats)
	self.menu = Menu {
		x = VIRTUAL_WIDTH - 180,
		y = VIRTUAL_HEIGHT - 148,
		width = 180,
		height = 84,
		items = {
			{text = "HP: "..stats.initial.health.." + "..stats.increase.health.." = "..stats.final.health, onSelect = function () end},
			{text = "Attack: "..stats.initial.attack.." + "..stats.increase.attack.." = "..stats.final.attack, onSelect = function () end},
			{text = "Speed: "..stats.initial.speed.." + "..stats.increase.speed.." = "..stats.final.speed, onSelect = function () end},
			{text = "Defense: "..stats.initial.defense.." + "..stats.increase.defense.." = "..stats.final.defense, onSelect = function () end}
		},
		textOnly = true
	}
end

function LevelUpState:update(dt)
	-- self.menu:update(dt) not needed cause selections only update as not textOnly
	if love.keyboard.wasPressed("enter") or love.keyboard.wasPressed("return") then
        gStateStack:pop()
        TakeTurnState:fadeOutWhite()
	end
end

function LevelUpState:render()
	self.menu:render()
end