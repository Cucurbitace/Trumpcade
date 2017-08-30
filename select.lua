local gameSelect = {
	sizeTimer = 0,
	size = 1,
	timer = 30,
	music = love.audio.newSource( "music/Do not move PSG.mp3" ),
	wall_logo = love.graphics.newImage( "graphics/the_wall_logo.png" ),
	g2_logo = love.graphics.newImage( "graphics/game_2_logo.png" ),
	g3_logo = love.graphics.newImage( "graphics/game_3_logo.png" ),
	pointer = 0,
	y = 150,
	h = 32,
	elements_count = 2, -- Base 0
	selector = { x = 12, y = 150, w = 200, h = 16 }
}
function gameSelect:update( dt )
	self.timer = self.timer - dt
	if self.timer < 0 then
		self.timer = 0
	end
	self.size = self.sizeTimer * self.timer - 30
	cheatCode:update( dt )
end
function gameSelect:draw()
	love.graphics.setColor( 255, 255, 255 )
	love.graphics.draw( self.wall_logo, 12, self.y )
	love.graphics.draw( self.g2_logo, 12, self.y + self.h )
	love.graphics.draw( self.g3_logo, 12, self.y + self.h * 2 )
	love.graphics.rectangle( "line", self.selector.x, self.selector.y + self.pointer * self.h, self.selector.w, self.selector.h )
	love.graphics.printf( math.ceil( self.timer ), 0, 300, 224, "center", 0, self.size )
	-- Debug
	love.graphics.print( self.pointer )
	love.graphics.print( self.size, 10, 10 )
end
function gameSelect:keypressed( key )
	if key == input.up then
		self:moveSelector( -1 )
	elseif key == input.down then
		self:moveSelector( 1 )
	elseif key == input.start then
		if self.pointer == 0 then
			game1:switch()
		elseif self.pointer == 1 then

		elseif self.pointer == 2 then

		end
	end
end
function gameSelect:switch()
	self.timer = 30
	self.music:play()
	phase = self
end
function gameSelect:moveSelector( direction )
	self.pointer = self.pointer + direction
	if self.pointer > self.elements_count then
		self.pointer = 0
	elseif self.pointer < 0 then
		self.pointer = self.elements_count
	end
end
return gameSelect
