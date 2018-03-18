-- Game 3: Doneky Crooked, a Donkey Kong clone.
local bump = require( "libs.bump" )
local image = love.graphics.newImage( "graphics/game3.png" )
local sw, sh = image:getDimensions()
local game = {
	gravity = 50,
	introIsActive = true,
	stage = 1,
	timer = 0,
	foreground = {
		batch = love.graphics.newSpriteBatch( image, 896, "static" ),
		structure = {},
	},
	blocks = {},
}
local x, y = 0, 0
for i = 1, 2 do
	table.insert( game.blocks, love.graphics.newQuad( x, y, 8, 8, sw, sh ) )
	x = x + 8
end
local levels = require( "game3Data.levels" )
local player = require( "game3Data.player" )
function game:addEnemy( x, y, w, h, vx, vy )
	local enemy = { x = x, y = y, w = w, h = h, vx = vx, vy = vy, isFalling = true }
	table.insert( self.enemies, enemy )
	self.world:add( enemy, enemy.x, enemy.y, enemy.w, enemy.h )
end
local function enemyFilter( item, other )
	if other.name == "ground" then
		return "slide"
	end
end
function game:updateEnemies( dt )
	for index, enemy in pairs( self.enemies ) do
		enemy.prevy = enemy.y
		local dx = enemy.x
		local dy = enemy.y + dt * self.gravity
		if not enemy.isFalling then
			dx = enemy.x + dt * enemy.vx
		end
		local cols, len
		enemy.x, enemy.y, cols, len = self.world:move( enemy, dx, dy )
		if enemy.prevy ~= enemy.y then
			if not enemy.isFalling then
				enemy.vx = -enemy.vx
			end
			enemy.isFalling = true
		else
			enemy.isFalling = false
		end
	end
end
function game:createLevel( level )
	self.world = bump.newWorld( 8 )
	self.foreground.batch:clear()
	local x, y = 0, 0
	for _, block in pairs( level ) do
		if block > 0 then
			self.foreground.batch:add( self.blocks[ block ], x, y )
			if block == 1 then
				local ground = { x = x, y = y, w = 8, h = 8, name = "ground" }
				table.insert( self.foreground.structure, ground )
				self.world:add( ground, ground.x, ground.y, ground.w, ground.h )
			end
		end
		x = x + 8
		if x == 224 then
			x = 0
			y = y + 8
		end
	end
end
function game:set()
	self.enemies = {}
	self:createLevel( levels[ 1 ] )
	self:addEnemy( 16, 8, 12, 10, 40, 0 )
end
function game:update( dt )
	if self.introIsActive then
		self.timer = self.timer + dt
		if self.timer > 2 then
			self.timer = 0
			self.introIsActive = false
		end
	else
		self:updateEnemies( dt )
		player.update( dt )
	end
end
function game:draw()
	love.graphics.draw( self.foreground.batch )
	love.graphics.setColor( 0, 255, 0 )
	for _, element in pairs( self.foreground.structure ) do
		love.graphics.rectangle( "line", element.x, element.y, element.w, element.h )
	end
	love.graphics.setColor( 255, 255,255 )
	for _, enemy in pairs( self.enemies ) do
		love.graphics.rectangle( "line", enemy.x, enemy.y, enemy.w, enemy.h )
	end
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
game:set()
return game