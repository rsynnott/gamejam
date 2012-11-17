local thing = require 'lib/thing'
local tree = require 'lib/tree'
local gamestate = require 'lib/gamestate'
local menu = require 'lib/menu'
local brd = require 'lib/brd'
local weapons = require 'lib/weapons'
local overlay = require 'lib/overlay'

function love.load()
	tree.load()
	brd.load()
	weapons.load()
end

function love.draw()
	love.graphics.setBackgroundColor(192, 216, 144, 0)
	tree.draw()
	--thing.bla()
	brd.draw()
	menu.draw()
	overlay.draw()
	weapons.draw()

end

function love.mousepressed(x, y, button)
	menu.mousepressed(x,y,button)
	weapons.mousepressed(x,y,button)
	print(string.format("%d, %d", x, y))
end

function love.update(dt)
	gamestate.update(dt)
	tree.update(dt)
	brd.update(dt)
	weapons.update(dt)
end