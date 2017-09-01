-- Game 3
local game = {}

function game:update( dt )
	-- body
end
function game:draw()
	love.graphics.print( "this is game 3", 10, 50 )
	printScore( score, fonts.basic )
end
function game:keypressed( key )
	-- body
end
function game:switch()
	currentGame = self
	phase = self
end
function game:complete()
	gameIsComplete[ 3 ] = true
	if gameIsComplete[ 1 ] and gameIsComplete[ 2 ] and gameIsComplete[ 3 ] then
		staff:switch()
	else
		print( gameIsComplete[ 1 ], gameIsComplete[ 2 ], gameIsComplete[ 3 ] )
		gameSelect:setPointer()
		gameSelect:switch()
	end
end
function game:reset()
	
end
return game