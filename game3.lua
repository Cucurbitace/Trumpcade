-- Game 3: Doneky Crooked, a Donkey Kong clone.
local game = {
	introIsActive = true,
	stage = 1,
	timer = 0,
}
local levels = require( "game3Data.levels" )
local player = require( "game3Data.player" )
function drawLevel( levels, stage )
	
end
function game:update( dt )
	if self.introIsActive then
		self.timer = self.timer + dt
		if self.timer > 2 then
			self.timer = 0
			self.introIsActive = false
		end
	else
		player.update( dt )
	end
end
function game:draw()
	love.graphics.print( "this is game 3", 10, 50 )
	player:draw()
	printScore( score, fonts.basic )
	if self.introIsActive then
		love.graphics.printf( "Trump Tower\nFloor "..tostring( self.stage * 10 ).."\nGet ready!", 0, 145, 224, "center" )
	end
end
function game:keypressed( key )
	score = score + 5000
	if key == input.b then self:complete() end
end
function game:switch()
	currentGame = self
	phase = self
end
function game:complete()
	gameIsComplete[ 3 ] = true
	if gameIsComplete[ 1 ] and gameIsComplete[ 2 ] and gameIsComplete[ 3 ] then
		--staff:switch()
		switchTo( staff, true )
	else
		gameSelect:setPointer()
		--gameSelect:switch()
		switchTo( gameSelect, true )
	end
end
function game:reset()
	
end
return game