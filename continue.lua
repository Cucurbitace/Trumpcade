-- Continue screen, once game1, game2 or game3 is over. No continue for secretGame
local continue = {
	explosion = love.audio.newSource( "sounds/explosion.ogg" ),
	timer = 10,
	timerSpeed = 1,
	timerPrevious = 10,
	timerSize = 1,
}
-- Missile ----------------------------------------------------------------------------------------
local missile = {
	sound = love.audio.newSource( "sounds/missile.ogg" ),
	image = love.graphics.newImage( "graphics/missile.png" ),
	frames = {
		love.graphics.newQuad( 0, 0, 16, 64, 64, 42 ),
		love.graphics.newQuad( 16, 0, 16, 64, 64, 42 ),
		love.graphics.newQuad( 32, 0, 16, 64, 64, 42 ),
		love.graphics.newQuad( 48, 0, 16, 64, 64, 42 )
	},
	speed = 22,
	timer = 0,
	index = 1,
	pace = 0.07,
	particles = love.graphics.newParticleSystem( love.graphics.newImage( "graphics/particle.png" ), 512 ),
	x = 100,
	y = 0,
	w = 32,
	h = 128,
}
missile.particles:setParticleLifetime( 0, 3 )
missile.particles:setDirection( math.rad( -90) )
missile.particles:setSpinVariation( 1 )
missile.particles:setAreaSpread( "uniform", 4, 0 )
missile.particles:setEmissionRate( 64 )
missile.particles:setSizes( 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 1 )
missile.particles:setSizeVariation( 1 )
missile.particles:setSpeed( 90, 100 )
missile.particles:setLinearAcceleration( -20, -700, 20, -1000 )
missile.particles:setColors( 255, 255, 255, 255, 0, 0, 0, 0 )
--missile.sound:play() -- Temp
function missile:update( dt )
	self.timer = self.timer + dt
	if self.timer > self.pace then
		self.timer = 0
		self.index = self.index + 1
		if self.index > #self.frames then
			self.index = 1
		end
	end
	self.particles:update( dt )
	self.y = self.y + dt * self.speed
end
function missile:draw()
	love.graphics.draw( self.particles, self.x, self.y, 0, 1, 1, -16 )
	love.graphics.draw( self.image, self.frames[ self.index ], self.x, self.y, 0, 1, 1, -8, 12 )
end
-- Blast ------------------------------------------------------------------------------------------
local blast = {
	x = 112,
	y = 256,
	radius = 0
}
function blast:update( dt )
	if self.radius == 0 then continue.explosion:play() end
	self.radius = self.radius + dt * 1000
	if self.radius > 400 then
		if playerHasHiScore( hiscores, score ) then
			scoreInput:switch()
		else
			gameOver:switch()
		end
	end
end
function blast:draw()
	love.graphics.setColor( 255, 255, 255 )
	love.graphics.circle( "fill", self.x, self.y, self.radius, 64 )
end
-- Trump ------------------------------------------------------------------------------------------
local dot = love.image.newImageData( 1, 1 )
dot:setPixel( 0, 0, 255, 255, 255, 255 )
local trump = {
	frames = {
		love.graphics.newQuad( 64, 448, 32, 32, 256, 544 ),
		love.graphics.newQuad( 96, 448, 32, 32, 256, 544 ),
		love.graphics.newQuad( 0, 480, 32, 32, 256, 544 ),
		love.graphics.newQuad( 32, 480, 32, 32, 256, 544 ),
	},
	x = 112,
	y = 256,
	index = 1,
	timer = 0,
	direction = 1,
	sweat = love.graphics.newParticleSystem( love.graphics.newImage( dot ), 8 )
}
trump.sweat:setParticleLifetime( 0, 1 )
trump.sweat:setDirection( math.rad( 180 ) )
trump.sweat:setAreaSpread( "uniform", 3, 3 )
trump.sweat:setEmissionRate( 64 )
trump.sweat:setSpeed( 50, 70 )
trump.sweat:setLinearAcceleration( -10, -10, 10, -50 )
trump.sweat:setColors( 255, 255, 255, 255, 0, 0, 0, 0 )
function trump:update( dt )
	self.sweat:update( dt )
	self.timer = self.timer + dt
	if self.timer > 0.07 then
		self.timer = 0
		self.index = self.index + 1
		if self.index > 4 then self.index = 1 end
	end
	self.x = self.x + dt * self.direction * 100
	if self.x < 80 then
		self.direction = 1
		self.sweat:reset()
		self.sweat:setDirection( math.rad( 180 ) )
	elseif self.x > 144 then
		self.direction = -1
		self.sweat:setDirection( 0 )
		self.sweat:reset()
	end
end
function trump:draw()
	love.graphics.draw( self.sweat, self.x, self.y - 11 )
	love.graphics.draw( game2.sheet, self.frames[ self.index ], self.x, self.y, 0, self.direction, 1, 16, 16 )
end
-- Main functions ---------------------------------------------------------------------------------
function continue:update( dt )
	self.timer = self.timer - dt
	if self.timer < 5 then
		if self.timerPrevious > math.floor( self.timer ) then
			self.timerSpeed = self.timerSpeed + 1
			self.timerSize = 1
		end
		self.timerSize = self.timerSize + dt * self.timerSpeed
	end
	missile:update( dt )
	trump:update( dt )
	if self.timer < 0 then
		blast:update( dt )
	end
	self.timerPrevious = math.ceil( self.timer )
end
function continue:draw()
	love.graphics.setColor( 255, 255, 200 )
	love.graphics.ellipse( "fill", 112, 270, 64, 12 )
	love.graphics.setColor( 255, 255, 255 )
	trump:draw()
	missile:draw()
	love.graphics.setFont( fonts.basic )
	if credits < 1 then
		love.graphics.printf( "CREDIT 0\nInsert coin to continue!", 0, 150, 224, "center" )
	elseif credits == 1 then
		love.graphics.printf( "CREDIT 1\nPress start to continue!", 0, 150, 224, "center" )
	else
		love.graphics.printf( "CREDITS "..credits.."\nPress start to continue!", 0, 150, 224, "center" )
	end
	printTimer( self.timer, fonts.basic, self.timerSize )
	if self.timer < 0 then
		blast:draw()
	end
end
function continue:keypressed( key )
	if key == input.coin and self.timer > 0 then
		self:reset()
	end
	if credits > 0 and key == input.start then
		score = 0
		currentGame:continue()
	end
end
function continue:reset()
	blast.radius = 0
	missile.y = 0
	missile.particles:reset()
	self.timer = 10
end
function continue:switch()
	if music then music:stop() end
	missile.sound:play()
	self:reset()
	self.timer = 10
	phase = self
end
return continue