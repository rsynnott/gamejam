local thing = require 'lib/thing'
local tree = require 'lib/tree'
local gamestate = require 'lib/gamestate'
local menu = require 'lib/menu'
local brd = require 'lib/brd'

function love.load()
	tree.load()
	brd.load()
end

function love.draw()
	tree.draw()
	--thing.bla()
	brd.draw()
	menu.draw()

end

function love.mousepressed(x, y, button)
	menu.mousepressed(x,y,button)
	print(string.format("%d, %d", x, y))
end

function love.update(dt)
	gamestate.update(dt)
	tree.update(dt)
	brd.update(dt)
end