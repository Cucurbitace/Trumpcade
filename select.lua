local gameSelect = {
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
		gameOver:switch()
	end
	cheatCode:update( dt, gameSecret.isComplete )
end
function gameSelect:draw()
	love.graphics.draw( self.wall_logo, 12, self.y )
	love.graphics.draw( self.g2_logo, 12, self.y + self.h )
	love.graphics.draw( self.g3_logo, 12, self.y + self.h * 2 )
	love.graphics.rectangle( "line", self.selector.x, self.selector.y + self.pointer * self.h, self.selector.w, self.selector.h )
	love.graphics.printf( math.ceil( self.timer ), 0, 300, 224, "center" )
	printScore( score, fonts.basic )
	-- Debug
end
function gameSelect:keypressed( key )
	if key == input.up then
		self:moveSelector( -1 )
	elseif key == input.down then
		self:moveSelector( 1 )
	elseif key == input.start then
		if self.pointer == 0 then -- Game 1
			self.music:stop()
			self:setPointer()
			game1:switch()
		elseif self.pointer == 1 then -- Game 2
			self.music:stop()
			self:setPointer()
			game2:switch()
		elseif self.pointer == 2 then -- Game 3
			self.music:stop()
			self:setPointer()
			game3:switch()
		end
	end
end
function gameSelect:setPointer()
	for i, g in pairs( gameIsComplete ) do
		if not g then
			self.pointer = i - 1
			break
		end
	end
end
function gameSelect:switch( reset )
	if reset then self.pointer = 0 end
	self.timer = 30
	self.music:play()
	phase = self
end
function gameSelect:moveSelector( direction )
	local c = 0
	for _, g in pairs( gameIsComplete ) do
		if g then c = c + 1 end
	end
	if c < 2 then
		self.pointer = self.pointer + direction
		if self.pointer > self.elements_count then
			self.pointer = 0
		elseif self.pointer < 0 then
			self.pointer = self.elements_count
		end
		if gameIsComplete[ self.pointer + 1 ] then
			self.pointer = self.pointer + direction
		end
		if self.pointer > self.elements_count then
			self.pointer = 0
		elseif self.pointer < 0 then
			self.pointer = self.elements_count
		end
	end
end
return gameSelect
