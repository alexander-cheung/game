--[[
    GD50
    Match-3 Remake

    -- Board Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    The Board is our arrangement of Tiles with which we must try to find matching
    sets of three horizontally or vertically.
]]

Board = Class{}

function Board:init(x, y, level)
    self.x = x
    self.y = y
    self.matches = {}
    -- every level, have some random 9 tile colors
    self.tileColors = {
        math.random(1, 2), math.random(3, 4), math.random(5, 6),
        math.random(7, 8), math.random(9, 10), math.random(11, 12),
        math.random(13, 14), math.random(15, 16), math.random(17, 18)
    }
    self:initializeTiles(level)
end

function Board:initializeTiles(level)
    self.tiles = {}
    self.shinyTiles = {}

    -- highest type of tile depending on level, caps at 6
    local highestTile = math.min(level, 6)

    for tileY = 1, 8 do
        
        -- empty table that will serve as a new row
        table.insert(self.tiles, {})

        for tileX = 1, 8 do
            -- create a new tile at X,Y with a random color and variety (within the highestTile)
            -- random color for tile
            local color = self.tileColors[math.random(1, 9)]
            -- one in 45 to get shiny tile
            if math.random(1, 45) == 1 then
                local tile = Tile(tileX, tileY, color, math.random(1, highestTile), true)
                -- add any shiny tiles into tiles and shiny tiles tables
                table.insert(self.tiles[tileY], tile)
                table.insert(self.shinyTiles, tile)
            else
                -- else make regular tile
                table.insert(self.tiles[tileY], Tile(tileX, tileY, color, math.random(1, highestTile), false))
            end
        end
    end
    while self:calculateMatches() or not self:CheckPotentialMatches() do
        -- recursively initialize if matches or no potential matches were returned
        -- so we always have a matchless board on start with potential matches
        self:initializeTiles(level)
    end
end

--[[
    Goes left to right, top to bottom in the board, calculating matches by counting consecutive
    tiles of the same color. Doesn't need to check the last tile in every row or column if the 
    last two haven't been a match.
]]
function Board:calculateMatches()
    local matches = {}

    -- how many of the same color blocks in a row we've found
    local matchNum = 1

    -- horizontal matches first
    for y = 1, 8 do
        local colorToMatch = self.tiles[y][1].color
        -- set to true if a shiny tile was matched
        local clearRow = false
        matchNum = 1
        
        -- every horizontal tile
        for x = 2, 8 do
            
            -- if this is the same color as the one we're trying to match...
            if self.tiles[y][x].color == colorToMatch then
                matchNum = matchNum + 1
            else
                
                -- set this as the new color we want to watch for
                colorToMatch = self.tiles[y][x].color

                -- if we have a match of 3 or more up to now, add it to our matches table
                if matchNum >= 3 then
                    local match = {}

                    -- go backwards from here by matchNum
                    for x2 = x - 1, x - matchNum, -1 do
                        -- add each tile to the match that's in that match
                        table.insert(match, self.tiles[y][x2])
                        -- shiny tile, clear the whole row
                        if self.tiles[y][x2].isShiny then
                            clearRow = true
                        end
                    end

                    -- if shiny then change matches to the whole row
                    if clearRow then
                        table.insert(matches, self.tiles[y])
                        -- go to next row
                        goto continue
                    end
                    -- add this match to our total matches table
                    table.insert(matches, match)
                end

                matchNum = 1

                -- don't need to check last two if they won't be in a match
                if x >= 7 then
                    goto continue
                end
            end
        end

        -- account for the last row ending with a match
        if matchNum >= 3 then
            local match = {}
            
            -- go backwards from end of last row by matchNum
            for x = 8, 8 - matchNum + 1, -1 do
                table.insert(match, self.tiles[y][x])
                -- shiny tile, clear the whole row
                if self.tiles[y][x].isShiny then
                    clearRow = true
                end
            end
            -- if shiny then change matches to the whole row
            if clearRow then
                match = self.tiles[y]
            end
            table.insert(matches, match)
        end

        ::continue::
    end

    -- vertical matches
    for x = 1, 8 do
        local colorToMatch = self.tiles[1][x].color
        -- set to true if a shiny tile was matched
        local clearColumn = false
        matchNum = 1

        -- every vertical tile
        for y = 2, 8 do
            if self.tiles[y][x].color == colorToMatch then
                matchNum = matchNum + 1
            else
                colorToMatch = self.tiles[y][x].color

                if matchNum >= 3 then
                    local match = {}

                    for y2 = y - 1, y - matchNum, -1 do
                        table.insert(match, self.tiles[y2][x])
                        if self.tiles[y2][x].isShiny then
                            clearColumn = true
                        end
                    end

                    -- clear whole column if a shiny was found
                    if clearColumn then 
                        local column = {}
                        -- create the column of matches
                        for y = 1, 8 do
                            table.insert(column, self.tiles[y][x])
                        end
                        -- add column into matches
                        table.insert(matches, column)
                        -- go to next column
                        goto continue
                    end

                    table.insert(matches, match)
                end

                matchNum = 1

                -- don't need to check last two if they won't be in a match
                if y >= 7 then
                    goto continue
                end
            end
        end

        -- account for the last column ending with a match
        if matchNum >= 3 then
            local match = {}
            
            -- go backwards from end of last row by matchNum
            for y = 8, 8 - matchNum + 1, -1 do
                table.insert(match, self.tiles[y][x])
            end
            -- clear column if shiny found
            if clearColumn then 
                matches = {}
                for y = 1, 8 do
                    table.insert(matches, self.tiles[y][x])
                end 
            end

            table.insert(matches, match)
        end
        ::continue::
    end

    -- store matches for later reference
    self.matches = matches

    -- return matches table if > 0, else just return false
    return #self.matches > 0 and self.matches or false
