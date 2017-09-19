-- Handle debug functions and display. To be removed from final build.
local dbug = {}
function dbug:update( dt )
	-- body
end
function dbug:draw()
	-- body
end
function dbug:keypressed( key )
	if key == "escape" then love.event.quit() end
	if key == "f12" then staff:switch() end
	if key == "f11" then
		if phase == game1 or phase == game2 or phase == game3 then gameSelect:switch() end
	end
	if key == "u" then
		score = score + 5000000
	end
	if key == "s" then
		currentGame:complete()
	end
	if key == "kp+" then
		screen:zoom( 1 )
	elseif key == "kp-" then
		screen:zoom( -1 )
	end
	if key == "t" then
		tweeter:type()
	end
end
function dbug:keyreleased( key )

end
return dbug