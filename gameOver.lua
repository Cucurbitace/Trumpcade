local gameOver = {
	loserSound = love.audio.newSource( "sounds/loser.ogg" ),
	timer = 0
}
function gameOver:update( dt )
	self.timer = self.timer + dt
	if self.timer > 10 then
		title:switch()
	end
end
function gameOver:draw()
	love.graphics.setFont( fonts.basic )
	love.graphics.printf( "YOU LOSE!", 0, 155, 224, "center" )
end
function gameOver:keypressed( key )
	if key == input.start or key == input.a or key == input.b or key == input.c then
		title:switch()
	end
end
function gameOver:switch()
	phase = self
	self.timer = 0
	self.loserSound:play()
end
return gameOver