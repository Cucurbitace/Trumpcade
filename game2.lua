require( "game2Data.player" )
function CheckCollision( x1, y1, w1, h1, x2, y2, w2, h2 )
  return x1 < x2+w2 and
         x2 < x1+w1 and
         y1 < y2+h2 and
         y2 < y1+h1
end
function scareEnemies( enemies )
	for _, enemy in pairs( enemies ) do
		enemy.movingMode = "scared"
		if enemy.nextMove == 1 then
			enemy.nextMove = 2
			enemy.prohibitedMove = 1
		elseif enemy.nextMove == 2 then
			enemy.nextMove = 1
			enemy.prohibitedMove = 2
		elseif enemy.nextMove == 3 then
			enemy.nextMove = 4
			enemy.prohibitedMove = 3
		elseif enemy.nextMove == 4 then
			enemy.nextMove = 3
			enemy.prohibitedMove = 4
		end
	end
end
function setEnemiesMovingMode( enemies, mode )
	for _, enemy in pairs( enemies ) do
		enemy.movingMode = mode
	end
end
local function newLevel( game, map, size, sheet )
	local level = { blocks = {}, points = {}, background = love.graphics.newSpriteBatch( game.sheet, 930, "static" ), count = 0 }
	local function isSpecial( index )
		if index > 420 and index < 428 then
			return true
		elseif index > 340 and index < 351 then
			return true
		elseif index > 443 and index < 454 then
			return true
		elseif index > 520 and index < 531 then
			return true
		elseif index == 211 or index == 371 or index == 375 or index == 376 or index == 401 or index == 405 or index == 406 or index == 431 or index == 435 or index == 436 or index == 461 or index == 491 or index == 380 or index == 410 or index == 440 or index == 470 or index == 500 or index == 705 or index == 706 then
			return true
		end
	end
	local x, y = -game.size, 0
	-- Create the level from the map
	for i, v in pairs( game.maps[ game.currentLevel ] ) do
		block = { index = i, x = x, y = y }
		if v > 18 then
			block.isPath = true
			block.playerTrace = 0
			if x > -game.size and x < 28 * game.size and v ~= 0 then
				local t = v
				if v == 23 or v == 29 then
					if love.math.random( 10 ) > 9 then
						if v == 23 then
							t = 31
						elseif t == 29 then
							t = 32
						end
					end
				end
				level.background:add( game.tiles[ t ], x, y )
			end
			-- Ghost markers
			if v == 20 then
				block.directions = { 1, 4 }
			elseif v == 21 then
				block.directions = { 2, 4 }
			elseif v == 22 then
				block.directions = { 1, 2, 3 }
			elseif v == 24 or v == 36 then
				block.directions = { 2, 3, 4 }
			elseif v == 25 then
				block.directions = { 2, 3 }
			elseif v == 26 then
				block.directions = { 1, 2, 4 }
			elseif v == 27 then
				block.directions = { 1, 2, 3, 4 }
			elseif v == 28 then
				block.directions = { 1, 3 }
			elseif v == 30 then
				block.directions = { 1, 3, 4 }
			end
			-- Special blocks without coins
			if not isSpecial( i ) then
				level.count = level.count + 1
				if i == 93 or i == 118 or i == 813 or i == 838 then
					block.hasPower = true
				elseif v < 36 then
					block.hasBonus = true
				end
			end
		elseif v < 18 then
			block.isWall = true
			if x > -game.size and x < 28 * game.size then level.background:add( game.tiles[ v ], x, y ) end
			if love.math.random( 100 ) > 90 and v > 7 and v < 10 then
				block.fancy = love.math.random( 3 )
			end
		end
		table.insert( level.blocks, block )
		 x = x + game.size
		if i % 30 == 0 then
			x = -game.size
			y = y + game.size
		end
	end
	-- Map functions
	function level:reset()
		for _, block in pairs( self.blocks ) do
			if block.playerTrace then block.playerTrace = 0 end
		end
	end
	function level:update( dt )
		for index, point in pairs( self.points ) do
				point.alpha = point.alpha - dt * 400
				point.y = point.y - dt * 20
				if point.alpha < 0 then
					table.remove( self.points, index )
				end
			end
		for _, block in pairs( self.blocks ) do
			if block.isPath then
				if block.playerTrace > 0 then
					block.playerTrace = block.playerTrace - dt
				elseif block.playerTrace < 0 then
					block.playerTrace = 0
				end
			end
		end
	end
	function level:draw()
		love.graphics.setColor( 255, 255, 255 )
		love.graphics.draw( self.background )
		for _, block in pairs( self.blocks ) do
			love.graphics.setColor( 255, 255, 255 )
			if block.fancy then
				love.graphics.draw( game.sheet, game.decorations[ block.fancy ], block.x, block.y + 2 )
			end
			if block.hasBonus then
				love.graphics.draw( game.sheet, game.coin[ game.coinIndex ], block.x, block.y, 0, 1, 1, -4, -4 )
			elseif block.hasPower then
				love.graphics.draw( game.sheet, game.viagra, block.x, block.y )
			end
			love.graphics.setFont( fonts.score )
			for _, point in pairs( self.points ) do
				love.graphics.setColor( 255, 255, 255, point.alpha )
				love.graphics.print( point.value, point.x, point.y )
			end
			-- Debug related
			--love.graphics.setFont( fonts.tiny )
			--love.graphics.setColor( 0, 0, 0 )
			--if block.playerTrace then love.graphics.print( math.floor( block.playerTrace ), block.x, block.y ) end
		end
	end
	return level