end

--[[
    Remove the matches from the Board by just setting the Tile slots within
    them to nil, then setting self.matches to nil.
]]
function Board:removeMatches()
    -- every match
    for k, match in pairs(self.matches) do
        -- every tile in a match
        for k, tile in pairs(match) do
            -- check if the tile was a shiny tile
            for k, shinyTile in pairs(self.shinyTiles) do
                -- if they reference to same object
                if shinyTile == tile then
                    -- if so, remove it from shinyTiles
                    table.remove(self.shinyTiles, k)
                    -- remove the timer for the tile
                    tile.timer:remove()
                end
            end
            -- remove tile
            self.tiles[tile.gridY][tile.gridX] = nil
        end
    end

    self.matches = nil
end

--[[
    Shifts down all of the tiles that now have spaces below them, then returns a table that
    contains tweening information for these new tiles.
]]
function Board:getFallingTiles(level)
    -- tween table, with tiles as keys and their x and y as the to values
    local tweens = {}

    -- for each column, go up tile by tile till we hit a space
    for x = 1, 8 do
        local space = false
        local spaceY = 0

        local y = 8
        while y >= 1 do
            
            -- if our last tile was a space...
            local tile = self.tiles[y][x]
            
            if space then
                
                -- if the current tile is *not* a space, bring this down to the lowest space
                if tile then
                    
                    -- put the tile in the correct spot in the board and fix its grid positions
                    self.tiles[spaceY][x] = tile
                    tile.gridY = spaceY

                    -- set its prior position to nil
                    self.tiles[y][x] = nil

                    -- tween the Y position to 32 x its grid position
                    tweens[tile] = {
                        y = (tile.gridY - 1) * 32
                    }

                    -- set Y to spaceY so we start back from here again
                    space = false
                    y = spaceY

                    -- set this back to 0 so we know we don't have an active space
                    spaceY = 0
                end
            elseif tile == nil then
                space = true
                
                -- if we haven't assigned a space yet, set this to it
                if spaceY == 0 then
                    spaceY = y
                end
            end

            y = y - 1
        end
    end

    -- highest type of tile for this level, caps at 6
    local highestTile = math.min(level, 6)

    -- create replacement tiles at the top of the screen
    for x = 1, 8 do
        for y = 8, 1, -1 do
            local tile = self.tiles[y][x]

            -- if the tile is nil, we need to add a new one
            if not tile then                
                local tile
                -- random color for tile
                local color = self.tileColors[math.random(1, 9)]
                -- 1 in 15 chance to have shiny tile
                if math.random(1, 15) < 1 then
                    -- add tile to shinyTiles
                    tile = Tile(x, y, color, math.random(1, highestTile), true)
                    tile.y = -32
                    table.insert(self.shinyTiles, tile)
                else
                    -- regular tile
                    tile = Tile(x, y, color, math.random(1, highestTile), false)
                    tile.y = -32
                end

                -- new tile with random color and variety
                self.tiles[y][x] = tile

                -- create a new tween to return for this tile to fall down
                tweens[tile] = {
                    y = (tile.gridY - 1) * 32
                }
            end
        end
    end

    return tweens
