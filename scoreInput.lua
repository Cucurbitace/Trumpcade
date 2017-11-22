local hiscore = {}
hiscore.timer = 60
hiscore.bg = love.graphics.newImage( "graphics/bust.png" )
hiscore.bigFont = love.graphics.newImageFont( "graphics/Big pixels font.png", "@ABCDEFGHIJKLMNOPQRSTUVWXYZÄÖÂ↑← !\"#$%&'()*+,-./0123456789:;<=>?" )
hiscore.limit = 10
hiscore.position = 1
hiscore.name = ""
hiscore.letters = { "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "←", "-", ".", ",", "!", "$", "%", "*", "+"," " }
hiscore.wheel = {}
for i, letter in pairs( hiscore.letters ) do
	local a = math.rad( i * 10 + 75 )
	table.insert( hiscore.wheel, { letter = letter, x = 55 * math.cos( a ), y = 5 * math.sin( a ), angle = a } )
end
table.sort( hiscore.wheel, function( v1, v2 ) return v1.y < v2.y end )
function hiscore:backspace()
	self.name = self.name:sub( 1, #self.name - 1 )
end
function hiscore:validate()
	if score > hiscores[ 1 ].value then
		hiscores[ 1 ].value = score + love.math.random( 1, 1000 )
	end
	table.insert( hiscores, { name = self.name, value = score } )
	table.sort( hiscores, function( v1, v2 ) return v1.value > v2.value end )

	table.remove( hiscores, #hiscores )

	resetEverything()
	--title:switch()
	switchTo( title, true )
end
function hiscore:update( dt )
	self.timer = self.timer - dt
	if self.timer < 0 then
		self:validate()
	end
end
function hiscore:draw()
	love.graphics.setColor( 255, 255, 255 )
	love.graphics.draw( self.bg, 13, 0 )
	love.graphics.setFont( self.bigFont )
	love.graphics.printf( self.name, 0, 90, 224, "center" )
	love.graphics.printf( score, 0, 40, 224, "center" )
	love.graphics.printf( math.ceil( self.timer ), 0, 10, 224, "center" )
	-- for _, input in pairs( self.inputs ) do
	-- 	love.graphics.printf( input.char, input.x, input.y, 30, "center" )
	-- end
	-- local input = self.inputs[ self.position ]
	-- love.graphics.rectangle( "line", input.x, input.y - 10, 30, 30 )
	-- if #self.name > 0 then
	-- 	love.graphics.printf( self.name, 0, 230, 224, "center" )
	-- end
	for _, element in pairs( self.wheel ) do
		if element.y >= 0 then
			local scale, x, y
			if element.letter == self.letters[ self.position ] then
				scale = 1.5
				x = math.floor( 105 + element.x ) - 3
				y = math.floor( 290 + element.y ) - 4
			else
				scale = 1
				x = math.floor( 105 + element.x )
				y = math.floor( 290 + element.y )
			end
			local color = element.y * 51
			love.graphics.setColor( color, color, color )
			love.graphics.print( element.letter, x, y, 0, scale )
		end
	end
end
function hiscore:rotate( dir )
	for i, e in pairs( self.wheel ) do
		local min, max = math.rad( 0 ), math.rad( 360 )
		e.angle = e.angle - math.rad( 10 ) * dir
		if e.angle > max then
			e.angle = e.angle - max
		elseif e.angle < min then
			e.angle = e.angle + min
		end
		e.x = 55 * math.cos( e.angle )
		e.y = 5 * math.sin( e.angle )
	end
	table.sort( self.wheel, function( v1, v2 ) return v1.y < v2.y end )
	self.position = self.position + dir
	if self.position < 1 then self.position = #self.letters elseif self.position > #self.letters then self.position = 1 end
end
function hiscore:keypressed( key )
	if key == input.left then
		self:rotate( -1 )
	elseif key == input.right then
		self:rotate( 1 )
	end
	if key == input.a and #self.name < 16 then
		local letter = self.letters[ self.position ]
		if letter == "←" then
			self:backspace()
		else
			self.name = self.name..letter
		end
	elseif key == input.b and #self.name > 0 then
		self:backspace()
	elseif key == input.start then
		self:validate()
	end
	-- local input = self.inputs[ self.position ]
	-- if key == "up" then
	-- 	self.position = input.up
	-- elseif key == "down" then
	-- 	self.position = input.down
	-- elseif key == "left" then
	-- 	self.position = input.left
	-- elseif key == "right" then
	-- 	self.position = input.right
	-- elseif key == "1" then
	-- 	self:validate()
	-- elseif key == "a" then
	-- 	if self.position == 30 then
	-- 		self:validate()
	-- 	elseif self.position == 29 then
	-- 		self:backspace()
	-- 	elseif #self.name <= self.limit then
	-- 		self.name = self.name..input.char
	-- 		if #self.name == self.limit then self.position = 30 end
	-- 	end
	-- elseif key == "b" and #self.name > 0 then
	-- 	self:backspace()
	-- end
end
function hiscore:switch()
	self.timer = 60
	self.name = ""
	self.limit = 10
	self.position = 1
	for i, letter in pairs( hiscore.letters ) do
		local a = math.rad( i * 10 + 75 )
		table.insert( hiscore.wheel, { letter = letter, x = 55 * math.cos( a ), y = 5 * math.sin( a ), angle = a } )
	end
	table.sort( hiscore.wheel, function( v1, v2 ) return v1.y < v2.y end )
	phase = self
end
return hiscore

-- hiscore.inputs = {
-- 	{ char = "A", x = 35, y = 50, up = 26, down = 6, left = 5, right = 2 },
-- 	{ char = "B", x = 65, y = 50, up = 27, down = 7, left = 1, right = 3 },
-- 	{ char = "C", x = 95, y = 50, up = 28, down = 8, left = 2, right = 4 },
-- 	{ char = "D", x = 125, y = 50, up = 29, down = 9, left = 3, right = 5 },
-- 	{ char = "E", x = 155, y = 50, up = 30, down = 10, left = 4, right = 1 },
-- 	{ char = "F", x = 35, y = 80, up = 1, down = 11, left = 10, right = 7 },
-- 	{ char = "G", x = 65, y = 80, up = 2, down = 12, left = 6, right = 8 },
-- 	{ char = "H", x = 95, y = 80, up = 3, down = 13, left = 7, right = 9 },
-- 	{ char = "I", x = 125, y = 80, up = 4, down = 14, left = 8, right = 10 },
-- 	{ char = "J", x = 155, y = 80, up = 5, down = 15, left = 9, right = 6 },
-- 	{ char = "K", x = 35, y = 110, up = 6, down = 16, left = 15, right = 12 },
-- 	{ char = "L", x = 65, y = 110, up = 7, down = 17, left = 11, right = 13 },
-- 	{ char = "M", x = 95, y = 110, up = 8, down = 18, left = 12, right = 14 },
-- 	{ char = "N", x = 125, y = 110, up = 9, down = 19, left = 13, right = 15 },
-- 	{ char = "O", x = 155, y = 110, up = 10, down = 20, left = 14, right = 11 },
-- 	{ char = "P", x = 35, y = 140, up = 11, down = 21, left = 20, right = 17 },
-- 	{ char = "Q", x = 65, y = 140, up = 12, down = 22, left = 16, right = 18 },
-- 	{ char = "R", x = 95, y = 140, up = 13, down = 23, left = 17, right = 19 },
-- 	{ char = "S", x = 125, y = 140, up = 14, down = 24, left = 18, right = 20 },
-- 	{ char = "T", x = 155, y = 140, up = 15, down = 25, left = 19, right = 16 },
-- 	{ char = "U", x = 35, y = 170, up = 16, down = 26, left = 25, right = 22 },
-- 	{ char = "V", x = 65, y = 170, up = 17, down = 27, left = 21, right = 23 },
-- 	{ char = "W", x = 95, y = 170, up = 18, down = 28, left = 22, right = 24 },
-- 	{ char = "X", x = 125, y = 170, up = 19, down = 29, left = 23, right = 25 },
-- 	{ char = "Y", x = 155, y = 170, up = 20, down = 30, left = 24, right = 21 },
-- 	{ char = "Z", x = 35, y = 200, up = 21, down = 1, left = 30, right = 27 },
-- 	{ char = ".", x = 65, y = 200, up = 22, down = 2, left = 26, right = 28 },
-- 	{ char = "!", x = 95, y = 200, up = 23, down = 3, left = 27, right = 29 },
-- 	{ char = "←", x = 125, y = 200, up = 24, down = 4, left = 28, right = 30 },
-- 	{ char = "↵", x = 155, y = 200, up = 25, down = 5, left = 29, right = 26 },
-- }