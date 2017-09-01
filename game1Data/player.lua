function newCharacter( game, kind, sw, sh, qx, qy, xstart, ystart, ox, oy, destination, speed, animData, scream )
	local character = {}
	function character:updateAnim( dt )
		self.timer = self.timer + dt
		if self.timer > self.pace then
			self.timer = 0
			self.index = self.index + 1
			if self.index > self.lastFrame then
				self.index = self.firstFrame
			end
		end
	end
	function character:setSpeed( s )
		if self.baseSpeed then
			self.baseSpeed = s
			self.fastSpeed = s * 1.6
		end
		self.speed = s
	end
	local x, y = qx, qy
	character.scream = love.audio.newSource( scream )
	character.isAlive = true
	if kind == 0 then -- character specific data
		character.destination = destination
		character.position = destination
		character.origin = destination
		character.delay = 0
		character.stamina = 64
		character.lives = 3
		character.isOutOfBreath = false
		character.baseSpeed = speed
		character.fastSpeed = speed * 1.6
		character.nextMove = 0
		character.xvel = 0
		character.destx = xstart
	else -- Ghosts
		function character:setNextMove( block )
			
		end
		character.movingMode = "scatter"
		character.forbiddenMove = 2
		character.nextMove = 1
		character.delay = kind
		if kind == 1 then
			character.xvel = speed
			character.destination = destination + 1
			character.position = destination
			character.origin = destination
			character.destx = xstart + 16
		elseif kind == 4 then
			character.xvel = -speed
		else
			character.xvel = 0
		end
	end
	-- Colours --
	character.red, character.green, character.blue, character.alpha = 255, 255, 255, 255
	character.operator = 1
	character.power = 0
	character.frames = {}
	-- Animation
	character.rFirst = animData.rFirst
	character.rLast = animData.rLast
	character.lFirst = animData.lFirst
	character.lLast = animData.lLast
	character.uFirst = animData.uFirst
	character.uLast = animData.uLast
	character.dFirst = animData.dFirst
	character.dLast = animData.dLast
	for i = 1, animData.frCount do
		local frame = love.graphics.newQuad( x, y, 32, 32, sw, sh )
		table.insert( character.frames, frame )
		x = x + 32
		if i % 4 == 0 then
			x = qx
			y = y + 32
		end
	end
	character.index = 1
	character.firstFrame = 1
	character.lastFrame = 4
	character.timer = 0
	character.pace = 0.1
	-- Movement variables --
	character.speed = speed
	character.isOnSpot = true
	character.x = xstart
	character.y = ystart
	character.yvel = 0
	character.origx = xstart
	character.origy = ystart
	character.desty = ystart
	function character:update( dt )
		-- character specific
		if kind == 0 then
			--Speed and self.stamina
			if self.isOutOfBreath then
				self.pace = 0.35
				self.stamina = self.stamina + dt * 15
				if self.stamina > 64 then
					self.stamina = 64
					self.isOutOfBreath = false
					self:setAnimation( 1, 4 )
					self.xvel = self.xvelTemp
					self.yvel = self.yvelTemp
				end
			elseif self.stamina < 0.1 then
				self:setAnimation( 23, 28, 0.35 )
				self.xvelTemp = self.xvel
				self.yvelTemp = self.yvel
				self.isOutOfBreath = true
				self.xvel = 0
				self.yvel = 0
			else
				if self.isRunning and self.stamina > 0 then
					self.pace = 0.06
					self.stamina = self.stamina - dt * 50
					self.speed = self.fastSpeed
				else
					self.pace = 0.1
					if self.stamina < 64 then
						self.stamina = self.stamina + dt * 20
					elseif self.stamina > 64 then
						self.stamina = 64
					end
					self.speed = self.baseSpeed
				end
			end
		else -- Ghosts IA and direction patterns
			if self.delay > 0 then
				self.delay = self.delay - dt
			else -- Ghosts can move
				self.delay = 0
				if self.isOnSpot then
					if game.level.blocks[ self.position ].directions then
						local block = game.level.blocks[ self.position ].directions
						local ways = {}
						for _, direction in pairs( block ) do
							if direction ~= self.forbiddenMove then table.insert( ways, direction ) end
						end
						self.nextMove = ways[ love.math.random( #ways ) ]
					end
				end
			end
		end
		--Animation
		if self.power > 0 then
			self.green = self.green + dt * 2000 * self.operator
			if self.green > 255 then
				self.green = 255
				self.operator = -1
			elseif self.green < 0 then
				self.green = 0
				self.operator = 1
			end
			self.power = self.power - dt
			if self.power < 0 then
				if kind == 0 then
					setEnemiesMovingMode( game.enemies, "scatter" )
				end
				self.power = 0
				self.speed = self.baseSpeed
				self.green, self.blue = 255, 255
			end
		end
		self:updateAnim( dt )
		-- Movement
		if not self.isOutOfBreath and self.delay == 0 then
			if self.isOnSpot then
				if kind == 0 then
					-- Add trace of the player to the block
					game.level.blocks[ self.position ].playerTrace = 5
					-- Object collection
					if game.level.blocks[ self.position ].hasBonus then 
						local block = game.level.blocks[ self.position ]
						if game.pickupCoin:isPlaying() then game.pickupCoin:stop() end
						game.pickupCoin:play()
						block.hasBonus = false
						game.level.count = game.level.count - 1
						score = score + 10
						table.insert( game.level.points, { value = "+10", x = block.x, y = block.y - 8, alpha = 255 } )
					elseif game.level.blocks[ self.position ].hasPower then
						scareEnemies( game.enemies )
						game.pickupPower:play()
						local block = game.level.blocks[ self.position ]
						self.power = 5
						self.green, self.blue = 0, 0
						self.speed = self.baseSpeed
						block.hasPower = false
						game.level.count = game.level.count - 1
						score = score + 100
						table.insert( game.level.points, { value = "+100", x = block.x, y = block.y - 8, alpha = 255 } )
					end
				end
				-- Restrictions
				if self.position == 434 then
					self:move( 1, 0, 1 )
					self:setAnimation( self.rFirst, self.rLast )
				elseif self.position == 437 then
					self:move( -1, 0, -1 )
					self:setAnimation( self.lFirst, self.lLast )
				elseif self.position == 375 or self.position == 376 or self.position == 405 or self.position == 406 or self.position == 435 or self.position == 436 then
					self:move( 0, -1, -30 )
					self:setAnimation( self.uFirst, self.uLast )
				elseif kind > 0 and ( self.position == 345 or self.position == 346 ) then
					if self.movingMode == "scared" then
						self:move( 0, 1, 30 )
						self.nextMove = 1
					elseif love.math.random( 2 ) > 1 then
						self:move( -1, 0, -1 )
						self:setAnimation( self.lFirst, self.lLast )
						self.nextMove = 3
						self.forbiddenMove = 4
					else
						self:move( 1, 0, 1 )
						self:setAnimation( self.rFirst, self.rLast )
						self.nextMove = 4
						self.forbiddenMove = 3
					end
				elseif self.nextMove == 1 and game.level.blocks[ self.position - 30 ].isPath then
					self:move( 0, -1, -30 )
					self:setAnimation( self.uFirst, self.uLast )
				elseif self.nextMove == 2 and game.level.blocks[ self.position + 30 ].isPath then
					self:move( 0, 1, 30 )
					self:setAnimation( self.dFirst, self.dLast )
				elseif self.nextMove == 3 and game.level.blocks[ self.position - 1 ].isPath then
					self:move( -1, 0, -1 )
					self:setAnimation( self.lFirst, self.lLast )
				elseif self.nextMove == 4 and game.level.blocks[ self.position + 1 ].isPath then
					self:move( 1, 0, 1 )
					self:setAnimation( self.rFirst, self.rLast )
				elseif self.xvel < 0 and game.level.blocks[ self.position - 1 ].isPath then
					self:move( -1, 0, -1 )
				elseif self.xvel > 0 and game.level.blocks[ self.position + 1 ].isPath then
					self:move( 1, 0, 1 )
				elseif self.yvel < 0 and game.level.blocks[ self.position - 30 ].isPath then
					self:move( 0, -1, -30 )
				elseif self.yvel > 0 and game.level.blocks[ self.position + 30 ].isPath then
					self:move( 0, 1, 30 )
				end

			else
				if self.nextMove == 3 and self.xvel > 0 then
					self:reverse()
					self:setAnimation( 11, 16 )
				elseif self.nextMove == 4 and self.xvel < 0 then
					self:reverse()
					self:setAnimation( 5, 10 )
				elseif self.nextMove == 1 and self.yvel > 0 then
					self:reverse()
					self:setAnimation( 29, 34 )
				elseif self.nextMove == 2 and self.yvel < 0 then
					self:reverse()
					self:setAnimation( 17, 22 )
				end
			end
			if self.xvel ~= 0 then
				self.x = self.x + dt * self.xvel
			elseif self.yvel ~= 0 then
				self.y = self.y + dt * self.yvel
			end
			if math.abs( self.x - self.origx ) > game.size or math.abs( self.y - self.origy ) > game.size then
				self.isOnSpot = true
				self.position = self.destination
				self.x = self.destx
				self.y = self.desty
			end
			if self.x > 29 * game.size then
				self.x = game.size
				self.destination = 422
				self.position = 421
			elseif self.x == game.size then
				self.x = 29 * game.size
				self.destination = 448
				self.position = 449
			end
		end
	end
	function character:draw( texture )
		if self.movingMode == "scared" then
			love.graphics.setColor( 0, 32, 255, self.alpha )
		else
			love.graphics.setColor( self.red, self.green, self.blue, self.alpha )
		end
		love.graphics.draw( texture, self.frames[ self.index ], math.floor( self.x ), math.floor( self.y ), 0, 1, 1, ox, oy )
		--love.graphics.rectangle( "line", self.x, self.y, 32, 32 )
	end
	function character:move( dx, dy, destination )
		if kind > 0 then
			if self.nextMove == 1 then
				self.forbiddenMove = 2
			elseif self.nextMove == 2 then
				self.forbiddenMove = 1
			elseif self.nextMove == 3 then
				self.forbiddenMove = 4
			elseif self.nextMove == 4 then
				self.forbiddenMove = 3
			end
		end
		self.isOnSpot = false
		self.xvel = dx * self.speed
		self.yvel = dy * self.speed
		self.origin = self.position
		self.destination = self.position + destination
		self.origx = self.x
		self.origy = self.y
		self.destx = self.x + dx * game.size
		self.desty = self.y + dy * game.size
	end
	function character:reverse()
		self.xvel = -self.xvel
		self.yvel = -self.yvel
		self.destx, self.origx = self.origx, self.destx
		self.desty, self.origy = self.origy, self.desty
		self.destination, self.origin = self.origin, self.destination
	end
	function character:setAnimation( first, last, pace )
		self.pace = pace or 0.1
		if self.firstFrame ~= first and self.lastFrame ~= last then
			self.index = first
			self.firstFrame = first
			self.lastFrame = last
		end
	end
	function character:reset( full )
		self.delay = kind
		self.isAlive = true
		self.red, self.green, self.blue = 255, 255, 255
		self.operator = 1
		self.power = 0
		self.index = 1
		self.firstFrame = 1
		self.lastFrame = 4
		self.timer = 0
		self.pace = 0.1
		self.isOnSpot = true
		self.speed = self.baseSpeed or speed
		self.xvel = 0
		self.yvel = 0
		self.x = xstart
		self.y = ystart
		self.origx = xstart
		self.origy = ystart
		self.destx = xstart
		self.desty = ystart
		self.destination = destination
		self.position = destination
		self.origin = destination
		self.nextMove = 0
		if full then
			self.lives = 3
		end
	end
	return character
end