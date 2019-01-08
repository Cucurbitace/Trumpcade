-- Move to main later
local points = { data = {} }
function points:update( dt )
	for index, point in pairs( self.data ) do
		point.alpha = point.alpha - dt * 400
		point.y = point.y - dt * 20
		if point.alpha < 0 then
			table.remove( self.data, index )
		end
	end
end
function points:draw( font )
	love.graphics.setFont( font )
	for _, point in pairs( self.data ) do
		love.graphics.setColor( 255, 255, 255, point.alpha )
		love.graphics.print( point.value, point.x, point.y )
	end
	love.graphics.setColor( 255, 255, 255 )
end
function points:reset()
	self.data = {}
end
function points:add( value, x, y )
	table.insert( self.data, { value = value, x = x, y = y, alpha = 255 } )
end
-- Border Invaders, AKA game 1
local sw, sh = 384, 112
local game = {
	animIndex = 1,
	animTimer = 0,
	enemyShadow = love.graphics.newQuad( 128, 0, 13, 5, sw, sh ),
	heart = love.graphics.newQuad( 80, 512, 8, 8, 256, 544 ),
	timer = 0,
	introIsActive = true,
	sheet = love.graphics.newImage( "graphics/game1.png" ),
	hostileFood = {},
	fire_trigger = 99,
	brickOnWall = 0,
	stage = 0,
	showGrid = false,
	enemyBullets = {
		love.graphics.newQuad( 24, 56, 8, 8, sw, sh ), -- Lime
		love.graphics.newQuad( 24, 64, 8, 8, sw, sh ), -- Lemon
		love.graphics.newQuad(  0, 56, 8, 8, sw, sh ), -- Orange
		love.graphics.newQuad( 40, 48, 8, 8, sw, sh ), -- Taco
		love.graphics.newQuad( 40, 64, 8, 8, sw, sh ), -- Papaya
	},
	trump = love.graphics.newImage( "graphics/Trump_walk_spritesheet.png" ),
	bricks = love.graphics.newImage( "graphics/bricks.png" ),
	brick = {
		frames = {
			love.graphics.newQuad(  0, 0, 16, 16, 128, 16 ),
			love.graphics.newQuad( 16, 0, 16, 16, 128, 16 ),
			love.graphics.newQuad( 32, 0, 16, 16, 128, 16 ),
			love.graphics.newQuad( 48, 0, 16, 16, 128, 16 ),
			love.graphics.newQuad( 64, 0, 16, 16, 128, 16 ),
			love.graphics.newQuad( 80, 0, 16, 16, 128, 16 ),
			love.graphics.newQuad( 96, 0, 16, 16, 128, 16 ),
		},
	},
	sombrero = {
		frames = {
			love.graphics.newQuad(  80, 64, 32, 16, sw, sh ),
			love.graphics.newQuad( 112, 64, 32, 16, sw, sh ),
			love.graphics.newQuad( 144, 64, 32, 16, sw, sh ),
			love.graphics.newQuad( 176, 64, 32, 16, sw, sh ),
		},
		timer = 0,
		index = 1,
		isAlive = false,
		x = 224,
		y = 48,
		w = 32,
		h = 10,
		delay = 14,
		value = 100,
	},
	fc = math.rad( 360 ),
	alpha = { value = 255, direction = -1 },
	run_trigger = 160,
}
local wall = {
	structure = {},
}
local flag = require( "game1Data.flag" )
local player = require( "game1Data.player" )
local levels = require( "game1Data.levels" )
local enemies = require( "game1Data.enemies" )
local explosions = require( "game1Data.explosions" )
local screams = {}
for i = 1, 19 do
	local scream = love.audio.newSource( "sounds/death"..tostring( i )..".ogg" )
	scream:setPitch( 1.5 )
	table.insert( screams, scream )
