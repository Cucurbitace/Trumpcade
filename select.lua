-- Games selection screen. Secret code can be input here.
local sw, sh = 448, 192
local gameSelect = {
	zoom = 1,
	direction = 1,
	alpha = 255,
	operator = -1,
	timer = 30,
	logos = {
		{ y = 32, selected = love.graphics.newQuad( 0, 0, 224, 64, sw, sh ), greyedOut = love.graphics.newQuad( 224, 0, 224, 64, sw, sh ), index = 0, h = 64 },
		{ y = 96, selected = love.graphics.newQuad( 0, 64, 224, 32, sw, sh ), greyedOut = love.graphics.newQuad( 224, 64, 224, 32, sw, sh ), index = 1, h = 32 },
		{ y = 128, selected = love.graphics.newQuad( 0, 96, 224, 64, sw, sh ), greyedOut = love.graphics.newQuad( 224, 96, 224, 64, sw, sh ), index = 2, h = 64 },
		},
	pointer = 0,
	y = 32,
	h = 64,
	elements_count = 2, -- First is 0
	selector = { x = 12, y = 150, w = 200, h = 16 },
	description = {
		"You must stop the Bad Hombres to cross the border and invade the country. Build the wall and stop them with great American burgers while avoiding their nasty food.",
		"Feminist protesters have invaded the White House. Collect all the money laying around and get a Viagra to grab them by the pussy to show them who's the man.",
		"Crooked Hilary has taken your darling Ivanka hostage inside the Trump Tower. Climb the tower avoiding Hilary's fraudulent e-mails and rescue your daughter."
	}
}
function gameSelect:update( dt )
	self.zoom = self.zoom + self.direction * dt / 2
	if self.zoom > 1 then
		self.direction = -self.direction
		self.zoom = 0.99
	elseif self.zoom < 0.8 then
		self.direction = -self.direction
		self.zoom = 0.81
	end
	self.coin:update( dt )
	self.alpha = self.alpha + dt * self.operator * 1000
	if self.alpha > 255 then
		self.alpha = 255
		self.operator = -1
	elseif self.alpha < 0 then
		self.alpha = 0
		self.operator = 1
	end
	if not transition.isActive then
		self.timer = self.timer - dt
	end
	if self.timer < 0 then
		score = 0
		self.timer = 0
		switchTo( gameOver, true  )
	end
	cheatCode:update( dt, gameSecret.isComplete )
end
function gameSelect:draw()
	love.graphics.setFont( fonts.basic )
	love.graphics.setColor( self.alpha, 160, 13, self.alpha )
	love.graphics.setColor( 255, 255, 255 )
	self.coin:draw( -6, self.logos[ self.pointer + 1 ].y, 0, 1, 1, 0, -self.logos[ self.pointer + 1 ].h / 2 + 16 )
	self.coin:draw( 230, self.logos[ self.pointer + 1 ].y, 0, -1, 1, 0, -self.logos[ self.pointer + 1 ].h / 2 + 16 )
	love.graphics.setColor( 255, 255, 255 )
	for _, logo in pairs( self.logos ) do
		local quad
		local zoom
		local ox
		local oy
		if logo.index == self.pointer then
			quad = logo.selected
			zoom = self.zoom
			local qw, qh = quad:getTextureDimensions()
			ox = -( qw - ( qw * zoom ) ) / 4
			oy = -( qh - ( qh * zoom ) ) / 4
		else
			quad = logo.greyedOut
			zoom = 1
			ox = 0
			oy = 0
		end
		love.graphics.draw( sheets.select, quad, 0, logo.y, 0, zoom, zoom, ox, oy )
	end
	love.graphics.printf( self.description[ self.pointer + 1 ], 16, 200, 198, "center" )
	printScore( score, fonts.basic )
	printTimer( self.timer, fonts.basic )
	-- Debug
end
function gameSelect:keypressed( key )
	if key == input.up then
		self:moveSelector( -1 )
	elseif key == input.down then
		self:moveSelector( 1 )
	elseif key == input.start then
		sounds.validate:play()
		if self.pointer == 0 then -- Game 1
			musics.select:stop()
			self:setPointer()
			--game1:switch()
			switchTo( game1, true )
		elseif self.pointer == 1 then -- Game 2
			musics.select:stop()
			self:setPointer()
			--game2:switch()
			switchTo( game2, true )
		elseif self.pointer == 2 then -- Game 3
			musics.select:stop()
			self:setPointer()
			--game3:switch()
			switchTo( game3 )
		end
	elseif key == input.left or key == input.right or key == input.a or key == input.b then
		if sounds.movePointer:isPlaying() then sounds.movePointer:stop() end
		sounds.movePointer:play()
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
	if music then music:stop() end
	music = musics.select
	music:setVolume( 0.5 )
	music:play()
	if reset then self.pointer = 0 end
	self.timer = 30
	phase = self
end
function gameSelect:moveSelector( direction )
	if sounds.movePointer:isPlaying() then sounds.movePointer:stop() end
	sounds.movePointer:play()
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
