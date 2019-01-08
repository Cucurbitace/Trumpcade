local max = math.rad( 360 )
local snow = {
	data = {},
}
for i = 0, 2048 do
	table.insert( snow.data, { x = love.math.random( 0, 224 ), y = love.math.random( 0, 320 ), angle = math.rad( love.math.random( 360 ) ) } )
end
function snow:update( dt )
	for _, flake in pairs( self.data ) do
		flake.angle = flake.angle + dt * 10
		if flake.angle > max then
			flake.angle = flake.angle - max
		end
		flake.y = flake.y + dt * 20
		flake.x = flake.x + math.cos( flake.angle )
		if flake.y > 320 then
			flake.y = flake.y - 320
		end
	end
end
function snow:draw()
	for _, flake in pairs( self.data ) do
		love.graphics.points( flake.x, flake.y )
	end
end
return snow