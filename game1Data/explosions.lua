local sw, sh = 384, 112
local explosions = {
	data = {},
	frames = {
		love.graphics.newQuad(   0, 80, 32, 32, sw, sh ),
		love.graphics.newQuad(  32, 80, 32, 32, sw, sh ),
		love.graphics.newQuad(  64, 80, 32, 32, sw, sh ),
		love.graphics.newQuad(  96, 80, 32, 32, sw, sh ),
		love.graphics.newQuad( 128, 80, 32, 32, sw, sh ),
		love.graphics.newQuad( 160, 80, 32, 32, sw, sh ),
		love.graphics.newQuad( 192, 80, 32, 32, sw, sh ),
		love.graphics.newQuad( 224, 80, 32, 32, sw, sh ),
		love.graphics.newQuad( 256, 80, 32, 32, sw, sh ),
		love.graphics.newQuad( 288, 80, 32, 32, sw, sh ),
		love.graphics.newQuad( 320, 80, 32, 32, sw, sh ),
		love.graphics.newQuad( 352, 80, 32, 32, sw, sh ),
	}
}
function explosions:add( x, y )
	table.insert( self.data, { x = x - 8, y = y - 8, timer = 0, index = 1 } )
end
function explosions:update( dt )
	for index, explosion in pairs( self.data ) do
		explosion.timer = explosion.timer + dt
		if explosion.timer > 0.05 then
			explosion.timer = 0
			explosion.index = explosion.index + 1
			if explosion.index > 12 then
				explosion.index = 12
				table.remove( self.data, index )
			end
		end
	end
end
function explosions:draw( sheet )
	for _, explosion in pairs( self.data ) do
		love.graphics.draw( sheet, self.frames[ explosion.index ], explosion.x, explosion.y )
	end
end
function explosions:reset()
	self.data = {}
end
return explosions