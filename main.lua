--[[
Trumpcade. A pseudo retro game about Donald Trump.
]]
score = 0
loader = require( "libs.love-loader" )
require( "libs.arcade" )
require( "libs.animator" )
require( "libs.cheatCode" )
require( "libs.speechBubble" )
require( "libs.BGimage" )
local version = "0.3.8"
-- Common functions -------------------------------------------------------------------------------
function loadSettings( path )
	local settings
	if love.filesystem.exists( path ) then
		settings = {}
		for line in love.filesystem.lines( path ) do
			table.insert( settings, tonumber( line ) )
		end
	else
		settings = { 1, 1, 1, 2 } -- Credits per coin, global speed, extra life scheme, attract mode.
		local file, errorstr = love.filesystem.newFile( path, "w" )
		--file:write( tostring( settings[ 1 ] ).."\n"..tostring( settings[ 2 ] ).."\n"..tostring( settings[ 3 ] ) )
	end
	if #settings == 0 then
		settings = { 1, 1, 1, 2 }
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
	music:stop()
	--gameSecret:switch()
	switchTo( gameSecret, true )
end
function resetEverything( hard )
	score = 0
	gameIsComplete = { false, false, false }
	tweeter:reset()
	game1:reset()
	game2:reset()
	game3:reset()
	gameSecret:reset()
	if hard then
		--intro:switch()
		switchTo( intro )
	end
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
function switchTo( target, showTransition, param )
	if showTransition then
		transition.isActive = true
		transition:set( target, param )
	else
		target:switch( param )
	end
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
	initIsComplete = false
	-- Graphic data
	sheets = {}
	loader.newImage( sheets, "trump", "graphics/trump.png" )
	loader.newImage( sheets, "title", "graphics/title.png" )
	loader.newImage( sheets, "select", "graphics/select.png" )
	loader.newImage( sheets, "game2", "graphics/game2.png" )
	--loader.newImage( sheets, "game1", "graphics/game1.png" )
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
	loader.newSource( musics, "victory", "music/Victory.ogg", "static" )
	loader.newSource( musics, "anthem", "music/anthem.ogg", "stream" )
	--loader.newSource( musics, "select", "music/Do not move PSG.mp3", "stream" )
	loader.newSource( musics, "select", "music/Juhani Junkala [Chiptune Adventures] 4. Stage Select.ogg", "stream" )
	loader.newSource( musics, "whiteHouse", "music/Lunar.ogg", "stream" )
	loader.newSource( musics, "Texas", "music/Juhani Junkala [Chiptune Adventures] 1. Stage 1.ogg", "stream" )
	loader.newSource( musics, "New Mexico", "music/Juhani Junkala [Chiptune Adventures] 2. Stage 2.ogg", "stream" )
	loader.newSource( musics, "Arizona", "music/Juhani Junkala [Chiptune Adventures] 3. Boss Fight.ogg", "stream" )
	loader.newSource( musics, "California", "music/Juhani Junkala [Retro Game Music Pack] Level 1.ogg", "stream" )
	loader.newSource( musics, "Washington", "music/Juhani Junkala [Retro Game Music Pack] Level 2.ogg", "stream" )
	loader.newSource( musics, "result", "music/Action3 - Preparing For Battle.ogg", "stream" )
	loader.newSource( musics, "hiscore", "music/OveMelaa - Trance Bit Bit Loop.ogg", "stream" )
	-- Code import
	transition = require( "transition" )
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
	test = require( "test" )
	-- Init
	--screen:set( 90, 1, true ) -- Set to 90, 1, true for cabinet build
	screen:set( 0, 2 )
	love.mouse.setVisible( false )
	currentGame = intro
	phase = intro
	loader.start( function()
		initIsComplete = true
		-- Animations are created here once the image are loaded.
		trumpAnim = newAnimation( sheets.trump, 32, 32, 0.1, 48, 0, 0, 128, 384, 1, 4 )
		title.glitch.anim = newAnimation( sheets.title, 99, 16, 0.01, 6, 224, 320, 99, 95, 1, 6 )
		gameSelect.coin = newAnimation( sheets.select, 32, 32, 0.05, 6, 0, 160, 192, 32, 1, 6 )
		woman1Animation = newAnimation( sheets.game2, 32, 32, 0.1, 69, 128, 192, 128, 288, 1, 4 )
		woman2Animation = newAnimation( sheets.game2, 32, 32, 0.1, 69, 128, 192, 128, 288, 1, 4 )
		woman3Animation = newAnimation( sheets.game2, 32, 32, 0.1, 69, 128, 192, 128, 288, 1, 4 )
		woman4Animation = newAnimation( sheets.game2, 32, 32, 0.1, 69, 128, 192, 128, 288, 1, 4 )
		game2.coin = newAnimation( sheets.game2, 8, 10, 0.1, 8, 0, 512, 64, 10, 1, 8 )
	end )
end
function love.update( dt )
	if initIsComplete and not pause.isActive then
		if love.keyboard.isDown( "s" ) then
			dt = dt * 10
		else
			dt = dt * globalSpeed[ settings[ 2 ] ] -- Global speed adjustment
		end
		transition:update( dt, phase )
		if not transition.isActive and music then
			if not music:isPlaying() then
				music:play()
			end
		end
		phase:update( dt )
	else
		loader:update( dt )
	end
	--Temp debug to be removed later
	if love.keyboard.isDown( input.start ) and love.keyboard.isDown( input.up ) and phase ~= intro then
		setup:switch()
	elseif love.keyboard.isDown( input.start ) and love.keyboard.isDown( input.down ) and phase ~= intro then
		resetEverything( true )
	end
end
function love.draw()
	love.graphics.setCanvas( screen.canvas )
	love.graphics.clear()
	phase:draw()
	transition:draw( 0, 64, 252 )
	pause:draw()
	love.graphics.setCanvas()
	if isPCVersion then love.graphics.setShader( screen.shader ) end
	love.graphics.draw( screen.canvas, 0, 0, screen.angle, screen.scale, screen.scale, screen.ox, screen.oy )
	if isPCVersion then love.graphics.setShader() end
	love.graphics.setFont( fonts.debug )
	love.graphics.print( version )
end
function love.keypressed( key )
	if key == "p" then pause:set( { sounds, musics } ) end
	if key == "escape" then love.event.quit() end
	if key == input.reset then resetEverything( true ) end
	if key == input.setup and phase ~= setup then
		switchTo( setup )
	end
	if key == input.coin then
		if creditSound:isPlaying() then creditSound:stop() end
		creditSound:play()
		credits = credits + creditsPerCoin[ settings[ 1 ] ]
	end
	if phase.keypressed and not transition.isActive then phase:keypressed( key ) end
	--dbug:keypressed( key )
	if key == "h" then phase:complete() end
end
function love.keyreleased( key ) if phase.keyreleased then phase:keyreleased( key ) end end