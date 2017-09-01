require( "animator" )
require( "cheatCode" )
require( "speechBubble" )
require( "BGimage" )
function playerHasHiScore( hiscores, score )
	for _, hiscore in pairs( hiscores ) do
		if score > hiscore.value then return true end
	end
end
function goToSecretLevel()
	gameSelect.music:stop()
	gameSecret:switch()
end
function resetEverything()
	game1:reset()
	game2:reset()
	game3:reset()
end
function printScore( score, font )
	love.graphics.setFont( font )
	love.graphics.setColor( 255, 255, 255 )
	love.graphics.printf( "SCORE", 0, 4, 224, "center" )
	love.graphics.printf( score, 0, 14, 224, "center" )
end
function love.load()
	-- Global variables
	gameIsComplete = { false, false, false }
	creditSound = love.audio.newSource( "sounds/sfx_coin_cluster3.wav" )
	credits = 0
	score = 0
	love.graphics.setDefaultFilter( "nearest", "nearest" )
	-- Code import
	dbug = require( "dbug" )
	fonts = require( "fonts" )
	input = require( "input" )
	cheatCode = newCheatCode( goToSecretLevel, { input.up, input.up, input.down, input.down, input.left, input.right, input.left, input.right, input.b, input.a }, 1 )
	gameOver = require( "gameOver" )
	continue = require( "continue" )
	hiscores = require( "scores" )
	screen = require( "screen" )
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
	-- Init
	screen:set( 0, 2 )
	currentGame = game1
	phase = intro
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
	if key == input.coin then
		if creditSound:isPlaying() then creditSound:stop() end
		creditSound:play()
		credits = credits + 1
	end
	if phase.keypressed then phase:keypressed( key ) end
	dbug:keypressed( key )
end
function love.keyreleased( key )
	if phase.keyreleased then phase:keyreleased( key ) end
end