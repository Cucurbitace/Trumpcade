local hiscore = {}
hiscore.timer = 30
hiscore.bg = love.graphics.newImage( "graphics/bust.png" )
hiscore.bigFont = love.graphics.newImageFont( "graphics/Big pixels font.png", "@ABCDEFGHIJKLMNOPQRSTUVWXYZÄÖÂ↑← !\"#$%&'()*+,-./0123456789:;<=>?" )
hiscore.limit = 10
hiscore.position = 1
hiscore.name = ""
hiscore.letters = { "A", "←", "-", ".", ",", "!", "$", "%", "*", "+"," ", "Z", "Y", "X", "W", "V", "U", "T", "S", "R", "Q", "P", "O", "N", "M", "L", "K", "J", "I", "H", "G", "F", "E", "D", "C", "B", }
hiscore.wheel = {}
for i, letter in pairs( hiscore.letters ) do
	local a = math.rad( i * 10 + 75 )
	table.insert( hiscore.wheel, { letter = letter, x = 92 * math.cos( a ), y = 6 * math.sin( a ), angle = a } )
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
	if not music:isPlaying() then
		music:play()
	end
	self.timer = self.timer - dt
	if self.timer < 0 then
		self:validate()
	end
end
function hiscore:draw()
	love.graphics.setColor( 255, 255, 255 )
	love.graphics.draw( self.bg, 0, 0 )
	love.graphics.setFont( self.bigFont )
	love.graphics.printf( self.name, 0, 10, 224, "center" )
	love.graphics.printf( "$"..tostring( score ), 0, 30, 224, "center" )
	love.graphics.printf( math.ceil( self.timer ), 22, 150, 32, "left" )
	for _, element in pairs( self.wheel ) do
		if element.y >= 0 then
			local scale, x, y
			if element.letter == self.letters[ self.position ] then
				scale = 1.5
				x = math.floor( 107 + element.x ) - 3
				y = math.floor( 277 + element.y ) - 4
			else
				scale = 1
				x = math.floor( 107 + element.x )
				y = math.floor( 277 + element.y )
			end
			local color = element.y * 40
			love.graphics.setColor( color, color, color )
			love.graphics.print( element.letter, x, y, 0, scale, scale )
		end
	end
	love.graphics.setColor( 255, 255, 255 )
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
		e.x = 92 * math.cos( e.angle )
		e.y = 6 * math.sin( e.angle )
	end
	table.sort( self.wheel, function( v1, v2 ) return v1.y < v2.y end )
	self.position = self.position + dir
	if self.position < 1 then self.position = #self.letters elseif self.position > #self.letters then self.position = 1 end
end
function hiscore:keypressed( key )
	if key == input.left then
		self:rotate( 1 )
	elseif key == input.right then
		self:rotate( -1 )
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
end
function hiscore:switch()
	music = musics.hiscore
	self.timer = 60
	self.name = ""
	self.limit = 10
	self.position = 1
	for i, letter in pairs( hiscore.letters ) do
		local a = math.rad( i * 10 + 75 )
		table.insert( hiscore.wheel, { letter = letter, x = 92 * math.cos( a ), y = 6 * math.sin( a ), angle = a } )
	end
	table.sort( hiscore.wheel, function( v1, v2 ) return v1.y < v2.y end )
	phase = self
end
return hiscore