end
local gamera = require( "libs.gamera" )
local howToPlay = require( "game2Data.howToPlay" )
local game = {
	outroTimer = 0,
	coolDown = 0,
	globalTime = 0,
	pickupCoin = love.audio.newSource( "sounds/coin.ogg" ),
	pickupPower = love.audio.newSource( "sounds/Powerup7.wav" ),
	music = love.audio.newSource( "music/Lunar.ogg", "stream" ),
	intro = { isActive = true, timer = 0 },
	currentLevel = 1,
	cam = gamera.new( 0, 0, 448, 496 ),
	coinIndex = 1,
	coinTimer = 0,
	size = 16,
	sheet = love.graphics.newImage( "graphics/sheet12.png" ),
	tiles = {},
	coin = {},
	maps = {
		{
			00, 13,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8, 14, 13,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8, 14, 00,
			00,  6, 21, 23, 23, 23, 23, 24, 23, 23, 23, 23, 23, 25,  4,  6, 21, 23, 23, 23, 23, 23, 24, 23, 23, 23, 23, 25,  4, 00,
			00,  6, 29,  1,  2,  2,  3, 29,  1,  2,  2,  2,  3, 29,  4,  6, 29,  1,  2,  2,  2,  3, 29,  1,  2,  2,  3, 29,  4, 00,
			00,  6, 29,  4,  5,  5,  6, 29,  4,  5,  5,  5,  6, 29,  4,  6, 29,  4,  5,  5,  5,  6, 29,  4,  5,  5,  6, 29,  4, 00,
			00,  6, 29,  7,  8,  8,  9, 29,  7,  8,  8,  8,  9, 29,  7,  9, 29,  7,  8,  8,  8,  9, 29,  7,  8,  8,  9, 29,  4, 00,
			00,  6, 26, 23, 23, 23, 23, 27, 23, 23, 24, 23, 23, 30, 23, 23, 30, 23, 23, 24, 23, 23, 27, 23, 23, 23, 23, 22,  4, 00,
			00,  6, 29,  1,  2,  2,  3, 29,  1,  3, 29,  1,  2,  2,  2,  2,  2,  2,  3, 29,  1,  3, 29,  1,  2,  2,  3, 29,  4, 00,
			00,  6, 29,  7,  8,  8,  9, 29,  4,  6, 29,  7,  8,  8, 14, 13,  8,  8,  9, 29,  4,  6, 29,  7,  8,  8,  9, 29,  4, 00,
			00,  6, 20, 23, 23, 23, 23, 22,  4,  6, 20, 23, 23, 25,  4,  6, 21, 23, 23, 28,  4,  6, 26, 23, 23, 23, 23, 28,  4, 00,
			00, 16,  2,  2,  2,  2,  3, 29,  4, 16,  2,  2,  3, 29,  4,  6, 29,  1,  2,  2, 17,  6, 29,  1,  2,  2,  2,  2, 17, 00,
			00,  5,  5,  5,  5,  5,  6, 29,  4, 13,  8,  8,  9, 29,  7,  9, 29,  7,  8,  8, 14,  6, 29,  4,  5,  5,  5,  5,  5, 00,
			00,  5,  5,  5,  5,  5,  6, 29,  4,  6, 21, 23, 23, 30, 23, 23, 30, 23, 23, 25,  4,  6, 29,  4,  5,  5,  5,  5,  5, 00,
			00,  5,  5,  5,  5,  5,  6, 29,  4,  6, 29,  1,  2,  3, 15, 15,  1,  2,  3, 29,  4,  6, 29,  4,  5,  5,  5,  5,  5, 00,
			00,  8,  8,  8,  8,  8,  9, 29,  7,  9, 29,  4, 13,  9, 15, 15,  7, 14,  6, 29,  7,  9, 29,  7,  8,  8,  8,  8,  8, 00,
			23, 23, 23, 23, 23, 23, 23, 27, 23, 23, 22,  4,  6, 15, 15, 15, 15,  4,  6, 26, 23, 23, 27, 23, 23, 23, 23, 23, 23, 23,
			00,  2,  2,  2,  2,  2,  3, 29,  1,  3, 29,  4, 16,  2,  2,  2,  2, 17,  6, 29,  1,  3, 29,  1,  2,  2,  2,  2,  2, 00,
			00,  5,  5,  5,  5,  5,  6, 29,  4,  6, 29,  7,  8,  8,  8,  8,  8,  8,  9, 29,  4,  6, 29,  4,  5,  5,  5,  5,  5, 00,
			00,  5,  5,  5,  5,  5,  6, 29,  4,  6, 26, 23, 23, 23, 23, 23, 23, 23, 23, 22,  4,  6, 29,  4,  5,  5,  5,  5,  5, 00,
			00,  5,  5,  5,  5,  5,  6, 29,  4,  6, 29,  1,  2,  2,  2,  2,  2,  2,  3, 29,  4,  6, 29,  4,  5,  5,  5,  5,  5, 00,
			00, 13,  8,  8,  8,  8,  9, 29,  7,  9, 29,  7,  8,  8, 14, 13,  8,  8,  9, 29,  7,  9, 29,  7,  8,  8,  8,  8, 14, 00,
			00,  6, 21, 23, 23, 23, 23, 27, 23, 23, 30, 23, 23, 25,  4,  6, 21, 23, 23, 30, 23, 23, 27, 23, 23, 23, 23, 25,  4, 00,
			00,  6, 29,  1,  2,  2,  3, 29,  1,  2,  2,  2,  3, 29,  4,  6, 29,  1,  2,  2,  2,  3, 29,  1,  2,  2,  3, 29,  4, 00,
			00,  6, 29,  7,  8, 14,  6, 29,  7,  8,  8,  8,  9, 29,  7,  9, 29,  7,  8,  8,  8,  9, 29,  4, 13,  8,  9, 29,  4, 00,
			00,  6, 20, 23, 25,  4,  6, 26, 23, 23, 24, 23, 23, 30, 23, 23, 30, 23, 23, 24, 23, 23, 22,  4,  6, 21, 23, 28,  4, 00,
			00, 16,  2,  3, 29,  4,  6, 29,  1,  3, 29,  1,  2,  2,  2,  2,  2,  2,  3, 29,  1,  3, 29,  4,  6, 29,  1,  2, 17, 00,
			00, 13,  8,  9, 29,  7,  9, 29,  4,  6, 29,  7,  8,  8, 14, 13,  8,  8,  9, 29,  4,  6, 29,  7,  9, 29,  7,  8, 14, 00,
			00,  6, 21, 23, 30, 23, 23, 28,  4,  6, 20, 23, 23, 25,  4,  6, 21, 23, 23, 28,  4,  6, 20, 23, 23, 30, 23, 25,  4, 00,
			00,  6, 29,  1,  2,  2,  2,  2, 17, 16,  2,  2,  3, 29,  4,  6, 29,  1,  2,  2, 17, 16,  2,  2,  2,  2,  3, 29,  4, 00,
			00,  6, 29,  7,  8,  8,  8,  8,  8,  8,  8,  8,  9, 29,  7,  9, 29,  7,  8,  8,  8,  8,  8,  8,  8,  8,  9, 29,  4, 00,
			00,  6, 20, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 30, 23, 23, 30, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 28,  4, 00,
			00, 16,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2, 17, 00
		},
	},
}
local sw, sh = game.sheet:getDimensions()
game.heart = love.graphics.newQuad( 80, 512, 8, 8, sw, sh )
game.viagra = love.graphics.newQuad( 64, 512, 16, 16, sw, sh )
for i = 1, 8 do
	table.insert( game.coin, love.graphics.newQuad( i * 8 - 8, 512, 8, 10, sw, sh ) )
