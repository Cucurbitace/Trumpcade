local player = {
	isJumping = false,
	x = 16,
	y = 288,
	w = 16,
	h = 16,
}
function player:update( dt )
	-- body
end
function player:draw()
	love.graphics.rectangle( "line", self.x, self.y, self.w, self.h )
end
function player:jump()

end
return player