loader = require( "libs.love-loader" )
require( "libs.animator" )
require( "libs.cheatCode" )
require( "libs.speechBubble" )
require( "libs.BGimage" )

-- Common functions -------------------------------------------------------------------------------
function loadSettings( path )
	local settings
	if love.filesystem.exists( path ) then
		settings = {}
		for line in love.filesystem.lines( path ) do
			table.insert( settings, tonumber( line ) )
		end
	else
		settings = { 1, 1, 1, 1 } -- Credits per coin, global speed, extra life scheme, attract mode.
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
	initIsComplete = false
	-- Graphic data
	sheets = {}
	loader.newImage( sheets, "trump", "graphics/trump.png" )
	loader.newImage( sheets, "title", "graphics/title.png" )
	loader.newImage( sheets, "select", "graphics/select.png" )
	loader.newImage( sheets, "game2", "graphics/game2.png" )
	-- Sound data
	sounds = {}
	loader.newSource( sounds, "glitch", "sounds/glitch.ogg" )
	loader.newSource( sounds, "movePointer", "sounds/select_move.ogg" )
	loader.newSource( sounds, "validate", "sounds/select_validate.ogg" )
	loader.newSource( sounds, "pickupCoin", "sounds/coin.ogg" )
	loader.newSource( sounds, "pickupPower", "sounds/Powerup7.wav" )
	loader.newSource( sounds, "trumpDeath", "sounds/sfx_deathscream_human14.wav" )
	loader.newSource( sounds, "sayPussy", "sounds/pussy.ogg" )
	loader.newSource( sounds, "girlScream", "sounds/wscream_2.wav" )
	loader.newSource( sounds, "pickBrick", "sounds/pick_brick.wav" )
	loader.newSource( sounds, "putBrick", "sounds/put_brick.wav" )
	loader.newSource( sounds, "shootFood", "sounds/shoot_food.wav" )
	-- Music data
	musics = {}
	loader.newSource( musics, "anthem", "music/anthem.ogg", "stream" )
	loader.newSource( musics, "select", "music/Do not move PSG.mp3", "stream" )
	loader.newSource( musics, "whiteHouse", "music/Lunar.ogg", "stream" )
	-- Code import
	pause = require( "pause" )
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
		-- Animations are created here once the image are loaded.
		trumpAnim = newAnimation( sheets.trump, 32, 32, 0.1, 38, 0, 0, 128, 320, 1, 4 )
		title.glitch.anim = newAnimation( sheets.title, 99, 16, 0.01, 6, 224, 320, 198, 48, 1, 6 )
		gameSelect.coin = newAnimation( sheets.select, 32, 32, 0.05, 6, 0, 160, 192, 32, 1, 6 )
		game2.coin = newAnimation( sheets.game2, 8, 10, 0.1, 8, 0, 512, 64, 10, 1, 8 )
	end )
end
function love.update( dt )
	if initIsComplete and not pause.isActive then
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
	pause:draw()
	love.graphics.setCanvas()
	if isPCVersion then love.graphics.setShader( screen.shader ) end
	love.graphics.draw( screen.canvas, 0, 0, screen.angle, screen.scale, screen.scale, screen.ox, screen.oy )
	if isPCVersion then love.graphics.setShader() end
	love.graphics.setFont( fonts.debug )
end
function love.keypressed( key )
	if key == "p" then pause:set( { sounds, musics } ) end
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