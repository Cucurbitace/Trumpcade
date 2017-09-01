local continue = {
	timer = 10,
}

function continue:update( dt )
	self.timer = self.timer - dt
	if self.timer < 0 then
		if playerHasHiScore() then
			scoreInput:switch()
		else
			title:switch()
		end
	end
end
function continue:draw()
	love.graphics.setFont( fonts.basic )
	if credits < 1 then
		love.graphics.printf( "CREDIT 0\nInsert coin to continue!", 0, 150, 224, "center" )
	elseif credits == 1 then
		love.graphics.printf( "CREDIT 1\nPress start to continue!", 0, 150, 224, "center" )
	else
		love.graphics.printf( "CREDITS "..credits.."\nPress start to continue!", 0, 150, 224, "center" )
	end
	love.graphics.printf( math.ceil( self.timer ), 0, 300, 224, "center" )
end
function continue:keypressed( key )
	if key == input.coin then self.timer = 10 end
	if credits > 0 and key == input.start then
		score = 0
		currentGame:continue()
	end
end
function continue:switch()
	self.timer = 10
	phase = self
end
return continue