end
local smoke = require( "game1Data.smoke" )
local snow = require( "game1Data.snow" )
function wall:draw( y, brick )
	for _, element in pairs( self.structure ) do
		if #element.blocks > 0 then
			for index, block in pairs( element.blocks ) do
				love.graphics.setColor( 255, 255, 255 )
				love.graphics.draw( game.bricks, brick.frames[ block ], element.x, y - index * 8 )
			end
			--love.graphics.rectangle( "line", element.x, 290 - 12 * #element.blocks, 16, 12 * #element.blocks )
			love.graphics.setColor( 0, 0, 0, 64 )
			love.graphics.rectangle( "fill", element.x, y + 8, 16, #element.blocks * 4 )
		end
	end
	love.graphics.setColor( 255, 255, 255 )
end
function game.sombrero:reset( kill )
	if kill then
		explosions:add( self.x, self.y )
		explosions:add( self.x + 16, self.y )
	end
	self.isAlive = false
	self.x = 224
	self.delay = love.math.random( 10, 15 )
	self.value = 100
end
function game.sombrero:update( dt, speed )
	if self.isAlive then
		-- Animation
		self.timer = self.timer + dt
		if self.timer > 0.1 then
			self.timer = self.timer - 0.1
			self.index = self.index + 1
			if self.index > 4 then
				self.index = 1
			end
		end
		-- Movement
		self.x = self.x - dt * speed * 2
		if self.x < -32 then
			self:reset()
		end
	else
		self.delay = self.delay - dt
		if self.delay < 0 then
			self.delay = 0
			self.isAlive = true
		end
	end
end
function game.sombrero:draw( texture )
	if self.isAlive then
		love.graphics.draw( texture, self.frames[ self.index ], self.x, self.y )
	end
end
function game:enemyShoot( x, y )
	table.insert( self.hostileFood, { x = x, y = y, w = 4, h = 4, id = 2, angle = 0, quad = self.enemyBullets[ love.math.random( #self.enemyBullets ) ] } )
end
function game:updateHostileFood( dt )
	for index, food in pairs( self.hostileFood ) do
		food.angle = food.angle + dt * 7
		if food.angle > math.rad( 360 ) then food.angle = food.angle - math.rad( 360 ) end
		food.y = food.y + dt * 60 * ( 1 + food.id / 6 )
		if food.y > 320 then
			table.remove( self.hostileFood, index )
		elseif food.y > 260 then
			for _, column in pairs( wall.structure ) do
				if CheckCollision( column.x, 290 - 12 * #column.blocks, 16, 12 * #column.blocks, food.x, food.y, food.w, food.h ) and #column.blocks > 0 then
					smoke:add( column.x, 285 - 12 * #column.blocks )
					column.blocks[ #column.blocks ] = column.blocks[ #column.blocks ] + 1
					if column.blocks[ #column.blocks ] > 5 then
						table.remove( column.blocks, #column.blocks )
						self.brickOnWall = self.brickOnWall - 1
					end
					table.remove( self.hostileFood, index )
				elseif CheckCollision( player.x - 8, player.y + 8, player.w, player.h, food.x, food.y, food.w, food.h ) then
					player:kill( self )
					explosions:add( player.x - 8, player.y + 8 )
					table.remove( self.hostileFood, index )
				end
			end
		end
	end
end
function game:drawHostileFood()
	for _, food in pairs( self.hostileFood ) do
		love.graphics.setColor( 255, 255, 255 )
		love.graphics.draw( self.sheet, food.quad, food.x + 2, food.y + 2, food.angle, 1, 1, 4, 4 )
		love.graphics.setColor( 0, 0, 0, 64 )
		love.graphics.draw( self.sheet, food.quad, food.x + 2, food.y + 6, food.angle, 1, 1, 4, 4 )
		--love.graphics.rectangle( "line", food.x, food.y, food.w, food.h )
	end
end
function game:updateGetZone( dt )
	self.alpha.value = self.alpha.value + dt * 700 * self.alpha.direction
	if self.alpha.value > 255 then
		self.alpha.value = 255
		self.alpha.direction = -1
	elseif self.alpha.value < 0 then
		self.alpha.value = 0
		self.alpha.direction = 1
	end
end
function game:drawGetZone( x, y )
	love.graphics.setColor( 0, 255, 255, self.alpha.value )
	love.graphics.rectangle( "fill", x, y, 16, 32 )
	love.graphics.rectangle( "fill", x, y, 16, 32 )
	love.graphics.setColor( 255, 255, 255 )
	love.graphics.printf( "G\nE\nT", x, y + 2, 16, "center" )
end
function game:resetEnemies()
	for index, enemy in pairs( self.wave ) do
		enemy.x = enemy.startx
		enemy.y = enemy.starty
		enemy.isZoning = true
	end
end
function game:updateEnemies( dt )
	local loop = 1
	self.animTimer = self.animTimer + dt * self.speed
	if self.animTimer > 3 then
		self.animTimer = 0
		self.animIndex = self.animIndex + 1
		if self.animIndex > 2 then
			self.animIndex = 1
		end
	end
	local dx = dt * self.speed * self.wave_direction
	local dy = 0
	local switch
	-- Reverse wave direction
	for _, enemy in pairs( self.wave ) do
		if enemy.x > 200 then
			switch = true
			self.wave_direction = -1
			dy = 8
			break
		elseif enemy.x < 16 then
			self.wave_direction = 1
			switch = true
			dy = 8
			break
		end
	end
	-- Wave movement
	for index, enemy in pairs( self.wave ) do
		loop = loop + 1
		if not enemy.coolDown then enemy.coolDown = enemy.coolDownTrigger end
		if enemy.isZoning and not enemy.toBeRemoved then
			enemy.coolDown = enemy.coolDown - dt
			if enemy.coolDown < 0 then
				enemy.coolDown = enemy.coolDownTrigger
				if love.math.random( 100 ) > 95 and #self.hostileFood < 6 then
					self:enemyShoot( enemy.x, enemy.y )
				end
			end
			enemy.x = enemy.x + dx
			if switch then
				if self.wave_direction == -1 then
					enemy.x = math.floor( enemy.x )
				elseif self.wave_direction == 1 then
					enemy.x = math.ceil( enemy.x )
				end
			end
			enemy.y = enemy.y + dy
			local block = math.floor( enemy.x / 16 )
			local xl = block * 16
			local xr = block * 16 + 12
			if enemy.y > self.run_trigger then
				for _, element in pairs( wall.structure ) do
					if #element.blocks == 0 and enemy.x > element.x and enemy.x < element.x + 4 then
						enemy.isZoning = false
					elseif enemy.y > 256 then
						local x = math.floor( enemy.x / 16 ) * 16
						if element.x == x then
							table.remove( element.blocks, #element.blocks )
							self:removeEnemy( index, true )
							smoke:add( element.x, 285 - 12 * #element.blocks )
						end
					end
				end
			end
		else
			enemy.y = enemy.y + dt * self.speed * 4
			if enemy.y > 321 then
				self:removeEnemy( index )
				enemy.toBeRemoved = true
				if player.isAlive then
					explosions:add( player.x - 8, player.y + 8 )
					smoke:add( player.x + 8, player.y + 8 )
					player:kill( self )
					for index, runaway in pairs( self.wave ) do
						if runaway.y > 310 then
							runaway.toBeRemoved = true
						end
					end
				end
			elseif enemy.y > 256 then
				for _, element in pairs( wall.structure ) do
					local x = math.floor( enemy.x / 16 ) * 16
					if element.x == x and #element.blocks > 0 then
						table.remove( element.blocks, #element.blocks )
						self:removeEnemy( index, true )
						smoke:add( element.x, 285 - 12 * #element.blocks )
					end
				end
			end
		end
	end
	-- Wave clean
	for index, enemy in pairs( self.wave ) do
		if enemy.toBeRemoved then
			table.remove( self.wave, index )
		end
	end
end
function game:drawEnemies()
	for _, enemy in pairs( self.wave ) do
		love.graphics.draw( self.sheet, self.enemyShadow, enemy.x, enemy.y, 0, 1, 1, 2, -20 )
		love.graphics.draw( self.sheet, enemies[ enemy.quad ][ self.animIndex ], enemy.x, enemy.y, 0, 1, 1, 4, 4 )
		--love.graphics.print( enemy.y, 0, enemy.y )
		--love.graphics.rectangle( "line", enemy.x, enemy.y, enemy.w, enemy.h )
		--love.graphics.print( enemy.block, enemy.x, enemy.y )
	end
end
function game:removeEnemy( index, boom )
	if boom then
		local enemy = self.wave[ index ]
		enemy.toBeRemoved = true
		explosions:add( enemy.x, enemy.y )
		local sound = screams[ love.math.random( 19 ) ]
		if sound:isPlaying() then
			sound:stop()
		end
		sound:play()
	end
	self.speed = self.speed + 0.5
	
	--table.remove( self.wave, index )
end

-- Global game functions
function game:update( dt )
	if not music:isPlaying() and not transition.isActive then
		music:play()
	end
	tweeter:update( dt )
	points:update( dt )
	explosions:update( dt )
	smoke:update( dt )
	self:updateGetZone( dt )
	-- Normal gameplay
	if self.isSnowing then
		snow:update( dt )
	end
	if self.introIsActive then
		self.timer = self.timer + dt
		if self.timer > 2 then
			self.timer = 0
			self.introIsActive = false
		end
	elseif self.isComplete then
		self.timer = self.timer + dt
		if self.timer > 10 then
			self.timer = 0
			self.isComplete = false
			self.complete()
		end
	elseif self.outroIsActive then
		self.timer = self.timer + dt
		if self.timer > 4 then
			self.timer = 0
			self.outroIsActive = false
			self.hostileFood = {}
			player:reset()
			self:set()
		end
	elseif ( #self.wave > 0 or self.brickOnWall == 36 or self.sombrero.isAlive ) and player.isAlive then
		self.sombrero:update( dt, self.speed )
		self:updateHostileFood( dt )	
		if not tweeter.isActive then
			player:update( dt, self, points )
		end
		self:updateEnemies( dt )
		if #self.wave < 1 and not self.sombrero.isAlive then
			player.anim:set( 44, 48, 0.1 )
			player:update( dt, self, points )
			if player.anim.index == 48 then
				player.anim:set( 1, 4, 0.2 )
			end
			self.outroIsActive = true
			music:stop()
			music = musics.victory
		end
	elseif not player.isAlive then
		self.timer = self.timer + dt
		if self.timer > 1 then
			self.timer = 0
			self.introIsActive = true
			player.anim:set( 1, 4, 0.2 )
			self.hostileFood = {}
			player.lives = player.lives - 1
			self:resetEnemies()
			player:reset()
			if player.lives == 0 then
				music:stop()
				switchTo( continue, true )
				--continue:switch()
			end
		end
	end
end
function game:draw()
	if self.isComplete then
		love.graphics.setFont( fonts.basic )
		love.graphics.printf( "THE DIRTY MEXICANS WON'T PAY FOR THE WALL!\n\nAND NOW THE DEMOCRATS ARE FORCING THE BEST PRESIDENT EVER TO SHUTDOWN!", 10, 50, 204, "center" )
	else
		love.graphics.draw( self.bg, 0, 0 )
		self.sombrero:draw( self.sheet )
		self:drawEnemies()
		self:drawHostileFood()
		wall:draw( 280, self.brick )
		smoke:draw( self.sheet )
		love.graphics.setFont( fonts.basic )
		self:drawGetZone( 0, 288)
		self:drawGetZone( 208, 288)
		player:draw( self, points )
		explosions:draw( self.sheet )
		points:draw( fonts.score )
		printScore( score, fonts.basic )
		love.graphics.setColor( 255, 255, 0 )
		if self.introIsActive then
			love.graphics.printf( levels[ self.stage].name.."\nGet ready!", 0, 155, 224, "center" )
		end
		tweeter:draw( player, fonts.tweeter, fonts.tiny )
		-- Debug
		love.graphics.setColor( 255, 255, 255 )
		if player.lives < 5 then
			for i = 1, player.lives do
				love.graphics.draw( sheets.game2, self.heart, i * 9 - 5, 4 )
			end
		else
			love.graphics.draw( sheets.game2, self.heart, 4, 4 )
			love.graphics.setColor( 255, 255, 255 )
			love.graphics.print( "x"..player.lives, 13, 4 )
		end
		if self.isSnowing then
			snow:draw()
		end
	end
	--debug
	love.graphics.setColor( 0, 255, 128, 160 )
	local x, y = 16, 16
	if self.showGrid then
		for i = 1, 13 do
			love.graphics.print( i + 1, x, y )
			love.graphics.line( x, 0, x, 320 )
			x = x + 16
		end
		for i = 1, 19 do
			love.graphics.line( 0, y, 224, y )
			y = y + 16
		end
	end
	love.graphics.setColor( 255, 255, 255 )
end
function game:keypressed( key )
	--if key == "g" then self.showGrid = not self.showGrid end
	if player.isAlive and not self.introIsActive then
		
		if tweeter.isActive then
			if key == input.a or key == input.b or key == input.c then
				tweeter:type()
			end
		else
			if key == input.a then player:shoot( self ) end
			if key == input.b then
				if player.x < 16 or player.x > 208 then
					player:pickBrick( self )
				else
					player:putBrick( self, wall, points )
				end
			end
			if key == input.c then
				tweeter:type( player.x, player.y )
			end
		end
	end
end

-- Modifier functions
function game:switch()
	player.anim = trumpAnim
	if music then music:stop() end
	currentGame = self
	phase = self
	self:set()
	player:set()
end
function game:set()
	self.sombrero:reset()
	self.animIndex = 1
	self.introIsActive = true
	love.graphics.setFont( fonts.dialog )
	self.stage = self.stage + 1
	if self.stage > 5 then
		self.isComplete = true
		music = musics.result
		--self:complete()
	else
		self.isComplete = false
		local level = levels[ self.stage ]
		if music then
			music:stop()
		end
		music = musics[ level.name ]
		music:setVolume( 0.5 )
		if level.snow then
			self.isSnowing = true
		else
			self.isSnowing = false
		end
		self.brickOnWall = level.brickOnWall
		self.speed = level.speed
		self.wave_x = 0
		self.wave_direction = 1
		self.wave = {}
		self.bg = level.bg
		wall.structure = level.structure
		local wave = level.wave
		local x, y = 16, 64
		for i = 1, #wave do
			table.insert( self.wave, { id = i, quad = wave[ i ], hp = 0, x = x, y = y, startx = x, starty = y, w = 10, h = 15, isZoning = true, block = 0, coolDownTrigger = love.math.random( 5 ) } )
			x = x + 16
			if i % 10 == 0 then
				x = 16
				y = y + 16
			end
		end
	end
end
function game:complete()
	music:stop()
	gameIsComplete[ 1 ] = true
	if gameIsComplete[ 1 ] and gameIsComplete[ 2 ] and gameIsComplete[ 3 ] then
		switchTo( staff )
		--staff:switch()
	else
		gameSelect:setPointer()
		switchTo( gameSelect )
		--gameSelect:switch()
	end
	-- Complete the game, cutscene, probably.
end
function game:continue()
	phase = self
	player.lives = 3
end
function game:reset()
	self.hostileFood = {}
	self.fire_trigger = 999
	self.stage = 0
end
function game:goToNextLevel()

end
--player.anim:set( 7, 10, 0.11 )
--game:set() -- Temp for debug purpose when launching the game directly
return game