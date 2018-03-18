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
function newEnemy( x, y, w, h, sw, sh, framesCount )
	local enemy = {}
	for i = 1, framesCount do
		table.insert( enemy, love.graphics.newQuad( x + ( i - 1 ) * w, y, w, h, sw, sh ) )
	end
	return enemy
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
	hostile_food = {},
	fire_trigger = 99,
	brickOnWall = 0,
	stage = 0,
	showGrid = false,
	mexicans = love.graphics.newImage( "graphics/mexicans.png" ),
	food = love.graphics.newImage( "graphics/foodtiles.png" ),
	hamburger = love.graphics.newQuad( 32, 0, 8, 8, 80, 41 ),
	lime = love.graphics.newQuad( 24, 56, 8, 8, sw, sh ),
	bullets = {
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
			love.graphics.newQuad( 0, 0, 16, 16, 128, 16 ),
			love.graphics.newQuad( 16, 0, 16, 16, 128, 16 ),
			love.graphics.newQuad( 32, 0, 16, 16, 128, 16 ),
			love.graphics.newQuad( 48, 0, 16, 16, 128, 16 ),
			love.graphics.newQuad( 64, 0, 16, 16, 128, 16 ),
			love.graphics.newQuad( 80, 0, 16, 16, 128, 16 ),
			love.graphics.newQuad( 96, 0, 16, 16, 128, 16 ),
		},
	},	
	fc = math.rad( 360 ),
	alpha = { value = 255, direction = -1 },
	run_trigger = 160,
}
local wall = {
	structure = {
		{ x =   0, blocks = { 1, 1, 1 } },
		{ x =  16, blocks = {} },
		{ x =  32, blocks = {} },
		{ x =  48, blocks = {} },
		{ x =  64, blocks = {} },
		{ x =  80, blocks = {} },
		{ x =  96, blocks = {} },
		{ x = 112, blocks = {} },
		{ x = 128, blocks = {} },
		{ x = 144, blocks = {} },
		{ x = 160, blocks = {} },
		{ x = 176, blocks = {} },
		{ x = 192, blocks = {} },
		{ x = 208, blocks = { 1, 1, 1 } },
	},
}
local player = require( "game1Data.player" )
local levels = {
	{ name = "Texas", speed = 10, bg = love.graphics.newImage( "graphics/game1_bg1.png" ), wave = { 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5 } },
	{ name = "New Mexico", speed = 12, bg = love.graphics.newImage( "graphics/game1_bg2.png" ), wave = { 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5 } },
	{ name = "Arizona", speed = 13, bg = love.graphics.newImage( "graphics/game1_bg3.png" ), wave = { 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5 } },
	{ name = "California", speed = 14, bg = love.graphics.newImage( "graphics/game1_bg4.png" ), wave = { 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5 } },
	{ name = "Washington", speed = 15, bg = love.graphics.newImage( "graphics/game1_bg5.png" ), wave = { 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5 } },
}
local enemies = {
	newEnemy(   0, 16, 16, 32, sw, sh, 2 ), -- Worker
	newEnemy(  32, 16, 16, 32, sw, sh, 2 ), -- Male luchador
	newEnemy(  64, 16, 16, 32, sw, sh, 2 ), -- Padre
	newEnemy(  96, 16, 16, 32, sw, sh, 2 ), -- Doctor
	newEnemy( 128, 16, 16, 32, sw, sh, 2 ), -- Muerte
	newEnemy( 144, 16, 16, 32, sw, sh, 2 ), -- Female luchador
	newEnemy( 160, 16, 16, 32, sw, sh, 2 ), -- Wheelchair
	--love.graphics.newQuad(   0, 16, 16, 32, sw, sh ),
	--love.graphics.newQuad(  32, 16, 16, 32, sw, sh ),
	--love.graphics.newQuad(  64, 16, 16, 32, sw, sh ),
	--love.graphics.newQuad(  96, 16, 16, 32, sw, sh ),
	--love.graphics.newQuad( 128, 16, 16, 32, sw, sh ),
}
local explosions = {
	data = {},
	frames = {
		love.graphics.newQuad(   0, 80, 32, 32, sw, sh ),
		love.graphics.newQuad(  32, 80, 32, 32, sw, sh ),
		love.graphics.newQuad(  64, 80, 32, 32, sw, sh ),
		love.graphics.newQuad(  96, 80, 32, 32, sw, sh ),
		love.graphics.newQuad( 128, 80, 32, 32, sw, sh ),
		love.graphics.newQuad( 160, 80, 32, 32, sw, sh ),
		love.graphics.newQuad( 192, 80, 32, 32, sw, sh ),
		love.graphics.newQuad( 224, 80, 32, 32, sw, sh ),
		love.graphics.newQuad( 256, 80, 32, 32, sw, sh ),
		love.graphics.newQuad( 288, 80, 32, 32, sw, sh ),
		love.graphics.newQuad( 320, 80, 32, 32, sw, sh ),
		love.graphics.newQuad( 352, 80, 32, 32, sw, sh ),
	}
}
local screams = {}
for i = 1, 19 do
	local scream = love.audio.newSource( "sounds/death"..tostring( i )..".ogg" )
	scream:setPitch( 1.5 )
	table.insert( screams, scream )
