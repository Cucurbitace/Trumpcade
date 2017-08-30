require( "animator" )
require( "cheatCode" )
require( "speechBubble" )
require( "BGimage" )
function goToSecretLevel()
	gameSecret:switch()
end
function resetEverything()
	game1.reset()
	game2.reset()
	game3.reset()
end
function love.load()
	love.graphics.setDefaultFilter( "nearest", "nearest" )
	dbug = require( "dbug" )
	cheatCode = newCheatCode( goToSecretLevel, { "up", "up", "down", "down", "left", "right", "left", "right", "b", "a", "return" }, 1 )
	gameOver = require( "gameOver" )
	hiscores = require( "scores" )
	input = require( "input" )
	screen = require( "screen" )
	fonts = require( "fonts" )
	title = require( "title" )
	intro = require( "intro" )
	gameSelect = require( "select" )
	game1 = require( "game1" )
	game2 = require( "game2" )
	game3 = require( "game3" )
	gameSecret = require( "gameSecret" )
	scoreInput = require( "scoreInput" )
	staff = require( "staff" )
	tweeter = require( "tweeter" )
	screen:set( 0, 2 )
	phase = gameSelect
	credits = 0
	score = 0
end
function love.update( dt )
	phase:update( dt )
end
function love.draw()
	love.graphics.setCanvas( screen.canvas )
	love.graphics.clear()
	phase:draw()
	tweeter:draw()
	love.graphics.setCanvas()
	--love.graphics.setShader( screen.shader )
	love.graphics.draw( screen.canvas, 0, 0, screen.angle, screen.scale, screen.scale, screen.ox, screen.oy )
	--love.graphics.setShader()
end
function love.keypressed( key )
	if key == "escape" then love.event.quit() end
	if phase.keypressed then phase:keypressed( key ) end
	dbug:keypressed( key )
end
function love.keyreleased( key )
	if phase.released then phase:keyreleased( key ) end
end