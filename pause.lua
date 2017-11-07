local pause = {
	isActive = false
}
function pause:set( audios )
	self.isActive = not self.isActive
	for _, audio in pairs( audios ) do
		for _, source in pairs( audio ) do
			if source:isPlaying() then
				source:pause()
			elseif source:isPaused() then
				source:play()
			end
		end
	end
end
function pause:draw()
	if self.isActive then
		love.graphics.setColor( 0, 0, 0, 96 )
		love.graphics.rectangle( "fill", 0, 0, 224, 320 )
		love.graphics.setColor( 255, 255, 255 )
	end
end
return pause