local gamestate = require 'lib/gamestate'

local M = {}

local BRANCH_WIDTH = 20

local level_data = nil

local state = "not_loaded"

local colors = {{139, 69, 19, 255}, {205, 133, 63, 255}}

local sway_time = 0
local sway_total_time = 1
local sway_factor = 30

function M.level_setup()
	-- Load in the level level_data
	level_data = gamestate.get_level_data()
end

local mouse_x = 0
local mouse_y = 0


function M.draw()
	if gamestate.get_state() == "gameover" then
		return
	end
	if level_data then
		for i,v in ipairs(level_data.tree) do
			--print(v)
			love.graphics.setColor(colors[v[6]])
			love.graphics.setLineWidth(v[5])
			local our_sway_time = sway_time 
			if our_sway_time > sway_total_time then
				our_sway_time = sway_total_time - (our_sway_time - sway_total_time)
			end
			--print(our_sway_time)
			local variance = our_sway_time * (1/v[5]) * sway_factor
			love.graphics.line(v[1], v[2], v[3] + variance, v[4] + variance)
		end
	end
end

local function load_level()
	print("Load level")
	level_data = gamestate.get_level_data()
end

function M.update(dt)

	sway_time = dt + sway_time
	if sway_time > sway_total_time*2 then
		sway_time=0
		sway_total_time = math.random(0.75, 2.5)
		sway_factor = math.random(5, 20) * sway_total_time

		--print("RESET")
	end
	

	if state == "not_loaded" and gamestate.in_game() then
		print "BLA"
		load_level()
		state = "loaded"
	end
end

function M.load()
	print("Loading our complex tree!")
end

return M