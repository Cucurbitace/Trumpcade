-- The wall, AKA game 1
local bump = require( "bump" )
local world = bump.newWorld( 16 )
local game = {
	stage = 0,
	showGrid = false,
	mexicans = love.graphics.newImage( "graphics/mexicans.png" ),
	food = love.graphics.newImage( "graphics/foodtiles.png" ),
	hamburger = love.graphics.newQuad( 32, 0, 8, 8, 80, 41 ),
	trump = love.graphics.newImage( "graphics/Trump_walk_spritesheet.png" ),
	brick = love.graphics.newImage( "graphics/brick.png" ),
	fc = math.rad( 360 ),
	alpha = { value = 255, direction = -1 },
	run_trigger = 160,
}
local wall = {
	structure = {
		{ x =   0, blocks = 3 },
		{ x =  16, blocks = 0 },
		{ x =  32, blocks = 0 },
		{ x =  48, blocks = 0 },
		{ x =  64, blocks = 0 },
		{ x =  80, blocks = 0 },
		{ x =  96, blocks = 0 },
		{ x = 112, blocks = 0 },
		{ x = 128, blocks = 0 },
		{ x = 144, blocks = 0 },
		{ x = 160, blocks = 0 },
		{ x = 176, blocks = 0 },
		{ x = 192, blocks = 0 },
		{ x = 208, blocks = 3 },
	},
}
local player = {
	sounds = {
		pick_brick = love.audio.newSource( "sounds/pick_brick.wav" ),
		put_brick = love.audio.newSource( "sounds/put_brick.wav" ),
		shoot_food = love.audio.newSource( "sounds/shoot_food.wav" )
	},
	position = 1,
	hasBrick = false,
	canShoot = true,
	x = 100,
	y = 280,
	speed = 100,
	anim = newAnimation( game.trump, 32, 32, 0.1, 10 )
}
local levels = {
	{ name = "West Texas", speed = 10, bg = love.graphics.newImage( "graphics/texas1.png" ), wave = { 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5 } },
	{ name = "East Texas", speed = 12, bg = love.graphics.newImage( "graphics/texas2.png" ) },
	{ name = "New Mexico", speed = 13, bg = love.graphics.newImage( "graphics/new_mexico.png" ) },
	{ name = "Arizona", speed = 14 },
	{ name = "California", speed = 15 },
}
local enemies = {
	love.graphics.newQuad( 0, 0, 16, 16, 112, 32 ),
	love.graphics.newQuad( 16, 0, 16, 16, 112, 32 ),
	love.graphics.newQuad( 32, 0, 16, 16, 112, 32 ),
	love.graphics.newQuad( 48, 0, 16, 16, 112, 32 ),
	love.graphics.newQuad( 64, 0, 16, 16, 112, 32 ),
	love.graphics.newQuad( 80, 0, 16, 16, 112, 32 ),
	love.graphics.newQuad( 96, 0, 16, 16, 112, 32 ),
	love.graphics.newQuad( 0, 0, 16, 16, 112, 32 ),
	love.graphics.newQuad( 16, 16, 16, 16, 112, 32 ),
	love.graphics.newQuad( 32, 16, 16, 16, 112, 32 ),
	love.graphics.newQuad( 48, 16, 16, 16, 112, 32 ),
	love.graphics.newQuad( 64, 16, 16, 16, 112, 32 ),
	love.graphics.newQuad( 80, 16, 16, 16, 112, 32 ),
	love.graphics.newQuad( 96, 16, 16, 16, 112, 32 )
}
function wall:draw( y, brick )
	for _, element in pairs( self.structure ) do
		if element.blocks > 0 then
			local count = math.ceil( element.blocks )
			love.graphics.setColor( 255, 255, 255 )
			for i = 1, count do
				love.graphics.draw( brick, element.x, y - i * 8 )
			end
			love.graphics.setColor( 0, 0, 0, 64 )
			love.graphics.rectangle( "fill", element.x, y + 8, 16, count * 4 )
		end
	end
	love.graphics.setColor( 255, 255, 255 )
end
function player:set()
	love.graphics.setFont( fonts.dialog ) --Temp
	self.lives = 3
	self.score = 0
end
function player:move( dt, direction, first, last, pace )
	if self.anim.first ~= first then
		self.anim:set( first, last, pace )
	end
	self.direction = direction
	self.x = self.x + dt * self.speed * direction
	if self.x < 8 then
		self.x = 8
	elseif self.x > 216 then
		self.x = 216
	end
	self.isMoving = true
end
function player:pickBrick()
	if not self.hasBrick then
		self.hasBrick = true
		self.sounds.pick_brick:play()
	end
end
function player:putBrick()
	local section = wall.structure[ self.position ].blocks
	if self.hasBrick and section < 3 then
		wall.structure[ self.position ].blocks = section + 1
		self.hasBrick = false
		self.sounds.put_brick:play()
	end
end
function player:shoot()
	if self.canShoot and not self.hasBrick then
		self.canShoot = false
		self.bullet = { x = self.x, y = self.y, w = 8, h = 8, angle = 0 }
		self.sounds.shoot_food:play()
	end