end
local x, y = 0, 0
for i = 1, 42 do
	local tile = love.graphics.newQuad( x, y, game.size, game.size, sw, sh )
	table.insert( game.tiles, tile )
	x = x + game.size
	if i % 3 == 0 then
		x = 0
		y = y + game.size
	end
end
game.decorations = {
	love.graphics.newQuad( 0, 48, 16, 16, sw, sh ),
	love.graphics.newQuad( 16, 48, 16, 16, sw, sh ),
	love.graphics.newQuad( 32, 48, 16, 16, sw, sh ),
}
game.cam:setWindow( 0, 16, 224, 336  )
game.level = newLevel( game, game.maps[ 1 ], game.size, game.sheet )


game.enemies = {
	newCharacter( game, 1, sw, sh, 128, 192, 224, 240, 40, 35, 434, 60, { frCount = 34, rFirst = 9, rLast = 12, lFirst = 5, lLast = 8, uFirst = 13, uLast = 16, dFirst = 1, dLast = 4 }, "sounds/wscream_2.wav", 93, 21, 7 ) -- 93 or 118 or 813 or 838 for patrolBlock	
}

local player = newCharacter( game, 0, sw, sh, 0, 192, 240, 384, 40, 32, 705, 75, { frCount = 34, rFirst = 5, rLast = 10, lFirst = 11, lLast = 16, uFirst = 29, uLast = 34, dFirst = 17, dLast = 22 }, "sounds/sfx_deathscream_human14.wav" )
player.sayPussy = love.audio.newSource( "sounds/pussy.ogg" )

