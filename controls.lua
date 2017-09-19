-- Controls display for How To Plays
local controls = {
	image = love.graphics.newImage( "graphics/controls.png" ),
}
local sw, sh = controls.image:getDimensions()
controls.joystick = newAnimation( controls.image, 32, 32, 0.1, 16, 0, 0, 128, 128, 1, 4 )
return controls