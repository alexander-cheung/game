--[[
    GD50
    Super Mario Bros. Remake

    -- LevelMaker Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

LevelMaker = Class{}

function LevelMaker.generate(height, levelNumber)
    local width = 100 + 10 * (levelNumber - 1)

    local tiles = {}
    local entities = {}
    local objects = {}

    local tileID = TILE_ID_GROUND
    
    -- whether we should draw our tiles with toppers
    local topper = true
    local tileset = math.random(20)
    local topperset = math.random(20)

    -- if key or lock has been generated
    local keySpawned = false
    local lockSpawned = false
    local lockBrick = nil
    local lockindex = nil

    -- insert blank tables into tiles for later access
    for x = 1, height do
        table.insert(tiles, {})
    end

    -- create regular column for 1st column
    -- lay out the empty space
    for y = 1, 6 do
        table.insert(tiles[y],
            Tile(1, y, TILE_ID_EMPTY, nil, tileset, topperset))
    end
    -- topper
    table.insert(tiles[7], Tile(1, 7, TILE_ID_GROUND, topper, tileset, topperset))
    -- rest of land
    for y = 8, 10 do
        table.insert(tiles[y], Tile(1, y, TILE_ID_GROUND, nil, tileset, topperset))
    end

    -- column by column generation instead of row; sometimes better for platformers
    -- leaves first and last column out so they can be normal columns
    for x = 2, width - 1 do
        local tileID = TILE_ID_EMPTY
        
        -- lay out the empty space
        for y = 1, 6 do
            table.insert(tiles[y],
                Tile(x, y, tileID, nil, tileset, topperset))
        end

        -- chance to just be emptiness
        if math.random(7) == 1 then
            for y = 7, height do
                table.insert(tiles[y],
                    Tile(x, y, tileID, nil, tileset, topperset))
            end
        else
            tileID = TILE_ID_GROUND

            local blockHeight = 4

            for y = 7, height do
                table.insert(tiles[y],
                    Tile(x, y, tileID, y == 7 and topper or nil, tileset, topperset))
            end

            -- chance to generate a pillar
            if math.random(8) == 1 then
                blockHeight = 2
                
                -- chance to generate bush on pillar
                if math.random(8) == 1 then
                    table.insert(objects,
                        GameObject {
                            quad = 'bushes',                            
                            texture = 'bushes',
                            x = (x - 1) * TILE_SIZE,
                            y = (4 - 1) * TILE_SIZE,
                            width = 16,
                            height = 16,
                            
                            -- select random frame from bush_ids whitelist, then random row for variance
                            frame = BUSH_IDS[math.random(#BUSH_IDS)] + (math.random(4) - 1) * 7
                        }
                    )
                end
                
                -- pillar tiles
                tiles[5][x] = Tile(x, 5, tileID, topper, tileset, topperset)
                tiles[6][x] = Tile(x, 6, tileID, nil, tileset, topperset)
                tiles[7][x].topper = nil
            
            -- chance to generate bushes
            elseif math.random(8) == 1 then
                table.insert(objects,
                    GameObject {
                        quad = 'bushes',                        
                        texture = 'bushes',
                        x = (x - 1) * TILE_SIZE,
                        y = (6 - 1) * TILE_SIZE,
                        width = 16,
                        height = 16,
                        frame = BUSH_IDS[math.random(#BUSH_IDS)] + (math.random(4) - 1) * 7,
                        collidable = false
                    }
                )
            end

            -- chance to spawn a block
            if math.random(6) == 1 then
                table.insert(objects,
                    -- jump block
                    GameObject {
                        quad = "jump-blocks",
                        texture = 'jump-blocks',
                        x = (x - 1) * TILE_SIZE,
                        y = (blockHeight - 1) * TILE_SIZE,
                        width = 16,
                        height = 16,

                        -- make it a random variant
                        frame = math.random(#JUMP_BLOCKS),
                        collidable = true,
                        hit = false,
                        solid = true,

                        -- collision function takes itself
                        onCollide = function(obj)
                            -- spawn a gem if we haven't already hit the block
                            if not obj.hit then
                                obj.hit = true                                
                                -- chance to spawn gem, not guaranteed
                                if math.random(3) == 1 then
                                    -- maintain reference so we can set it to nil
                                    local gem = GameObject {
                                        quad = "gems",                                        
                                        texture = 'gems',
                                        x = (x - 1) * TILE_SIZE,
                                        y = (blockHeight - 1) * TILE_SIZE - 4,
                                        width = 16,
                                        height = 16,
                                        frame = math.random(#GEMS),
                                        collidable = true,
                                        consumable = true,
                                        solid = false,

                                        -- gem has its own function to add to the player's score
                                        onConsume = function(player, object)
                                            gSounds['pickup']:play()
                                            player.score = player.score + 100
                                        end
                                    }
                                    
                                    -- make the gem move up from the block and play a sound
                                    Timer.tween(0.1, {
                                        [gem] = {y = (blockHeight - 2) * TILE_SIZE}
                                    })
                                    gSounds['powerup-reveal']:play()

                                    table.insert(objects, gem)
                                elseif not keySpawned and math.random(3) == 1 then
                                    -- chance for key
                                    keySpawned = true
                                    local KeyColor = math.random(#KEYS)
                                    local key = GameObject {
                                        quad = "keys_and_locks",
                                        texture = 'keys_and_locks',
                                        x = (x - 1) * TILE_SIZE,
                                        y = (blockHeight - 1) * TILE_SIZE - 4,
                                        width = 16,
                                        height = 16,
                                        frame = KEYS[KeyColor],
                                        collidable = false,
                                        consumable = true,
                                        solid = false,

                                        onConsume = function(player, object)
                                            gSounds['pickup']:play()
                                            player.score = player.score + 500
                                            player.key = KeyColor
                                        end
                                    }
                                    Timer.tween(0.1, {
                                        [key] = {y = (blockHeight - 2) * TILE_SIZE}
                                    })
                                    gSounds['powerup-reveal']:play()
                                    table.insert(objects, key)                          
                                end                            
                            end
                            gSounds['empty-block']:play()
                        end
                    }
                )
            -- chance for lock block
            elseif math.random(20) == 1 and not lockSpawned then
                lockSpawned = true
                lockBrick = GameObject {
                    quad = "keys_and_locks",
                    texture = 'keys_and_locks',
                    x = (x - 1) * TILE_SIZE,
                    y = (blockHeight - 1) * TILE_SIZE,
                    width = 16,
                    height = 16,

                    -- make it a random variant
                    frame = LOCKS[math.random(#LOCKS)],
                    collidable = true,
                    consumable = false,
                    solid = true,

                    -- collision function takes itself
                    onCollide = function(object, player)
                        if player.key then
                            player.level.doesthelockthingneedtounexist = true
                            gSounds['pickup']:play()
                            player.key = nil
                            player.level.flagColor = FLAGS[math.random(#FLAGS)]
                            -- spawn flag
                            player.level.flag = true
                            local flag = GameObject {
                                quad = "flags",
                                texture = 'poles',
                                x = width * TILE_SIZE - 16,
                                y = 48,
                                width = 16,
                                height = 48,

                                -- make it a random variant
                                frame = POLES[math.random(#POLES)],
                                collidable = false,
                                hit = false,
                                solid = false,
                                consumable = true,
                                -- collision function takes itself
                                onConsume = function(player)
                                    gSounds['pickup']:play()
                                    gStateMachine:change('play',  {
                                        map = LevelMaker.generate(10, levelNumber + 1),
                                        background = math.random(3),
                                        score = player.score,
                                        level = levelNumber + 1
                                    })
                                end
                            }
                            table.insert(objects, flag)
                        else
                            gSounds['empty-block']:play()                            
                        end
                    end
                }
                lockindex = #objects + 1
                table.insert(objects, lockBrick)
            end
        end
    end

    -- create regular column for last column
    -- lay out the empty space
    for y = 1, 6 do
        table.insert(tiles[y],
            Tile(width, y, TILE_ID_EMPTY, nil, tileset, topperset))
    end
    -- topper
    table.insert(tiles[7], Tile(width, 7, TILE_ID_GROUND, topper, tileset, topperset))
    -- rest of land
    for y = 8, 10 do
        table.insert(tiles[y], Tile(width, y, TILE_ID_GROUND, nil, tileset, topperset))
    end

    local map = TileMap(width, height)
    map.tiles = tiles
    
    return GameLevel(entities, objects, map, lockindex)
end