end
local smoke = {
	sound = love.audio.newSource( "sounds/impact.ogg" ),
	frames = {
		love.graphics.newQuad( 144, 0, 16, 16, sw, sh ),
		love.graphics.newQuad( 160, 0, 16, 16, sw, sh ),
		love.graphics.newQuad( 176, 0, 16, 16, sw, sh ),
		love.graphics.newQuad( 192, 0, 16, 16, sw, sh ),
		love.graphics.newQuad( 208, 0, 16, 16, sw, sh ),
		love.graphics.newQuad( 224, 0, 16, 16, sw, sh ),
		love.graphics.newQuad( 240, 0, 16, 16, sw, sh ),
		love.graphics.newQuad( 256, 0, 16, 16, sw, sh ),
	},
	data = {},
}
function smoke:add( x, y )
	table.insert( self.data, { x = x, y = y, timer = 0, index = 1 } )
	self.sound:play()
end
function smoke:update( dt )
	for index, entry in pairs( self.data ) do
		entry.y = entry.y - dt * 20
		entry.timer = entry.timer + dt
		if entry.timer > 0.05 then
			entry.timer = 0
			entry.index = entry.index + 1
			if entry.index > 8 then
				entry.index = 8
				table.remove( self.data, index )
			end
		end
	end
end
function smoke:draw( sheet )
	for _, entry in pairs( self.data ) do
		love.graphics.draw( sheet, self.frames[ entry.index ], entry.x, math.floor( entry.y ) )
	end
end
function explosions:add( x, y )
	table.insert( self.data, { x = x - 8, y = y - 8, timer = 0, index = 1 } )
end
function explosions:update( dt )
	for index, explosion in pairs( self.data ) do
		explosion.timer = explosion.timer + dt
		if explosion.timer > 0.05 then
			explosion.timer = 0
			explosion.index = explosion.index + 1
			if explosion.index > 12 then
				explosion.index = 12
				table.remove( self.data, index )
			end
		end
	end
end
function explosions:draw( sheet )
	for _, explosion in pairs( self.data ) do
		love.graphics.draw( sheet, self.frames[ explosion.index ], explosion.x, explosion.y )
	end
end
function explosions:reset()
	self.data = {}
