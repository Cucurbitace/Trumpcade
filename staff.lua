local staff = {
	timer = 0,
	music = love.audio.newSource( "music/Juhani Junkala [Retro Game Music Pack] Level 3.ogg", "stream" ),
	speed = 10,
	fonts = {
		header = love.graphics.newImageFont( "graphics/Block Font.png", '!"#$%&'.."'()*+,-./0123456789:.<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_¨{|}~abcdefghijklmnopqrstuvwxyz " ),
		body = love.graphics.newImageFont( "graphics/good_neighbors.png", '!"#$%&'.."'()*+,-./0123456789:.<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_¨abcdefghijklmnopqrstuvwxyz{|}~ ç" ),
	},
	list = {
		--[[
			Distances between:
			* names = 14
			* names and header = 30
			* next section = 50
		]]
		{ image = love.graphics.newImage( "graphics/title.png" ), oy = 320, y = 320, x = 35 },
		{ text = "A great game by", oy = 360, y = 360, font = "body" },
		{ image = love.graphics.newImage( "graphics/3bit_logo.png"), oy = 375, y = 375, x = 62 },
		{ text = "Code", oy = 430, y = 430, font = "header" },
		{ text = "Yannick Carrey", oy = 460, y = 460, font = "body" },
		{ text = "Graphics", oy = 510, y = 510, font = "header" },
		{ text = "Mathieu Schmidt", oy = 540, y = 540, font = "body" },
		{ text = "Yannick Carrey", oy = 554, y = 554, font = "body" },
		{ text = "Music", oy = 604, y = 604, font = "header" },
		{ text = "Juhani Junkala", oy = 634, y = 634, font = "body" },
		{ text = "QA Test", oy = 684, y = 684, font = "header" },
		{ text = "Mathieu Schmidt", oy = 714, y = 714, font = "body" },
		{ text = "Yannick Carrey", oy = 728, y = 728, font = "body" },
		{ text = "François de Domahidy", oy = 742, y = 742, font = "body" },
	},
	bg = {}
}
local s = 0
local dir = 1
local x, y = 8, 8
for i = 1, 296 do
	local c = { x = x, y = y, s = s, dir = dir }
	x = x + 16
	if x > 224 then
		x = 8
		y = y + 16
	end
	s = s + dir
	if s > 16 then
		s = 15
		dir = -1
	elseif s < 1 then
		s = 2
		dir = 1
	end
	table.insert( staff.bg, c )
end
function staff:update( dt )
	if not self.music:isPlaying() then self.music:play() end
	self.timer = self.timer + dt
	if self.timer > 60 then
		self.music:stop()
		title:switch()
	end
	for _, line in pairs( self.list ) do
		if line.y > -32 then
			line.y = line.y - dt * self.speed
		end
	end
	for _, circle in pairs( self.bg ) do
		circle.s = circle.s + dt * circle.dir * self.speed
		if circle.s > 24 then
			circle.s = 24
			circle.dir = -1
		elseif circle.s < 0 then
			circle.s = 0
			circle.dir = 1
		end
	end
end
function staff:draw()
	love.graphics.setColor( 64, 0, 128 )
	love.graphics.rectangle( "fill", 0, 0, 224, 320 )
	for _, object in pairs( self.bg ) do
		love.graphics.setColor( 0, 64, 128, 64 )
		love.graphics.circle( "fill", object.x, object.y, object.s )
		love.graphics.setColor( 78, 0, 160, 96 )
		love.graphics.circle( "line", object.x, object.y, object.s / 2 )
	end
	love.graphics.setColor( 255, 255, 255 )
	for _, line in pairs( self.list ) do
		if line.y > -32 and line.y < 320 then
			if line.text then
				love.graphics.setFont( self.fonts[ line.font ] )
				love.graphics.printf( line.text, 0, math.ceil( line.y ), 224, "center" )
			elseif line.image then
				love.graphics.draw( line.image, line.x, math.ceil( line.y ) )
			end
		end
	end
end
function staff:keypressed( key )
	-- body
end
function staff:switch( ... )
	for _, entry in self.list do entry.y = entry.oy end
	phase = self
end
return staff