-- Game Over screen
local gameOver = {
	music = love.audio.newSource( "music/gameOver.ogg" ),
	image = love.graphics.newImage( "graphics/nuke.png" ),
	loserTrigger = true,
	loserSound = love.audio.newSource( "sounds/loser.ogg" ),
	xOffset = 5,
	yOffset = 5,
	timer = 0
}
function gameOver:update( dt )
	if self.xOffset > 0 then
		self.xOffset = self.xOffset - dt * 10
	elseif self.xOffset < 0 then
		self.xOffset = 0
	end
	if self.yOffset > 0 then
		self.yOffset = self.yOffset - dt * 10
	elseif self.yOffset < 0 then
		self.yOffset = 0
	end
	self.timer = self.timer + dt
	if self.timer > 5 and self.loserTrigger then
		self.loserTrigger = false
		self.loserSound:play()
	elseif self.timer > 10 then
		--title:switch()
		switchTo( title, true )
		resetEverything( true )
	end
end
function gameOver:draw()
	love.graphics.draw( self.image, 0, 0, 0, 1, 1, love.math.random( math.ceil( self.xOffset ) - math.ceil( self.xOffset / 2 ) ), love.math.random( math.ceil( self.yOffset ) ) - math.ceil( self.yOffset / 2 ) )
	love.graphics.setFont( fonts.basic )
	love.graphics.printf( "GAME OVER", 0, 145, 224, "center" )
	love.graphics.printf( "YOU LOSE!", 0, 165, 224, "center" )
end
function gameOver:keypressed( key )
	if key == input.start or key == input.a or key == input.b or key == input.c then
		--title:switch()
		switchTo( title, true )
		resetEverything( true )
	end
end
function gameOver:switch()
	music = self.music
	music:play()
	self.loserTrigger = true
	self.xOffset = 16
	self.yOffset = 16
	phase = self
	self.timer = 0
end
return gameOver