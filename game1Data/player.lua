local sw, sh = 384, 112
local player = {
	isAlive = true,
	position = 1,
	hasBrick = false,
	canShoot = true,
	x = 100,
	y = 280,
	w = 16,
	h = 16,
	speed = 100,
	food = {
		love.graphics.newQuad( 32, 48, 8, 8, sw, sh ), -- Hamburger
		love.graphics.newQuad( 64, 64, 8, 8, sw, sh ), -- Pizza
		love.graphics.newQuad( 40, 72, 8, 8, sw, sh ), -- Fries
	},
}
function player:set()
	self.lives = 3
end
function player:kill( game )
	tweeter:kill()
	self.anim:set( 43, 43, 1 )
	self.hasBrick = false
	self.bullet = nil
	self.isAlive = false
	game.sombrero:reset()
	--game.introIsActive = true
	sounds.trumpDeath:play()
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
function player:pickBrick( game )
	if not self.hasBrick and game.brickOnWall < 36 then
		self.hasBrick = true
		sounds.pickBrick:play()
	end
end
function player:putBrick( game, wall, points )
	local section = #wall.structure[ self.position ].blocks
	if self.hasBrick and section < 3 then
		game.brickOnWall = game.brickOnWall + 1
		
		table.insert( wall.structure[ self.position ].blocks, 1 )
		points:add( "+10", player.x - 10, player.y )
		score = score + 10
		self.hasBrick = false
		sounds.putBrick:play()
	end
end
function player:shoot( game )
	if self.canShoot and not self.hasBrick then
		self.anim:set( 39, 42, 0.1 )
		self.canShoot = false
		self.bullet = { x = self.x, y = self.y, w = 8, h = 8, angle = 0, quad = self.food[ love.math.random( #self.food ) ] }
		if sounds.shootFood:isPlaying() then sounds.shootFood:stop() end
		sounds.shootFood:play()
		if not game.sombrero.isAlive then
			game.sombrero.value = game.sombrero.value + 10
			if game.sombrero.value > 150 then
				game.sombrero.value = 100
			end
		end
	end
end
function player:update( dt, game, points )
	-- Bullet
	local toRemove = false
	if self.bullet then
		-- Bullet rotation
		self.bullet.angle = self.bullet.angle + dt * 10
		if self.bullet.angle > game.fc then self.bullet.angle = self.bullet.angle - game.fc end
		-- Bullet movement
		self.bullet.y = self.bullet.y - dt * 200
		-- Remove bullet out of screen
		if self.bullet.y < -8 then
			toRemove = true
			self.canShoot = true
		end
		-- Check versus enemies
		for index, enemy in pairs( game.wave ) do
			if CheckCollision( self.bullet.x, self.bullet.y, self.bullet.w, self.bullet.h, enemy.x, enemy.y, enemy.w, enemy.h ) then
				score = score + 30
				points:add( "+30", enemy.x - 4, enemy.y )
				toRemove = true
				self.canShoot = true
				game:removeEnemy( index, true )
				--table.remove( game.wave, index )
				break
			end
		end
		-- Sombrero
		if CheckCollision( self.bullet.x, self.bullet.y, self.bullet.w, self.bullet.h, game.sombrero.x, game.sombrero.y, game.sombrero.w, game.sombrero.h ) then
			score = score + game.sombrero.value
			points:add( tostring( game.sombrero.value ), game.sombrero.x + 4, game.sombrero.y )
			toRemove = true
			self.canShoot = true
			game.sombrero:reset( true )
		end
	end
	if toRemove then self.bullet = nil end
	-- Animation
	self.anim:update( dt )
	-- Movement
	if love.keyboard.isDown( input.left ) then
		self:move( dt, -1, 5, 10, 0.07 )
	elseif love.keyboard.isDown( input.right ) then
		self:move( dt, 1, 5, 10, 0.07 )
	else
		if self.anim.first ~= 1 and self.canShoot then self.anim:set( 1, 4, 0.2 ) end
		self.isMoving = false
	end
	if self.anim.index == 42 then
		self.anim:set( 1, 4, 0.2 )
	end
	self.position = math.ceil( self.x / 16 )
	if not self.isAlive then
		self.anim:set( 43, 43, 1 )
	end
end
function player:draw( game, points )
	if self.bullet then
		if self.bullet.y > 44 then
			love.graphics.setColor( 0, 0, 0, 64 )
			love.graphics.draw( game.sheet, self.bullet.quad, self.bullet.x, self.bullet.y + 6, self.bullet.angle, 1, 1, 4, 4 )
		end
		love.graphics.setColor( 255, 255, 255 )
		love.graphics.draw( game.sheet, self.bullet.quad, self.bullet.x, self.bullet.y, self.bullet.angle, 1, 1, 4, 4 )
	end
	self.anim:draw( math.floor( self.x ), math.floor( self.y ), 0, self.direction, 1, 16 )
	if self.hasBrick then love.graphics.draw( game1.bricks, game.brick.frames[ 1 ], self.x, self.y, 0, self.direction, 1, 8, -8 ) end
	--love.graphics.rectangle( "line", self.x - 8, self.y + 8, self.w, self.h )
end
function player:reset()
	self.bullet = nil
	self.isAlive = true
	self.position = 1
	self.hasBrick = false
	self.canShoot = true
	self.x = 100
	self.y = 280
	self.w = 16
	self.h = 16
	self.speed = 100
end
return player