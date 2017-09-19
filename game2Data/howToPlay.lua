-- How to play for game 2
local how = {
	isActive = true,
	timer = 0,
	length = 20,
	text = {
		"Use the joystick to move around.",
		"Press the A button to sprint. But be careful, if you sprint for too long you will run out of stamina and won't be able to move until you rest a bit.",
		"The pussies are tough to grab. You need to pick up a Viagra first, or you will get your ass kicked. The effect don't last long, be fast once you get one!",
		"Presidential word is essential! Press the A button to start a Tweet and mash the buttons to type the Tweet. A Tweet worth a lot of points but you can't do anything else until you complete it.",
	},
	index = 1
}
function how:update( dt )
	controls.joystick:update( dt )
	self.timer = self.timer + dt
	if self.timer < 5 then
		self.index = 1
		if controls.joystick.first ~= 1 then
			print( "error" )
			controls.joystick:set( 1, 4 )
		end
	elseif self.timer < 10 then
		self.index = 2
		if controls.joystick.first ~= 5 then controls.joystick:set( 5, 8 ) end
	elseif self.timer < 15 then
		self.index = 3
		if controls.joystick.first ~= 9 then controls.joystick:set( 9, 12 ) end
	elseif self.timer < 20 then
		self.index = 4
		if controls.joystick.first ~= 13 then controls.joystick:set( 13, 16 ) end
	elseif self.timer > self.length then
		self.isActive = false
	end
end
function how:draw( font )
	love.graphics.setFont( font )
	love.graphics.printf( self.text[ self.index ], 0, 200, 224, "center" )
	controls.joystick:draw( 16, 200 )
end
function how:reset()
	self.isActive = true
	self.timer = 0
end
return how