local gamestate = require 'lib/gamestate'

local M = {}

function M.draw()
	love.graphics.setColor(255, 255, 255, 255)
	local eggs_remaining = gamestate.get_eggs_remaining()
	--print(eggs_remaining)
	if not eggs_remaining == nil then
		love.graphics.print(string.format("Eggs Remaining: %d", eggs_remaining), 700, 10)
	end
end

return M