end
function player:update( dt )
	-- Bullet
	if self.bullet then
		self.bullet.angle = self.bullet.angle + dt * 10
		if self.bullet.angle > game.fc then self.bullet.angle = self.bullet.angle - game.fc end
		self.bullet.y = self.bullet.y - dt * 150
		-- Check versus enemies
		for index, enemy in pairs( game.wave ) do
			if self.bullet.x > enemy.x and self.bullet.x + self.bullet.w < enemy.x + enemy.w and self.bullet.y > enemy.y and self.bullet.y + self.bullet.h < enemy.y + enemy.h then
				self.bullet = nil
				self.canShoot = true
				table.remove( game.wave, index )
			end
		end
		-- Remove bullet out of screen
		if self.bullet.y < -8 then
			self.bullet = nil
			self.canShoot = true
		end
	end
	-- Animation
	self.anim:update( dt )
	-- Movement
	if love.keyboard.isDown( input.left ) then
		self:move( dt, -1, 1, 6, 0.07 )
	elseif love.keyboard.isDown( input.right ) then
		self:move( dt, 1, 1, 6, 0.07 )
	else
		if self.anim.first ~= 7 then self.anim:set( 7, 10, 0.2 ) end
		self.isMoving = false
	end
	self.position = math.ceil( self.x / 16 )
end
function player:draw()
	if self.bullet then
		if self.bullet.y > 44 then
			love.graphics.setColor( 0, 0, 0, 64 )
			love.graphics.draw( game.food, game.hamburger, self.bullet.x, self.bullet.y + 6, self.bullet.angle, 1, 1, 4, 4 )
		end
		love.graphics.setColor( 255, 255, 255 )
		love.graphics.draw( game.food, game.hamburger, self.bullet.x, self.bullet.y, self.bullet.angle, 1, 1, 4, 4 )
	end
	self.anim:draw( math.floor( self.x ), math.floor( self.y ), 0, self.direction, 1, 16 )
	if self.hasBrick then love.graphics.draw( game.brick, self.x, self.y, 0, self.direction, 1, 8, -8 ) end	
end
function game:update( dt )
	self.alpha.value = self.alpha.value + dt * 700 * self.alpha.direction
	if self.alpha.value > 255 then
		self.alpha.value = 255
		self.alpha.direction = -1
	elseif self.alpha.value < 0 then
		self.alpha.value = 0
		self.alpha.direction = 1
	end
	player:update( dt )
	-- Enemies
	local dx = dt * self.speed * self.wave_direction
	local dy = 0
	local switch
	self.wave_x = self.wave_x + dx
	if self.wave_x > 40 then
		self.wave_x = 40
		self.wave_direction = -1
		dy = 8
		switch = true
	elseif self.wave_x < 0 then
		self.wave_x = 0
		self.wave_direction = 1 
		dy = 8
		switch = true
	end
	for index, enemy in pairs( self.wave ) do
		if enemy.isZoning then
			enemy.x = enemy.x + dx
			if switch then enemy.x = math.floor( enemy.x ) end
			enemy.y = enemy.y + dy
			local block = math.floor( enemy.x / 16 )
			local xl = block * 16
			local xr = block * 16 + 12
			if enemy.y > self.run_trigger then
				for _, element in pairs( wall.structure ) do
					if element.blocks == 0 and enemy.x > element.x and enemy.x < element.x + 12 then
						enemy.isZoning = false
					end
				end
			end
		else
			enemy.y = enemy.y + dt * self.speed * 5
		end
	end
end
function game:draw()
	love.graphics.draw( self.bg )
	wall:draw( 280, self.brick )
	for _, enemy in pairs( self.wave ) do
		--love.graphics.draw( self.mexicans, enemies[ enemy.quad ], enemy.x, enemy.y )
		love.graphics.rectangle( "line", enemy.x, enemy.y, enemy.w, enemy.h )
		love.graphics.print( enemy.block, enemy.x, enemy.y )
	end
	love.graphics.setColor( 0, 255, 255, self.alpha.value )
	love.graphics.rectangle( "fill", 0, 288, 16, 32 )
	love.graphics.rectangle( "fill", 208, 288, 16, 32 )
	love.graphics.setColor( 255, 255, 255 )
	love.graphics.printf( "G\nE\nT", 0, 290, 16, "center" )
	player:draw()
	love.graphics.setColor( 0, 255, 128, 160 )
	local x, y = 16, 16
	if self.showGrid then
		for i = 1, 13 do
			love.graphics.print( i+1, x, y )
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
	if key == "g" then self.showGrid = not self.showGrid end
	if key == input.a then player:shoot() end
	if key == input.b then
		if player.x < 16 or player.x > 208 then
			player:pickBrick()
		else
			player:putBrick()
		end
	end
end
function game:switch()
	phase = self
	self:set()
end
function game:set()
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
		for i = 1, #self.wave do
			table.insert( self.wave, { quad = wave[ i ], hp = 0, x = x, y  = y, w = 10, h = 15, isZoning = true, block = 0 } )
			x = x + 16
			if i % 10 == 0 then
				x = 16
				y = y + 16
			end
		end
	end
end
function game:complete()
	-- body
	-- Complete the game, cutscene, probably.
end
player.anim:set( 7, 10, 0.11 )
game:set() -- Temp for debug purpose
return game