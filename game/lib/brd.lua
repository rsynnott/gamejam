local gamestate = require 'lib/gamestate'

local M = {}

local spawn_timer = 0
local next_spawn = 2
local brd_ctr = 1

local state = "not_loaded"
local level_data = nil
local pause_timer = 0

local brd_defs = {{main_frames=3, frame_time=0.5, velocity = 2, health=10, bounty=50, courage=10, accel = 2, pause = 0.1, pause_frame = "smallbird4.png", frame_names={"smallbird1.png", "smallbird2.png", "smallbird3.png"}}}

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
	if gamestate.get_state() == "gameover" then
		return
	end
	love.graphics.setColor(255, 255, 255, 255)
	for k, v in ipairs(gamestate.get_brds()) do
		if not v.gone then
			--print(string.format("Will draw %s", k))
			if v.dying then 
				love.graphics.draw(v.definition.pause_image, v.position[1], (v.position[2] - v.displacement) + v.gravdisplacement, 0, 1, 1, 0, 0)
			else
				love.graphics.draw(v.definition.images[v.frame+1], v.position[1], (v.position[2] - v.displacement) + v.gravdisplacement, 0, v.size, v.size, 0, 0)
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
	if gamestate.get_state() == "gameover" then
		return
	end

	--#print("LOADED!")

	spawn_timer = spawn_timer + dt
	if spawn_timer > next_spawn then
		next_spawn = math.random(level_data.spawn_min, level_data.spawn_max)
		spawn_timer = 0
		
		new_brd = {
			variety = 1,
			position = table_copy(level_data.path[1]),
			frame = 0,
			on_frame_for = 0,
			definition = brd_defs[1],
			velocity = 0,
			path_pos = 1,
			rising = true,
			displacement=0,
			fear = 0,
			damage = 0,
			pause_timer = 0,
			fleeing = false,
			dying = false,
			size = 1,
			gravdisplacement = 0,
			max_velocity_point = 0, 
		}

		gamestate.add_brd(brd_ctr, new_brd)
		brd_ctr = brd_ctr + 1
		print("Added brd")
	end
	for k,v in ipairs(gamestate.get_brds()) do

		if not v.gone then 

			def = brd_defs[v.variety]

			if v.fear >= def.courage then
				v.fleeing = true
			end
			--print(v.damage)

			if v.damage >= def.health then
				v.dying = true
			end

			if v.pause_timer < def.pause then 
				v.pause_timer = v.pause_timer + dt
			else
				v.on_frame_for = v.on_frame_for + dt
				if v.on_frame_for > def.frame_time then
					v.on_frame_for = 0
					v.frame = (v.frame + 1) % def.main_frames
				end


				local distance_travelled = math.sqrt((v.position[1]-level_data.path[v.path_pos][1])*(v.position[1]-level_data.path[v.path_pos][1]) +
					(v.position[2]-level_data.path[v.path_pos][2])*(v.position[2]-level_data.path[v.path_pos][2]))

				--print(string.format("%d %d", v.velocity, def.velocity))
				if v.velocity < def.velocity then
					v.velocity = v.velocity + (def.accel*dt)
					v.max_velocity_point = distance_travelled
				end

				if v.fleeing then
					v.velocity = 20
				end
				local xdiff = level_data.path[v.path_pos+1][1] - level_data.path[v.path_pos][1]
				local ydiff = level_data.path[v.path_pos+1][2] - level_data.path[v.path_pos][2]
				--print(xdiff)
				--print(ydiff)
				local distance = math.sqrt(xdiff*xdiff + ydiff*ydiff)
				--print(string.format("%d %d %d", distance, distance_travelled, v.max_velocity_point))
				if distance - distance_travelled < v.max_velocity_point then
					print("Slowing!")
					v.velocity = math.max(v.velocity-(def.accel*dt), 0.25)
				end

				if v.rising then
					v.displacement = v.displacement + dt * 8
					if v.displacement > 15 then
						v.rising = false
					end
				else
					v.displacement = v.displacement - dt * 8
					if v.displacement < 1 then
						v.rising = true
					end
				end
				--print(string.format("Diff %d %d", ydiff, xdiff))
				local angle = math.atan(ydiff/xdiff)
				local xdiff2 = level_data.path[v.path_pos+1][1] - v.position[1]
				local ydiff2 = level_data.path[v.path_pos+1][2] - v.position[2]
				if v.fleeing then 
					xdiff2 = 0 - v.position[1]
					ydiff2 = 0 - v.position[2]
				end
				local distance2 = math.sqrt(xdiff*xdiff + ydiff*ydiff)

				local scalef = v.velocity / distance2
				local scalex = xdiff2 * scalef
				local scaley = ydiff2 * scalef

				if xdiff2 < 0 then
					v.position[1] = v.position[1] - math.abs(math.cos(angle) * v.velocity) -- scalex
				else
					v.position[1] = v.position[1] + math.abs(math.cos(angle) * v.velocity)
				end
				if ydiff2 < 0 then
					v.position[2] = v.position[2] - math.abs(math.sin(angle) * v.velocity)
				else
					v.position[2] = v.position[2] + math.abs(math.sin(angle) * v.velocity)
				end
				if v.fleeing then 
					v.size = v.size - dt
				end
				if v.dying then
					if v.gravdisplacement == 0 then
						v.gravdisplacement = 1
						end
					v.gravdisplacement = v.gravdisplacement +  (v.gravdisplacement * 9 *dt)
				end
				if v.gravdisplacement > 1000 then
					gamestate.remove_brd(k)
					gamestate.modify_balance(def.bounty)
					gamestate.kill_brd()
				end
				if v.size <= 0 then
					gamestate.remove_brd(k)
					gamestate.modify_balance(def.bounty/2)
					gamestate.scare_brd()
				end
				--print(string.format("%f %f %f %f %f %f %f %f %f", angle, math.sin(angle), math.cos(angle), ydiff, v.path_pos, v.position[1], level_data.path[v.path_pos+1][1], v.position[2], level_data.path[v.path_pos+1][2]))
				if ((xdiff >=0 and v.position[1] >= level_data.path[v.path_pos+1][1]) or (xdiff <=0 and v.position[1] <= level_data.path[v.path_pos+1][1])) or
					((ydiff >=0 and v.position[2] >= level_data.path[v.path_pos+1][2]) or (ydiff <=0 and v.position[2] <= level_data.path[v.path_pos+1][2])) then
					print("AT END POINT")
					v.position[1] = level_data.path[v.path_pos+1][1]
					v.position[2] = level_data.path[v.path_pos+1][2]
					v.path_pos = v.path_pos + 1
					v.velocity=0
					v.pause_timer = 0
					v.max_velocity_point = 0
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

