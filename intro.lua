local intro = {
	timer = 0,
	index = 1,
	y = 0
}
intro.text = {
	"",
	"THIS GAME IS FOR USE IN",
	"THE GREATEST COUNTRY OF",
	"UNITED STATES OF",
	"AMERICA. IF YOU ARE",
	"USING IT IN ANOTHER",
	"LOSER COUNTRY, YOU ARE",
	"A CRIMINAL AND WILL BE",
	"PROSECUTED BY THE FULL",
	"EXTENT OF PATRIOT",
	"MISSILES.",
	"",
	""
}
local data = love.image.newImageData( 224, 320 )
local x, y, alpha = 0, 0, 0
for i = 1, 71680 do
	data:setPixel( x, y, 0, 0, 0, alpha )
	x = x + 1
	if x == 224 then
		x = 0
		y = y + 1
		alpha = alpha + 16
		if alpha > 255 then alpha = 255 end
	end
end
intro.mask = love.graphics.newImage( data )
function intro:update( dt )
	self.y = self.y + dt * 22
	self.timer = self.timer + dt
	if self.timer > 1 then
		self.timer = 0
		self.index = self.index + 1
		if self.index > #self.text then
			self.index = #self.text
			switchTo( title, true )
		end
	end
end
function intro:draw()
	love.graphics.setFont( fonts.basic )
	for i, t in pairs( self.text ) do
		love.graphics.printf( t, 20, 10 + i * 20, 184, "center" )
	end
	love.graphics.draw( self.mask, 0, math.floor( self.y ) )
	love.graphics.print( "@3-BIT 2017", 110, 300 )
end
function intro:switch()
	self.index = 1
	self.timer = 0
	self.y = 0
	music = nil
	phase = self
end
return intro