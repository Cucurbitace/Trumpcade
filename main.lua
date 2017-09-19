loader = require( "libs.love-loader" )
require( "libs.animator" )
require( "cheatCode" )
require( "speechBubble" )
require( "BGimage" )

-- Common functions -------------------------------------------------------------------------------
function loadSettings( path )
	local settings
	if love.filesystem.exists( path ) then
		settings = {}
		for line in love.filesystem.lines( path ) do
			table.insert( settings, tonumber( line ) )
		end
	else
		settings = { 1, 1, 1 } -- Credits per coin, global speed, extra life schme.
		local file, errorstr = love.filesystem.newFile( path, "w" )
		file:write( tostring( settings[ 1 ] ).."\n"..tostring( settings[ 2 ] ).."\n"..tostring( settings[ 3 ] ) )
	end
	return settings
end
function setVolume( dt, volume, direction, music )
	volume = volume + dt * direction
	if volume > 1 then
		volume = 1
	elseif volume < 0 then
		volume = 0
	end
	music:setVolume( volume )
end
function playerHasHiScore( hiscores, score )
	for _, hiscore in pairs( hiscores ) do
		if score > hiscore.value then return true end
	end
end
function goToSecretLevel()
	gameSelect.music:stop()
	gameSecret:switch()
end
function resetEverything( hard )
	game1:reset()
	game2:reset()
	game3:reset()
	if hard then intro:switch() end
end
function printTimer( timer, font )
	local s = size or 1
	love.graphics.setFont( font )
	love.graphics.printf( "TIME", 0, 296, 224, "center" )
	love.graphics.printf( math.ceil( timer), 0, 306, 224, "center" )
end
function printScore( score, font )
	love.graphics.setFont( font )
	love.graphics.setColor( 255, 255, 255 )
	love.graphics.printf( "SCORE", 0, 4, 224, "center" )
	love.graphics.printf( score, 0, 14, 224, "center" )
end

-- LÖVE functions ---------------------------------------------------------------------------------
function love.load()
	-- Global parameters
	love.graphics.setDefaultFilter( "nearest", "nearest" )
	-- Constants
	creditsPerCoin = { 1, 2, 3, 4, 5 }
	globalSpeed = { 1, 1.1, 1.2, 1.3, 1.4, 1.5 }
	extraLifeScheme = {
		{},
	}
	-- Global variables
	isPCVersion = false
	settings = loadSettings( "data" )
	volume = 1
	music = false
	gameIsComplete = { false, false, false }
	creditSound = love.audio.newSource( "sounds/sfx_coin_cluster3.wav" )
	credits = 0
	score = 0
	-- Graphic data
	initIsComplete = false
	sheets = {}
	loader.newImage( sheets, "trump", "graphics/sheet12.png" )
	--trumpAnim = newAnimation( sheets.trump, 32, 32, 0.07, 38, 0, 192, 128, 320, 1, 6 )
	-- Code import
	dbug = require( "dbug" )
	fonts = require( "fonts" )
	input = require( "input" )
	controls = require( "controls" )
	tweeter = require( "tweeter" )
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
	setup = require( "setup" )
	-- Init
	screen:set( 0, 2 ) -- Set to 90, 1 for cabinet build
	currentGame = game1
	phase = intro
	loader.start( function()
		initIsComplete = true
		trumpAnim = newAnimation( sheets.trump, 32, 32, 0.07, 38, 0, 192, 128, 320, 1, 6 )
	end )
end
function love.update( dt )
	if initIsComplete then
		dt = dt * globalSpeed[ settings[ 2 ] ] -- Global speed adjustment
		phase:update( dt )
	else
		loader:update( dt )
	end
end
function love.draw()
	love.graphics.setCanvas( screen.canvas )
	love.graphics.clear()
	phase:draw()
	love.graphics.setCanvas()
	if isPCVersion then love.graphics.setShader( screen.shader ) end
	love.graphics.draw( screen.canvas, 0, 0, screen.angle, screen.scale, screen.scale, screen.ox, screen.oy )
	if isPCVersion then love.graphics.setShader() end
	love.graphics.setFont( fonts.debug )
end
function love.keypressed( key )
	if key == "escape" then love.event.quit() end
	if key == input.reset then resetEverything( true ) end
	if key == input.setup and phase ~= seyup then setup:switch() end
	if key == input.coin then
		if creditSound:isPlaying() then creditSound:stop() end
		creditSound:play()
		credits = credits + creditsPerCoin[ settings[ 1 ] ]
	end
	if phase.keypressed then phase:keypressed( key ) end
	dbug:keypressed( key )
end
function love.keyreleased( key ) if phase.keyreleased then phase:keyreleased( key ) end end