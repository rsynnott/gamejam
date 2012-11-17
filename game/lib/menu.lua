local gamestate = require 'lib/gamestate'

local M = {}

function M.load()
end

local menu_elements = {play_button = {x = 200,y = 200,w = 200,h = 100,text = "Play",color = {0, 255, 0, 255}, text_color={255,255,255, 255}}}

function M.draw()
	if not gamestate.in_menu() then
		return
	end
	
	if gamestate.get_state() == "gameover" then
		love.graphics.setColor(menu_elements.play_button.text_color)
		love.graphics.printf("Game over", 
		menu_elements.play_button.x,
		menu_elements.play_button.y + (menu_elements.play_button.h/2),
		menu_elements.play_button.w,
		"center")
	else
		love.graphics.setColor(menu_elements.play_button.color)
	love.graphics.rectangle("fill", menu_elements.play_button.x, menu_elements.play_button.y, menu_elements.play_button.w, menu_elements.play_button.h)
	love.graphics.setColor(menu_elements.play_button.text_color)
		 love.graphics.printf("START", 
		menu_elements.play_button.x,
		menu_elements.play_button.y + (menu_elements.play_button.h/2),
		menu_elements.play_button.w,
		"center")
		end
end

function M.mousepressed(x, y, button)
	if gamestate.get_state() == "gameover" then
		return
	end
	if not gamestate.in_menu() then
		return
	end
	if x >= menu_elements.play_button.x and x <= menu_elements.play_button.w+menu_elements.play_button.x
		and y >= menu_elements.play_button.y and y <= menu_elements.play_button.y+menu_elements.play_button.h then
		gamestate.start_game()
		print("Click!")
	end
end


return M