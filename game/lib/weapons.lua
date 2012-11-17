local gamestate = require 'lib/gamestate'

local M = {}

local level_data = nil
local state = "not_loaded"
local control_state = "idle"
local selected_weapon = nil
local pulse_radius = 0
local pulse_out = true
local pulse_max = 0
local hardpoint_state = {}
local hardpoint_weapon = {}

local function load_level()
	level_data = gamestate.get_level_data()
	for k, def in ipairs(level_data.hardpoints) do
		print(def[1])
		print(def[2])
		hardpoint_state[def] = "unselected"
		hardpoint_weapon[def] = {placed=false}
		print(hardpoint_state[{def[1],def[2]}])
	end
	for k,v in pairs(hardpoint_state) do
		print(k[1])
	end
end

local weapons = {{
	name = "Speaker",
	damage = 0,
	fear = 7,
	time_to_fire = 0.5,
	time_to_reload = 1,
	destroyed_on_fire = false,
	radius=60,
	icon = "speaker.png",
	icon_bounds = {480, 455, 530, 505},
	cost = 20
	},
	{
	name = "Flame",
	damage = 10,
	fear = 0,
	time_to_fire = 0.1,
	time_to_reload = 0.5,
	destroyed_on_fire = false,
	radius=80,
	icon = "flame.png",
	icon_bounds = {530, 455, 580, 505},
	cost = 40
	}
}

local function distance(x1,y1, x2, y2)
	local xdiff = x2-x1
	local ydiff = y2-y1
	--print(xdiff,ydiff)
	local distance = math.sqrt(xdiff*xdiff + ydiff*ydiff)
	return distance
end


function M.load()
	for k, def in ipairs(weapons) do 
		def.icon_image = love.graphics.newImage(string.format("assets/%s", def.icon))

	end
	
end

function M.draw()
	if gamestate.get_state() == "gameover" then 
		return
	end
	if state == "not_loaded" then
		return
	end
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.rectangle("fill", 480, 455, 800, 600)
	--love.graphics.setColor(menu_elements.play_button.text_color)

	for k, v in ipairs(weapons) do
		local alpha = 1
		if v.cost > gamestate.get_balance() then
			alpha = 50
		else
			alpha = 255
		end
		love.graphics.setColor(255, 255, 255, alpha)
		love.graphics.draw(v.icon_image, v.icon_bounds[1], v.icon_bounds[2], 0, 1, 1, 0, 0)
	end

	-- draw hardpoints
	for k, v in ipairs(level_data.hardpoints) do
		--print(hardpoint_state[v] )
		if hardpoint_state[v] == "selected" then

			love.graphics.setColor(255, 0, 0, 150)
			love.graphics.circle("fill", v[1], v[2], pulse_radius)
		elseif hardpoint_state[v] == "taken" then
			if hardpoint_weapon[v].state == "firing" then
				love.graphics.setColor(255, 0, 0, 180)
			elseif hardpoint_weapon[v].state == "reload" then
				love.graphics.setColor(255, 255, 255, 150)
			else
				love.graphics.setColor(255,255,0,150)
			end
			weapon = hardpoint_weapon[v].weapon
			love.graphics.circle("fill", v[1], v[2], weapon.radius)
			love.graphics.draw(weapon.icon_image, v[1], v[2], 0, 1, 1, (weapon.icon_bounds[3]-weapon.icon_bounds[1])/2, (weapon.icon_bounds[4]-weapon.icon_bounds[2])/2)
			
		else
			love.graphics.setColor(0, 255, 0, 100)
			love.graphics.circle("fill", v[1], v[2], 30)
				end
	end
	love.graphics.setColor(0, 0, 0, 255)
	love.graphics.print(string.format("Balance: %d", gamestate.get_balance()), 500, 550)
	love.graphics.print(string.format("Scared: %d", gamestate.birds_scared()), 630, 550)

	love.graphics.print(string.format("Killed: %d", gamestate.birds_killed()), 630, 520)
	local moral_compass = "None"
	if gamestate.birds_scared() + gamestate.birds_killed() > 0 then
		local ratio =  gamestate.birds_killed() / (gamestate.birds_scared() + gamestate.birds_killed())
		if ratio == 0 then
			moral_compass = "Saintly"
		elseif ratio < 0.20 then
			moral_compass = "Virtuous"
		elseif ratio < 0.60 then
			moral_compass = "Unaligned Neutral"
		elseif ratio < 0.80 then
			moral_compass = "Shaky Ground"
		else
			moral_compass = "Burderer"
		end
	end
	love.graphics.print(string.format("Moral Compass: %s", moral_compass), 500, 570)
	love.graphics.print(string.format("Eggs remaining: %d", gamestate.get_eggs_remaining()), 500, 520)
