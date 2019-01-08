local sw, sh = 384, 112
local function newEnemy( x, y, w, h, sw, sh, framesCount )
	local enemy = {}
	for i = 1, framesCount do
		table.insert( enemy, love.graphics.newQuad( x + ( i - 1 ) * w, y, w, h, sw, sh ) )
	end
	return enemy
end
return {
	newEnemy(   0, 16, 16, 32, sw, sh, 2 ), --  1, Worker
	newEnemy(  32, 16, 16, 32, sw, sh, 2 ), --  2, Male luchador
	newEnemy(  64, 16, 16, 32, sw, sh, 2 ), --  3, Padre
	newEnemy(  96, 16, 16, 32, sw, sh, 2 ), --  4, Doctor
	newEnemy( 128, 16, 16, 32, sw, sh, 2 ), --  5, Muerte
	newEnemy( 160, 16, 16, 32, sw, sh, 2 ), --  6, Female luchador
	newEnemy( 192, 16, 16, 32, sw, sh, 2 ), --  7, Wheelchair
	newEnemy( 224, 16, 16, 32, sw, sh, 2 ), --  8, Lumberjack red
	newEnemy( 256, 16, 16, 32, sw, sh, 2 ), --  9, Lumberjack green
	newEnemy( 288, 16, 16, 32, sw, sh, 2 ), -- 10, Lumberjack blue
	newEnemy( 320, 16, 16, 32, sw, sh, 2 ), -- 11, Mountie
	newEnemy( 208, 48, 16, 32, sw, sh, 2 ), -- 12, Bear
	newEnemy( 240, 48, 16, 32, sw, sh, 2 ), -- 13, Indian
}