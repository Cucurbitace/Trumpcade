function newEnemy( x, y, pos )
	local enemy = {}
	enemy.x = x * size
	enemy.y = y * size
	enemy.position = pos
	enemy.timer = 0
	enemy.index = 1
	enemy.firstFrame = 1
	enemy.lastFrame = 5
	enemy.pace = 0.05
	enemy.mode = "scatter" -- Can be "chase" or "running" too
	enemy.id = goblins:add( goblin[ 1 ], enemy.x - 16, enemy.y -16 )
	function enemy:update( dt )
		self.timer = self.timer + dt
		if self.timer > self.pace then
			self.timer = 0
			self.index = self.index + 1
			goblins:set( self.id, goblin[ self.index ], self.x - 16, self.y - 16 )
			if self.index > self.lastFrame then
				self.index = self.firstFrame
			end
		end
	end
	return enemy
end