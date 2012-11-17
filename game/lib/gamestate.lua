--local brd = require 'lib/brd'
--local tree = require 'lib/tree'

local M = {}

local state = {
	system_state = "menu",
	level = 0,
	level_data = nil,
	brds = {},
	brds_removed = 0,
	brds_killed = 0,
	brds_scared = 0,
	eggs_remaining = nil,
	gone = false,
	balance = 50
}



function M.in_game()
	return state.system_state == "playing"
end

function M.get_state()
	return state.system_state
end

function M.in_menu()
	
	return state.system_state == "menu"
end

function M.lose_egg()
	print("Lost an egg!")
	state.eggs_remaining = state.eggs_remaining - 1
	state.brds_removed = state.brds_removed + 1
end

function M.get_eggs_remaining()
	return state.eggs_remaining
end

function M.kill_brd()
	state.brds_killed = state.brds_killed + 1
end

function M.scare_brd()
	state.brds_scared = state.brds_scared + 1
end

function M.birds_scared()
	return state.brds_scared
end

function M.birds_killed()
	return state.brds_killed
end

function M.get_level_data()
	return state.level_data
end

function M.add_brd(id, brd)
	state.brds[id] = brd
end

function M.remove_brd(id)
	state.brds[id].gone = true
end

function M.get_brds()
	return state.brds
end

function M.get_balance()
	return state.balance
end

function M.modify_balance(delta)
	state.balance = state.balance + delta
end 

function M.start_game()
	print("Start")
	state.level = 1
	state.system_state = "playing"
	state.level_data = love.filesystem.load(string.format("levels/%d.lua", state.level))()
	state.eggs_remaining = state.level_data.eggs
	print(state.level_data)
	--tree.level_setup()
	--brd.level_setup()
end

function M.update(dt)
	if not state.level_data then
		return
	end
	if state.eggs_remaining < 1 or (state.brds_scared + state.brds_killed) >= state.level_data.brds then
		state.system_state = "gameover"
	end
end

return M