end

function M.mousepressed(x, y, button)
	if state == "not_loaded" then
		return
	end
	--menu.mousepressed(x,y,button)
	print(string.format("%d, %d", x, y))
	if control_state == "idle" then 
		-- Did we hit a weapon?
		local the_weapon = nil
		for k,v in ipairs(weapons) do
			print("%b %b %b %b %b", v.icon_bounds[1] <= x, x <= v.icon_bounds[3], v.icon_bounds[2] <= y, y <= v.icon_bounds[4], v.cost <= gamestate.get_balance())
			if v.icon_bounds[1] <= x and x <= v.icon_bounds[3] and v.icon_bounds[2] <= y and y <= v.icon_bounds[4] and v.cost <= gamestate.get_balance() then
				the_weapon = v
			end
		end
		print("gak")
		print(the_weapon)
		print("Bla")
		if the_weapon then
			print("Vla")
			control_state = "placement"
			selected_weapon = the_weapon
		end

	elseif control_state == "placement" then
		for k,v in pairs(hardpoint_state) do
			print(distance(x, y, k[1], k[2]))
			if distance(x, y, k[1], k[2]) < pulse_max then 
				control_state = "idle"
				hardpoint_state[k] = "taken"
				hardpoint_weapon[k].placed = true
				hardpoint_weapon[k].weapon = selected_weapon
				hardpoint_weapon[k].state = "idle"
				hardpoint_weapon[k].time_left_to_fire = 0
				hardpoint_weapon[k].time_left_to_reload = 0
				gamestate.modify_balance(-selected_weapon.cost)
			end
		end
	end

end



function M.update(dt)
	if pulse_out then
		pulse_radius = pulse_radius + pulse_max*dt
		if pulse_radius > pulse_max then
			pulse_radius = pulse_max
			pulse_out = false
		end
	else
		pulse_radius = pulse_radius - pulse_max*dt
		if pulse_radius < 0 then
			pulse_radius = 0
			pulse_out = true
		end
	end
	--print(control_state)
	if state == "not_loaded" then
		if gamestate.in_game() then
			state = "loaded"
			load_level()
		else
			return
		end
	end

	if control_state == "placement" then
		--print("In placement")
		x,y = love.mouse.getPosition( )
		for k,v in pairs(hardpoint_state) do
			--print(distance(x, y, k[1], k[2]))
			if distance(x, y, k[1], k[2]) < 30 then
				if hardpoint_weapon[k].placed then 
					hardpoint_state[k] = "taken"
				else
					hardpoint_state[k] = "selected"
				end
				pulse_max = selected_weapon.radius
				--print("Over a hardpoint! %d %d %d %d", distance(x, y, k[1], k[2]), x, y, k[1], k[2])
			else
				if hardpoint_weapon[k].placed then 
					hardpoint_state[k] = "taken"
				else
					hardpoint_state[k] = "unselected"
				end
			end
		end
	end

	for k,v in pairs(hardpoint_state) do
		if hardpoint_weapon[k].state == "firing" then
			hardpoint_weapon[k].time_left_to_fire = hardpoint_weapon[k].time_left_to_fire - dt
			if hardpoint_weapon[k].time_left_to_fire <= 0 then
				hardpoint_weapon[k].state = "infiring"
			end
		elseif hardpoint_weapon[k].state == "reload" then
			hardpoint_weapon[k].time_left_to_reload = hardpoint_weapon[k].time_left_to_reload - dt
			if hardpoint_weapon[k].time_left_to_reload <= 0 then
				hardpoint_weapon[k].state = "idle"
			end
		end
		for bk, brd in pairs(gamestate.get_brds()) do
			if hardpoint_weapon[k].placed and not brd.gone and distance(brd.position[1], brd.position[2], k[1], k[2]) < hardpoint_weapon[k].weapon.radius then
				if hardpoint_weapon[k].state == "idle" then
					hardpoint_weapon[k].state = "firing"
					hardpoint_weapon[k].time_left_to_fire = hardpoint_weapon[k].weapon.time_to_fire
				elseif hardpoint_weapon[k].state == "infiring" then
					print("WE HIT A BIRD")
					brd.damage = brd.damage + hardpoint_weapon[k].weapon.damage
					brd.fear = brd.fear + hardpoint_weapon[k].weapon.fear
					hardpoint_weapon[k].state = "reload"
					hardpoint_weapon[k].time_left_to_reload = hardpoint_weapon[k].weapon.time_to_reload
				end
			end
		end
	end
end

return M