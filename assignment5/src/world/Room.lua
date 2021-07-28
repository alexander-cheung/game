--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

Room = Class{}

function Room:init(player)
    self.width = MAP_WIDTH
    self.height = MAP_HEIGHT

    self.tiles = {}
    self:generateWallsAndFloors()
    self.coHelper = CoordinateHelper(self.width - 2, self.height - 2)

    self.coHelper:Omit(OMIT)
    -- entities in the room
    self.entities = {}
    self:generateEntities()

    -- game objects in the room
    self.objects = {}
    self:generateObjects()

    -- dont need coHelper anymore
    self.coHelper = nil

    -- doorways that lead to other dungeon rooms
    self.doorways = {}
    table.insert(self.doorways, Doorway('top', false, self))
    table.insert(self.doorways, Doorway('bottom', false, self))
    table.insert(self.doorways, Doorway('left', false, self))
    table.insert(self.doorways, Doorway('right', false, self))

    -- reference to player for collisions, etc.
    self.player = player

    -- used for centering the dungeon rendering
    self.renderOffsetX = MAP_RENDER_OFFSET_X
    self.renderOffsetY = MAP_RENDER_OFFSET_Y

    -- used for drawing when this room is the next room, adjacent to the active
    self.adjacentOffsetX = 0
    self.adjacentOffsetY = 0
end