function game:complete()
	gameIsComplete[ 2 ] = true
	if gameIsComplete[ 1 ] and gameIsComplete[ 2 ] and gameIsComplete[ 3 ] then
		staff:switch()
	else
		gameSelect:setPointer()
		gameSelect:switch()
	end
end
function game:update( dt )
	if howToPlay.isActive then
		howToPlay:update( dt )
	else
		tweeter:update( dt )
		self.level:update( dt )
		self.globalTime = self.globalTime + dt
		if music:isStopped() then music:play() end
		if self.isOutro then
			self.outroTimer = self.outroTimer + dt
			if self.outroTimer > 10 then
				self.outroTimer = 0
				self:complete()
			end
		elseif self.level.count == 0 then
			self.currentLevel = self.currentLevel + 1
			if self.currentLevel > #self.maps then
				self.isOutro = true
			else
				self.level = newLevel( self.maps[ currentLevel ], self.size, self.sheet )
				player:reset()
				self.intro.isActive = true
			end
		else
			if self.intro.isActive then
				self.intro.timer = self.intro.timer + dt
				if self.intro.timer > 2 then
					self.intro.timer = 0
					self.intro.isActive = false
				end
			elseif player.isAlive then
				if not tweeter.isActive then
					player:update( dt )
				end
				-- Collisions
				for _, enemy in pairs( self.enemies ) do
					enemy:update( dt )
					if CheckCollision( enemy.x + 12, enemy.y + 12, 8, 8, player.x + 12, player.y + 12, 8, 8 ) and enemy.isAlive then
						if player.power > 0 then
							enemy.alpha = 100
							enemy.isAlive = false
							player.sayPussy:play()
							enemy.scream:play()
						else
							player.scream:play()
							player.isAlive = false
							player:setAnimation( 23, 28, 0.35 )
							self.coolDown = 1.5
						end
					end
				end
				self.coinTimer = self.coinTimer + dt
				if self.coinTimer > 0.1 then
					self.coinTimer = 0
					self.coinIndex = self.coinIndex + 1
					if self.coinIndex > 8 then self.coinIndex = 1 end
				end
				self.cam:setPosition( player.x - 16, player.y - 16 )
			else
				player:updateAnim( dt )
				self.coolDown = self.coolDown - dt
				if self.coolDown < 0 then
					tweeter:remove()
					tweeter.isActive = false
					self.level:reset()
					self.coolDown = 0
					player:reset()
					player.lives = player.lives - 1
					if player.lives == 0 then
						continue:switch()
					end
					for _, enemy in pairs( self.enemies ) do
						enemy:reset()
					end
					self.intro.isActive = true
					self.cam:setPosition( player.x - 16, player.y - 16 )
				end
			end
		end
	end
