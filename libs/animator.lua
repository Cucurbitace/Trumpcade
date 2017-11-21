-- Animation engine, based on AnAL.
local animation = {}
animation.__index = animation
function newAnimation( image, frameWidth, frameHeight, pace, framesCount, areaX, areaY, areaWidth, areaHeight, firstFrame, lastFrame )
	local sw, sh = image:getDimensions()
	local anim = {
		image = image,
		pace = pace,
		timer = 0,
		index = 1,
		last = lastFrame or framesCount,
		first = firstFrame or 1,
		frames = {}
	}
	local x, y = areaX or 0, areaY or 0
	for i = 1, framesCount do
		table.insert( anim.frames, love.graphics.newQuad( x, y, frameWidth, frameHeight, sw, sh ) )
		x = x + frameWidth
		if x >= ( ( areaX + areaWidth ) or sw ) then
			x = areaX or 0
			y = y + frameHeight
		end
	end
	return setmetatable( anim, animation )
end
function animation:update( dt )
	--print( self.index, self.timer, self.pace )
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
	if pace then self.pace = pace end
	self.first = first
	self.last = last
	self.index = first
end