--[[
    Randomly creates an assortment of enemies for the player to fight.
]]
function Room:generateEntities()
    local types = {'skeleton', 'slime', 'bat', 'ghost', 'spider'}

    -- if the amount of entities is like 10000 the collision detection matters makes game slow but who cares
    for i = 1, 10 do
        local type = types[math.random(#types)]
        local coordinates = self.coHelper:getCoordinates()
        table.insert(self.entities, Entity {
            animations = ENTITY_DEFS[type].animations,
            walkSpeed = ENTITY_DEFS[type].walkSpeed or 20,

            -- ensure X and Y are within bounds of the map
            x = coordinates.x,
            y = coordinates.y,
            
            width = 16,
            height = 16,

            health = 1,
            -- chance to spawn heart
            spawnHeart = math.random(1, 10) == 1
        })

        self.entities[i].stateMachine = StateMachine {
            ['walk'] = function() return EntityWalkState(self.entities[i]) end,
            ['idle'] = function() return EntityIdleState(self.entities[i]) end
        }

        self.entities[i]:changeState('walk')
    end
end

--[[
    Randomly creates an assortment of obstacles for the player to navigate around.
]]
function Room:generateObjects()
    local switchCoordinates = self.coHelper:getCoordinates()
    table.insert(self.objects, GameObject(GAME_OBJECT_DEFS['switch'], switchCoordinates.x, switchCoordinates.y))

    -- get a reference to the switch
    local switch = self.objects[1]

    -- define a function for the switch that will open all doors in the room
    switch.onCollide = function()
        if switch.state == 'unpressed' then
            switch.state = 'pressed'
            
            -- open every door in the room if we press the switch
            for k, doorway in pairs(self.doorways) do
                doorway.open = true
            end

            gSounds['door']:play()
        end
    end

    -- four randomly placed pots
    for i = 1, 8 do
        local potCoordinates = self.coHelper:getCoordinates()
        table.insert(self.objects, GameObject(GAME_OBJECT_DEFS["pot"], potCoordinates.x, potCoordinates.y))
    end
end

--[[
    Generates the walls and floors of the room, randomizing the various varieties
    of said tiles for visual variety.
]]
function Room:generateWallsAndFloors()
    for y = 1, self.height do
        table.insert(self.tiles, {})

        for x = 1, self.width do
            local id = TILE_EMPTY

            if x == 1 and y == 1 then
                id = TILE_TOP_LEFT_CORNER
            elseif x == 1 and y == self.height then
                id = TILE_BOTTOM_LEFT_CORNER
            elseif x == self.width and y == 1 then
                id = TILE_TOP_RIGHT_CORNER
            elseif x == self.width and y == self.height then
                id = TILE_BOTTOM_RIGHT_CORNER
            
            -- random left-hand walls, right walls, top, bottom, and floors
            elseif x == 1 then
                id = TILE_LEFT_WALLS[math.random(#TILE_LEFT_WALLS)]
            elseif x == self.width then
                id = TILE_RIGHT_WALLS[math.random(#TILE_RIGHT_WALLS)]
            elseif y == 1 then
                id = TILE_TOP_WALLS[math.random(#TILE_TOP_WALLS)]
            elseif y == self.height then
                id = TILE_BOTTOM_WALLS[math.random(#TILE_BOTTOM_WALLS)]
            else
                id = TILE_FLOORS[math.random(#TILE_FLOORS)]
            end
            
            table.insert(self.tiles[y], {
                id = id
            })
        end
    end
end

function Room:update(dt)
    -- don't update anything if we are sliding to another room (we have offsets)
    if self.adjacentOffsetX ~= 0 or self.adjacentOffsetY ~= 0 then return end

    self.player:update(dt)

    for i = #self.entities, 1, -1 do
        local entity = self.entities[i]

        -- remove entity from the table if health is <= 0
        if entity.health <= 0 then
            entity.dead = true            
            -- spawn heart, 1 time
            if entity.spawnHeart then
                entity.spawnHeart = false                
                local heart = GameObject(GAME_OBJECT_DEFS["heart"], entity.x, entity.y)
                heart.onConsume = function(player)
                    player.health = math.min(player.health + 2, 6)
                    gSounds['recover']:play()
                end
                table.insert(self.objects, heart)
            end
        elseif not entity.dead then
            entity:processAI({room = self}, dt)
            entity:update(dt)
        end

        -- collision between the player and entities in the room
        if not entity.dead and self.player:collides(entity) and not self.player.invulnerable then
            gSounds['hit-player']:play()
            self.player:damage(1)
            self.player:goInvulnerable(1.5)

            if self.player.health == 0 then
                gStateMachine:change('game-over')
            end
        end

        -- checks collision with other entities
        for _, e in pairs(self.entities) do
            if entity ~= e and entity:collides(e) then
                entity.stateMachine.current.bumped = true
                entity:resetPosition()
            end
        end
    end

    for i = #self.objects, 1, -1 do
        self.objects[i]:update(dt)
        -- if projectile check collision with other gameobjects and the walls
        if self.objects[i].fired then
            -- projectile traveled max distance
            if self.objects[i].travel <= 0 then
                table.remove(self.objects, i)
                gSounds["pot-break"]:play()                
                goto continue -- no need to keep updating
            -- goes past a wall
            elseif self.objects[i].x < LEFT_WALL or self.objects[i].x + self.objects[i].width > RIGHT_WALL
              or self.objects[i].y < TOP_WALL or self.objects[i].y + self.objects[i].height > BOTTOM_WALL then
                table.remove(self.objects, i)
                gSounds["pot-break"]:play()                
                goto continue
            else -- collides with gameobject other than itself
                for k, object in pairs(self.objects) do
                    if object ~= self.objects[i] and object.solid and object:collides(self.objects[i]) then
                        table.remove(self.objects, i)
                        gSounds["pot-break"]:play()                        
                        goto continue
                    end
                end
            end
        end

        -- collision for entities and objects
        for _, entity in pairs(self.entities) do
            if entity:collides(self.objects[i]) and not entity.dead then
                if self.objects[i].fired then
                    entity:damage(1)
                    table.remove(self.objects, i)
                    gSounds["pot-break"]:play()                    
                    goto continue
                else
                    -- assuming statemachine is walking cause it had to have walked into the object
                    entity.stateMachine.current.bumped = true
                    entity:resetPosition()
                end
            end
        end

        -- trigger collision callback on object
        if self.player:collides(self.objects[i]) then
            if self.objects[i].solid then
                -- reset position if collides with a solid
                self.player:resetPosition()
            end

            self.objects[i]:onCollide(self.player)

            -- if consumable then call onConsume and delete
            if self.objects[i].consumable then
                self.objects[i].onConsume(self.player)
                table.remove(self.objects, i)
            end
        end
        ::continue::
    end
end

function Room:render()
    for y = 1, self.height do
        for x = 1, self.width do
            local tile = self.tiles[y][x]
            love.graphics.draw(gTextures['tiles'], gFrames['tiles'][tile.id],
                (x - 1) * TILE_SIZE + self.renderOffsetX + self.adjacentOffsetX, 
                (y - 1) * TILE_SIZE + self.renderOffsetY + self.adjacentOffsetY)
        end
    end

    -- render doorways; stencils are placed where the arches are after so the player can
    -- move through them convincingly
    for k, doorway in pairs(self.doorways) do
        doorway:render(self.adjacentOffsetX, self.adjacentOffsetY)
    end

    for k, object in pairs(self.objects) do
        object:render(self.adjacentOffsetX, self.adjacentOffsetY)
    end

    for k, entity in pairs(self.entities) do
        if not entity.dead then entity:render(self.adjacentOffsetX, self.adjacentOffsetY) end
    end

    -- stencil out the door arches so it looks like the player is going through
    push:setCanvas('stencil_canvas')
    love.graphics.stencil(function()
        -- left (bigger on top in case of object)
        love.graphics.rectangle('fill', -TILE_SIZE - 6, MAP_RENDER_OFFSET_Y + (MAP_HEIGHT / 2) * TILE_SIZE - TILE_SIZE * 2,
            TILE_SIZE * 2 + 6, TILE_SIZE * 3)
        
        -- right (bigger on top in case of object)
        love.graphics.rectangle('fill', MAP_RENDER_OFFSET_X + (MAP_WIDTH * TILE_SIZE) - 6,
            MAP_RENDER_OFFSET_Y + (MAP_HEIGHT / 2) * TILE_SIZE - TILE_SIZE * 2, TILE_SIZE * 2 + 6, TILE_SIZE * 3)
        
        -- top
        love.graphics.rectangle('fill', MAP_RENDER_OFFSET_X + (MAP_WIDTH / 2) * TILE_SIZE - TILE_SIZE,
            -TILE_SIZE - 6, TILE_SIZE * 2, TILE_SIZE * 2 + 12)
        
        --bottom
        love.graphics.rectangle('fill', MAP_RENDER_OFFSET_X + (MAP_WIDTH / 2) * TILE_SIZE - TILE_SIZE,
            VIRTUAL_HEIGHT - TILE_SIZE - 6, TILE_SIZE * 2, TILE_SIZE * 2 + 12)
    end, 'replace', 1)

    love.graphics.setStencilTest('less', 1)
    
    if self.player then
        self.player:render()
    end

    love.graphics.setStencilTest()
end