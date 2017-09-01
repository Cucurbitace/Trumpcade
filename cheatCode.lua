function newCheatCode( command, sequence, delay )
	local timer, index = 0, 1
	local code = {}
	function code:update( dt, flag )
		if not flag then
			timer = timer - dt
			if timer < 0 then
				timer = 0
				index = 1
			end
			for i, key in pairs( sequence ) do
				if love.keyboard.isDown( key ) and index == 1 then
					timer = delay
					index = 2
				elseif love.keyboard.isDown( key ) and index > #sequence then
					command()
				elseif love.keyboard.isDown( key ) and i == index then
					timer = delay
					index = index + 1
				end
			end
		end
	end
	return code
end