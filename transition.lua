local transition = {
	size = 0,
	direction = 1,
	stars = {},
	isActive = false
}
local x, y = 0, 0
local angle = math.rad( 90 )
local step = math.rad( 36 )
for i = 1, 148 do
	local star = {  x = x, y = y, step = step, angles = { angle, angle + step, angle + step * 2, angle + step * 3, angle + step * 4, angle + step * 5, angle + step * 6, angle + step * 7, angle + step * 8, angle + step * 9 } }
	table.insert( transition.stars, star )
	x = x + 32
	if x > 224 then
		if i % 16 == 0 then
			x = 0
		else
			x = -16
		end
		y = y + 32
	end
end
function transition:set( target, param )
	self.target = target
	self.targetParam = param
end
function transition:update( dt, phase )
	if self.isActive then
		self.size = self.size + dt * self.direction * 80
		if self.size > 40 then
			self.size = 40
			self.direction = -1
			self.target:switch( self.targetParam )
			--switchTo( self.target, self.targetParam )
		elseif self.size < 0 then
			self.size = 0
			self.direction = 1
			self.isActive = false
			self.target = nil
			self.targetParam = nil
		end
	end
end
function transition:draw( r, g, b )
	if self.isActive then
		love.graphics.setColor( r, g, b )
		for _, star in pairs( self.stars ) do
			local points = {}
			for i, angle in pairs( star.angles ) do
				local size
				if i % 2 == 0 then
					size = self.size
				else
					size = self.size / 2
				end
				table.insert( points, star.x + math.cos( angle ) * size )
				table.insert( points, star.y + math.sin( angle ) * size )
			end
			for i, point in pairs( points ) do
				love.graphics.polygon( "fill", points )
			end
		end
		love.graphics.setColor( 255, 255, 255 )
	end
end
return transition