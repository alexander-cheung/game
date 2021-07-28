-- fuck you
-- bitch
-- class for picking where to spawn things
CoordinateHelper = Class{}

function CoordinateHelper:init(width, height)
	self.tiles = {}
	for y = 1, height do
		for x = 1, width do
			table.insert(self.tiles, {x = x, y = y})
		end
	end
end

-- get random coordinates
function CoordinateHelper:getCoordinates()
	-- ran out of space then just dont care
	if #self.tiles == 0 then
		return {x = 1 * TILE_SIZE + MAP_RENDER_OFFSET_X, y = 1 * TILE_SIZE + MAP_RENDER_OFFSET_Y}
	end

	local randomNum = math.random(#self.tiles)
	local tile = self.tiles[randomNum]
	table.remove(self.tiles, randomNum)
	return {x = tile.x * TILE_SIZE + MAP_RENDER_OFFSET_X, y = tile.y * TILE_SIZE + MAP_RENDER_OFFSET_Y}
end

function CoordinateHelper:toTile(x, y)
	return {x = math.floor((x - MAP_RENDER_OFFSET_X) / TILE_SIZE), y = math.floor((y - MAP_RENDER_OFFSET_Y) / TILE_SIZE)}
end

-- takes table of x and y (not tiles form)
function CoordinateHelper:Omit(omit)
	if not omit then return end
	for _, item in pairs(omit) do
		-- if is part of omit then remove
		for i, tile in pairs(self.tiles) do
			-- found a match, remove and start looking for next tile
			if item.x == tile.x and item.y == tile.y then
				table.remove(self.tiles, i)
				goto continue
			end
		end
		::continue::
	end
end