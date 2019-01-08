local sw, sh = 384, 112
local smoke = {
	sound = love.audio.newSource( "sounds/impact.ogg" ),
	frames = {
		love.graphics.newQuad( 144, 0, 16, 16, sw, sh ),
		love.graphics.newQuad( 160, 0, 16, 16, sw, sh ),
		love.graphics.newQuad( 176, 0, 16, 16, sw, sh ),
		love.graphics.newQuad( 192, 0, 16, 16, sw, sh ),
		love.graphics.newQuad( 208, 0, 16, 16, sw, sh ),
		love.graphics.newQuad( 224, 0, 16, 16, sw, sh ),
		love.graphics.newQuad( 240, 0, 16, 16, sw, sh ),
		love.graphics.newQuad( 256, 0, 16, 16, sw, sh ),
	},
	data = {},
}
function smoke:add( x, y )
	table.insert( self.data, { x = x, y = y, timer = 0, index = 1 } )
	self.sound:play()
end
function smoke:update( dt )
	for index, entry in pairs( self.data ) do
		entry.y = entry.y - dt * 20
		entry.timer = entry.timer + dt
		if entry.timer > 0.05 then
			entry.timer = 0
			entry.index = entry.index + 1
			if entry.index > 8 then
				entry.index = 8
				table.remove( self.data, index )
			end
		end
	end
end
function smoke:draw( sheet )
	for _, entry in pairs( self.data ) do
		love.graphics.draw( sheet, self.frames[ entry.index ], entry.x, math.floor( entry.y ) )
	end
end
return smoke