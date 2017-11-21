-- Constants game setup, are being saved to a file
local setup = {
	cursor = 1,
	menu = {
		{ info = "Credits/coin:", y = 64, source = { "1", "2", "3", "4", "5" }, index = settings[ 1 ] },
		{ info = "Extra life:", y = 96, source = { "None", "At 500.000", "Every 100.000", "Every 200.000", "Every 500.000" }, index = settings[ 3 ] },
		{ info = "Speed:", y = 128, source = { "100%", "110%", "120%", "130%", "140%", "150%" }, index = settings[ 2 ] },
		{ info = "Attract mode:", y = 160, source = { "ON", "OFF" }, index = settings[ 4 ] },
	},
}

function setup:update( dt )
	-- body
end
function setup:draw()
	love.graphics.setFont( fonts.basic )
	love.graphics.printf( "Service menu", 0, 32, 224, "center" )
	love.graphics.printf( "Press UP or DOWN to select an option.", 16, 224, 198, "center" )
	love.graphics.printf( "Press LEFT or RIGHT to change the value.", 16, 252, 198, "center" )
	love.graphics.printf( "Press START to save and exit.", 16, 280, 198, "center" )
	for index, element in pairs( self.menu ) do
		if index == self.cursor then
			love.graphics.setColor( 255, 255, 0 )
		else
			love.graphics.setColor( 255, 255, 255 )
		end
		love.graphics.printf( element.info, 16, element.y, 198, "left" )
		love.graphics.printf( element.source[ element.index ], 0, element.y + 10, 198, "right" )
	end
	love.graphics.setColor( 255, 255, 255 )
end
function setup:keypressed( key )
	if key == input.up then
		self:moveCursor( -1 )
	elseif key == input.down then
		self:moveCursor( 1 )
	elseif key == input.left then
		self:moveOption( -1 )
	elseif key == input.right then
		self:moveOption( 1 )
	elseif key == input.start then
		self:writeOption()
		intro:switch()
	end
end
function setup:switch()
	if music then music:stop() end
	phase = self
	cursor = 1
end
function setup:writeOption()
	-- à refaire, c'est de la merde.
	for i = 1, #self.menu do
		settings[ i ] = self.menu[ i ].index 
	end
	love.filesystem.remove( "data" )
	local file, errorstr = love.filesystem.newFile( "data", "w" )
	local output = ""
	for index, value in pairs( settings ) do
		if index < #settings then
			output = output..tostring( value ).."\n"
		else
			output = output..tostring( value )
		end
	end
	file:write( output )
end
function setup:moveCursor( direction )
	self.cursor = self.cursor + direction
	if self.cursor > #self.menu then
		self.cursor = 1
	elseif self.cursor < 1 then
		self.cursor = #self.menu
	end
end
function setup:moveOption( direction )
	local e = self.menu[ self.cursor ]
	e.index = e.index + direction
	if e.index > #e.source then
		e.index = 1
	elseif e.index < 1 then
		e.index = #e.source
	end
end
return setup