end

-- checks the board if there are any potential matches
function Board:CheckPotentialMatches()
    for y, row in pairs(self.tiles) do
        for x, tile in pairs(row) do

            -- if possible, swap tile with one under it and check for matches
            -- check if theres a tile under
            if y + 1 < #self.tiles then
                -- if so, swap tiles
                self:Swap(tile.gridX, tile.gridY, self.tiles[y + 1][x].gridX, self.tiles[y + 1][x].gridY, false)

                -- check for matches
                if self:calculateMatches() then
                    -- swap back and return true
                    self:Swap(tile.gridX, tile.gridY, self.tiles[y][x].gridX, self.tiles[y][x].gridY, false)
                    return true
                end
                -- no match, still swap back
                self:Swap(tile.gridX, tile.gridY, self.tiles[y][x].gridX, self.tiles[y][x].gridY, false)
            end

            -- now check tile to the right
            if x + 1 < #row then
                -- swap tiles
                self:Swap(tile.gridX, tile.gridY, self.tiles[y][x + 1].gridX, self.tiles[y][x + 1].gridY, false)
                -- check for matches
                if self:calculateMatches() then
                    -- swap back and return true
                    self:Swap(tile.gridX, tile.gridY, self.tiles[y][x].gridX, self.tiles[y][x].gridY, false)
                    return true
                end
                -- no match, still swap back
                self:Swap(tile.gridX, tile.gridY, self.tiles[y][x].gridX, self.tiles[y][x].gridY, false)
            end
        end
    end
    -- if we got to the end, no matches so return false
    return false
end

-- swaps two tiles in the board
function Board:Swap(x1, y1, x2, y2, Tween, TweenCallBack)
    -- swap grid positions
    self.tiles[y1][x1].gridX = x2
    self.tiles[y1][x1].gridY = y2
    self.tiles[y2][x2].gridX = x1
    self.tiles[y2][x2].gridY = y1

    -- copy of tile 2 to put into tile 1
    local tile2 = self.tiles[y2][x2]
    -- swap tiles in the tiles table
    self.tiles[y2][x2] = self.tiles[y1][x1]
    self.tiles[y1][x1] = tile2

    -- tween coordinates between the two so they swap
    if Tween then
        -- only call finish if callback was passed in
        if TweenCallBack then
            -- swap x and y
            Timer.tween(0.1, {
                -- setting 2nd tile to what the former 2nd tile x and y was
                [self.tiles[y2][x2]] = {x = tile2.x, y = tile2.y},
                -- setting 1st tile to what the old 1st tile x and y was
                [self.tiles[y1][x1]] = {x = self.tiles[y2][x2].x, y = self.tiles[y2][x2].y}
            }):finish(TweenCallBack)
        else
            Timer.tween(0.1, {
                -- setting 2nd tile to what the former 2nd tile x and y was
                [self.tiles[y2][x2]] = {x = tile2.x, y = tile2.y},
                -- setting 1st tile to what the old 1st tile x and y was
                [self.tiles[y1][x1]] = {x = self.tiles[y2][x2].x, y = self.tiles[y2][x2].y}
            })
        end
    -- if no tween, swap x and y
    else
        -- saving these because setting current tile 1 xy to former tile 1 xy
        -- will override tile2's x and y because current tile 1 is the same reference
        -- to the same object, this doesn't happen in the tween because the tiles aren't
        -- immediately set to override the other
        local tile2X = tile2.x
        local tile2Y = tile2.y
        -- change current tile 1 x and y to former tile 1 x and y
        self.tiles[y1][x1].x = self.tiles[y2][x2].x
        self.tiles[y1][x1].y = self.tiles[y2][x2].y
        -- change tile 2's x and y to former tile 2's x and y
        self.tiles[y2][x2].x = tile2X
        self.tiles[y2][x2].y = tile2Y
    end
end

-- tweens all tiles to their correct spot
function Board:TweenTiles()
    local tweens = {}
    for y, row in pairs(self.tiles) do
        for x, tile in pairs(row) do
            tweens[tile] = {y = (tile.gridY - 1) * 32}
            tile.y = 0
        end
    end
    Timer.tween(0.25, tweens)
end

function Board:render()
    for y = 1, #self.tiles do
        for x = 1, #self.tiles[1] do
            self.tiles[y][x]:render(self.x, self.y)
            if self.tiles[y][x].isShiny then
                self.tiles[y][x]:renderParticles()
            end
        end
    end
end