local dbug = {}
function dbug:update( dt )
	-- body
end
function dbug:draw()
	-- body
end
function dbug:keypressed( key )
	if key == "escape" then love.event.quit() end
	if key == "kp+" then
		screen:zoom( 1 )
	elseif key == "kp-" then
		screen:zoom( -1 )
	end
	if key == input.coin then
		credits = credits + 1
	end
	if key == "t" then
		tweeter:type()
	end
end
function dbug:keyreleased( key )

end
return dbug