end
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
function game:enemyShoot( x, y )
	table.insert( self.hostile_food, { x = x, y = y, w = 4, h = 4, id = 2, angle = 0, quad = self.bullets[ love.math.random( #self.bullets ) ] } )
end
function game:updateHostileFood( dt )
	for index, food in pairs( self.hostile_food ) do
		food.angle = food.angle + dt * 7
		if food.angle > math.rad( 360 ) then food.angle = food.angle - math.rad( 360 ) end
		food.y = food.y + dt * 60 * ( 1 + food.id / 6 )
		if food.y > 320 then
			table.remove( self.hostile_food, index )
		elseif food.y > 260 then
			for _, column in pairs( wall.structure ) do
				if CheckCollision( column.x, 290 - 12 * #column.blocks, 16, 12 * #column.blocks, food.x, food.y, food.w, food.h ) and #column.blocks > 0 then
					smoke:add( column.x, 285 - 12 * #column.blocks )
					column.blocks[ #column.blocks ] = column.blocks[ #column.blocks ] + 1
					if column.blocks[ #column.blocks ] > 5 then
						table.remove( column.blocks, #column.blocks )
					end
					table.remove( self.hostile_food, index )
				elseif CheckCollision( player.x - 8, player.y + 8, player.w, player.h, food.x, food.y, food.w, food.h ) then
					player.bullet = nil
					player.isAlive = false
					self.introIsActive = true
					sounds.trumpDeath:play()
					table.remove( self.hostile_food, index )
				end
			end
		end
	end
end
function game:drawHostileFood()
	for _, food in pairs( self.hostile_food ) do
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
	for _, enemy in pairs( self.wave ) do
		enemy.x = enemy.startx
		enemy.y = enemy.starty
	end
end
function game:updateEnemies( dt )
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
		if not enemy.coolDown then enemy.coolDown = enemy.coolDownTrigger end
		if enemy.isZoning then
			enemy.coolDown = enemy.coolDown - dt
			if enemy.coolDown < 0 then
				enemy.coolDown = enemy.coolDownTrigger
				if love.math.random( 100 ) > 95 and #self.hostile_food < 6 then
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
					end
				end
			end
		else
			enemy.y = enemy.y + dt * self.speed * 5
			if enemy.y > 320 then
				--table.remove( self.wave, index )
				self:removeEnemy( index )
			end
		end
	end
end
function game:drawEnemies()
	for _, enemy in pairs( self.wave ) do
		love.graphics.draw( self.sheet, self.enemyShadow, enemy.x, enemy.y, 0, 1, 1, 2, -20 )
		love.graphics.draw( self.sheet, enemies[ enemy.quad ][ self.animIndex ], enemy.x, enemy.y, 0, 1, 1, 4, 4 )
		--love.graphics.rectangle( "line", enemy.x, enemy.y, enemy.w, enemy.h )
		--love.graphics.print( enemy.block, enemy.x, enemy.y )
	end
end
function game:removeEnemy( index, boom )
	if boom then
		local enemy = self.wave[ index ]
		explosions:add( enemy.x, enemy.y )
		local sound = screams[ love.math.random( 19 ) ]
		if sound:isPlaying() then
			sound:stop()
		end
		sound:play()
	end
	self.speed = self.speed + 0.5
	table.remove( self.wave, index )
end

-- Global game functions
function game:update( dt )
	tweeter:update( dt )
	points:update( dt )
	explosions:update( dt )
	smoke:update( dt )
	self:updateGetZone( dt )
	-- Normal gameplay
	if self.introIsActive then
		self.timer = self.timer + dt
		if self.timer > 2 then
			self.timer = 0
			self.introIsActive = false
		end
	elseif ( #self.wave > 0 or self.brickOnWall == 36 ) and player.isAlive then
		self:updateHostileFood( dt )	
		if not tweeter.isActive then
			player:update( dt, self, points )
		end
		self:updateEnemies( dt )
		if #self.wave < 1 then
			--self.stage = self.stage + 1
			self.hostile_food = {}
			player.bullet = nil
			self:set()
		end
	elseif not player.isAlive then
		self.timer = self.timer + dt
		if self.timer > 2 then
			self.timer = 0
			self.hostile_food = {}
			player.lives = player.lives - 1
			if player.lives == 0 then
				switchTo( continue )
				--continue:switch()
			else
				self:resetEnemies()
				player:reset()
			end
		end
	else -- Level complete

	end
end
function game:draw()
	love.graphics.draw( self.bg, 0, 0 )
	self:drawEnemies()
	explosions:draw( self.sheet )
	self:drawHostileFood()
	wall:draw( 280, self.brick )
	smoke:draw( self.sheet )
	love.graphics.setFont( fonts.basic )
	self:drawGetZone( 0, 288)
	self:drawGetZone( 208, 288)
	points:draw( fonts.score )
	player:draw( self, points )
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
	if tweeter.isActive then
		if key == input.a or key == input.b or key == input.c then
			tweeter:type()
		end
	elseif player.isAlive and not self.introIsActive then
		if key == input.a then player:shoot() end
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

-- Modifier functions
function game:switch()
	player.anim = trumpAnim
	if music then music:stop() end
	currentGame = self
	phase = self
	self:set()
end
function game:set()
	self.animIndex = 1
	self.introIsActive = true
	love.graphics.setFont( fonts.dialog )
	self.stage = self.stage + 1
	if self.stage > 5 then
		self:complete()
	else
		player:set()
		self.speed = levels[ self.stage ].speed
		self.wave_x = 0
		self.wave_direction = 1
		self.wave = {}
		self.bg = levels[ self.stage ].bg
		local wave = levels[ self.stage ].wave
		local x, y = 16, 64
		for i = 1, #wave do
			table.insert( self.wave, { quad = wave[ i ], hp = 0, x = x, y = y, startx = x, starty = y, w = 10, h = 15, isZoning = true, block = 0, coolDownTrigger = love.math.random( 5 ) } )
			x = x + 16
			if i % 10 == 0 then
				x = 16
				y = y + 16
			end
		end
		wall.structure = {
			{ x =   0, blocks = { 1, 1, 1 } },
			{ x =  16, blocks = {} },
			{ x =  32, blocks = {} },
			{ x =  48, blocks = {} },
			{ x =  64, blocks = {} },
			{ x =  80, blocks = {} },
			{ x =  96, blocks = {} },
			{ x = 112, blocks = {} },
			{ x = 128, blocks = {} },
			{ x = 144, blocks = {} },
			{ x = 160, blocks = {} },
			{ x = 176, blocks = {} },
			{ x = 192, blocks = {} },
			{ x = 208, blocks = { 1, 1, 1 } },
		}
	end
end
function game:complete()
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
	self.hostile_food = {}
	self.fire_trigger = 999
	self.stage = 0
end
function game:goToNextLevel()

end
--player.anim:set( 7, 10, 0.11 )
--game:set() -- Temp for debug purpose when launching the game directly
return game