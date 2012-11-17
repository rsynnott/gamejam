local gamestate = require 'lib/gamestate'

local M = {}

local spawn_timer = 0
local next_spawn = 1
local brd_ctr = 1

local state = "not_loaded"
local level_data = nil
local pause_timer = 0

local brd_defs = {{main_frames=3, frame_time=0.5, velocity = 10, accel = 2, pause = 0.5, pause_frame = "smallbird4.png", frame_names={"smallbird1.png", "smallbird2.png", "smallbird3.png"}}}

function M.level_setup()
	print("IS THE WRD")
end


function M.load()
	for k, def in ipairs(brd_defs) do 
		def.images = {}
		for k,name in ipairs(def.frame_names) do 
			def.images[k] = love.graphics.newImage(string.format("assets/%s", name))
		end
		def.pause_image = love.graphics.newImage(string.format("assets/%s", def.pause_frame))
	end
end

local function load_level()
	level_data = gamestate.get_level_data()
end

local function table_copy(t)
  local u = { }
  for k, v in pairs(t) do u[k] = v end
  return setmetatable(u, getmetatable(t))
end

function M.draw()
	for k, v in ipairs(gamestate.get_brds()) do
		if not v.gone then
			print(string.format("Will draw %s", k))
			if v.pause_timer < v.definition.pause then 
				love.graphics.draw(v.definition.pause_image, v.position[1], v.position[2], 0, 1, 1, 0, 0)
			else
				love.graphics.draw(v.definition.images[v.frame+1], v.position[1], v.position[2], 0, 1, 1, 0, 0)
			end
		end
	end
end
function M.update(dt)
	if state == "not_loaded" then
		if gamestate.in_game() then
			state = "loaded"
			load_level()
		else
			return
		end
	end

	--#print("LOADED!")

	spawn_timer = spawn_timer + dt
	if spawn_timer > next_spawn then
		next_spawn = 2
		spawn_timer = 0
		
		new_brd = {
			variety = 1,
			position = table_copy(level_data.path[1]),
			frame = 0,
			on_frame_for = 0,
			definition = brd_defs[1],
			velocity = 0,
			path_pos = 1,
			pause_timer = 0
		}
		gamestate.add_brd(brd_ctr, new_brd)
		brd_ctr = brd_ctr + 1
		print("Added brd")
	end
	for k,v in ipairs(gamestate.get_brds()) do
		if not v.gone then 
			def = brd_defs[v.variety]
			if v.pause_timer < def.pause then 
				v.pause_timer = v.pause_timer + dt
			else
				v.on_frame_for = v.on_frame_for + dt
				if v.on_frame_for > def.frame_time then
					v.on_frame_for = 0
					v.frame = (v.frame + 1) % def.main_frames
				end

				if v.velocity < def.velocity then
					v.velocity = v.velocity + (def.accel*dt)
				end
				local xdiff = level_data.path[v.path_pos+1][1] - level_data.path[v.path_pos][1]
				local ydiff = level_data.path[v.path_pos+1][2] - level_data.path[v.path_pos][2]
				print(xdiff)
				print(ydiff)
				local distance = math.sqrt(xdiff*xdiff + ydiff*ydiff)
				local scalef = v.velocity / distance
				local scalex = xdiff * scalef
				local scaley = ydiff * scalef
				v.position[1] = v.position[1] + scalex
				v.position[2] = v.position[2] + scaley
				print(string.format("%f %f %f %f %f", v.path_pos, v.position[1], level_data.path[v.path_pos+1][1], v.position[2], level_data.path[v.path_pos+1][2]))
				if ((xdiff >=0 and v.position[1] >= level_data.path[v.path_pos+1][1]) or (xdiff <=0 and v.position[1] <= level_data.path[v.path_pos+1][1])) and
					((ydiff >=0 and v.position[2] >= level_data.path[v.path_pos+1][2]) or (ydiff <=0 and v.position[2] <= level_data.path[v.path_pos+1][2])) then
					print("AT END POINT")
					v.path_pos = v.path_pos + 1
					v.velocity=0
					v.pause_timer = 0
				end

				if v.path_pos >= #level_data.path then 
					gamestate.lose_egg()
					gamestate.remove_brd(k)
					
				end
			end
		end
	end

end

return M

