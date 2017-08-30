function newBGImage( fileName, x, y, show, hide, speed_x, speed_y )
	local image = love.graphics.newImage( fileName )
	local bg = { x = x, y = y }
	if speed_x and speed_y then
		function bg:update( dt, t )
			if t > show and t < hide then
				self.x = self.x + speed_x * dt
				self.y = self.y + speed_y * dt
			end
		end
	end
	function bg:draw( t )
		if t >= show and t <= hide then
			love.graphics.draw( image, math.floor( self.x ), math.floor( self.y ) )
		end
	end
	return bg
end