end

function game:draw()
	if howToPlay.isActive then
		howToPlay:draw( fonts.basic )
	elseif self.isOutro then
		love.graphics.printf( "Outro screen, to be replaced with artwork and so on.", 10, 10, 204, "center" )
	else
		self.cam:draw( function( l, t, w, h )
	  	-- draw camera stuff here
			love.graphics.setColor( 255, 255, 255 )
			self.level:draw()
			if not self.isOver then
				for _, enemy in pairs( self.enemies ) do
					enemy:draw( self.sheet )
				end
				player:draw( self.sheet )
			end
		end )
		love.graphics.setFont( fonts.basic )
		love.graphics.setColor( 255 - player.stamina * 4, player.stamina * 4, 0, 192 )
		love.graphics.rectangle( "fill", 154, 13, player.stamina, 8 )
		love.graphics.setColor( 255, 255, 255 )
		love.graphics.print( "STAMINA", 160, 4 )
		-- HUD
		if player.lives < 5 then
			for i = 1, player.lives do
				love.graphics.draw( self.sheet, self.heart, i * 9 - 5, 4 )
			end
		else
			love.graphics.draw( self.sheet, self.heart, 4, 4 )
			love.graphics.setColor( 255, 255, 255 )
			love.graphics.print( "x"..player.lives, 13, 4 )
		end
		tweeter:draw( player, fonts.tweeter, fonts.tiny )
		if self.intro.isActive then
			love.graphics.setColor( 255, 255, 0 )
			love.graphics.printf( "Level "..self.currentLevel, 0, 118, 224, "center" )
			if self.intro.timer < 1 then
				love.graphics.setColor( 255, 255, 0 )
				love.graphics.printf( "There's pussy around", 0, 100, 224, "center" )
			elseif self.intro.timer > 1 then
				love.graphics.setColor( 255, 255, 0 )
				love.graphics.printf( "Get ready", 0, 100, 224, "center" )
			end
		end
		printScore( score, fonts.basic )
	end
end

function game:keypressed( key )
	if key == "k" then
		player.lives = 1
		player.isAlive = false
	end
	if self.isOutro then
		if key == input.a or key == input.b or key == input.c then
			self.outroTimer = 0
			title:switch()
		end
	end
	if tweeter.isActive then
		if key == input.a or key == input.b or key == input.c then
			tweeter:type()
		end
	elseif not self.intro.isActive then
		if key == input.a then player.isRunning = true end
		if key == input.c then
			tweeter:type( self.cam:toScreen( player.x, player.y ) )
		end
		if key == input.up then
			player.nextMove = 1
		elseif key == input.down then
			player.nextMove = 2
		elseif key == input.left then
			player.nextMove = 3
		elseif key == input.right then
			player.nextMove = 4
		end
	end
end

function game:keyreleased( key )
	if key == input.a then
		player.isRunning = false
	end
end

function game:continue()
	phase = self
	player.lives = 3
end
function game:switch()
	self.isOutro = false
	currentGame = self
	phase = self
	if music then music:stop() end
	music = self.music
	player:reset()
end
function game:reset()
	player:reset()
	self.currentLevel = 1
end
game.cam:setPosition( player.x - 16, player.y - 16 )

return game