local animation = {}
animation.__index = animation
function newAnimation( image, fw, fh, pace, frames_count )
	local sw, sh = image:getDimensions()
	local a = {
		image = image,
		pace = pace,
		timer = 0,
		index = 1,
		last = frames_count,
		first = 1,
		frames = {}
	}
	local x, y = 0, 0
	for i = 1, frames_count do
		table.insert( a.frames, love.graphics.newQuad( x, y, fw, fh, sw, sh ) )
		x = x + fw
		if x >= sw then
			x = 0
			y = y + fh
		end
	end
	return setmetatable( a, animation )
end
function animation:update( dt )
	self.timer = self.timer + dt
	if self.timer > self.pace then
		self.timer = 0
		self.index = self.index + 1
		if self.index > self.last then self.index = self.first end
	end
end
function animation:draw( ... )
	love.graphics.draw( self.image, self.frames[ self.index ], ... )
end
function animation:set( first, last, pace )
	self.pace = pace
	self.first = first
	self.last = last
	self.index = first
end