function newCharacter( game, kind, anim, xstart, ystart, ox, oy, destination, speed, animData, patrolBlock, scatterTime, patrolTime, target )
	local character = {}
	function character:setSpeed( s )
		if self.baseSpeed then
			self.baseSpeed = s
			self.fastSpeed = s * 1.6
		end
		self.speed = s
	end
	local x, y = qx, qy
	character.anim = anim
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
		function character:setBehaviour( behaviour )
			self.movingMode = behaviour
			if behaviour == "scatter" then
				self.behaviourTimer = scatterTime
				self.xTarget = target.x
				self.yTarget = target.y
			elseif behaviour == "patrol" then
				self.xTarget = game.level.blocks[ patrolBlock ].x
				self.yTarget = game.level.blocks[ patrolBlock ].y
			end
		end
		character.xTarget = 0
		character.yTarget = 0
		character.behaviourTimer = scatterTime
		character.scatterTime = scatterTime
		character.patrolTime = patrolTime
		character.patrolBlock = patrolBlock
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
			character.destination = destination + 1
			character.position = destination
			character.origin = destination
			character.destx = xstart + 16
		else
			character.xvel = 0
			character.destination = destination + 1
			character.position = destination
			character.origin = destination
			character.destx = xstart + 16
		end
	end
	-- Colours --
	character.red, character.green, character.blue, character.alpha = 255, 255, 255, 255
	character.operator = 1
	character.power = 0
	-- Animation
	character.rFirst = animData.rFirst
	character.rLast = animData.rLast
	character.lFirst = animData.lFirst
	character.lLast = animData.lLast
	character.uFirst = animData.uFirst
	character.uLast = animData.uLast
	character.dFirst = animData.dFirst
	character.dLast = animData.dLast
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
				-- Alternate between moving modes
				if self.movingMode == "scatter" or self.movingMode == "patrol" then
					self.behaviourTimer = self.behaviourTimer - dt
					if self.behaviourTimer < 0 then
						if self.movingMode == "scatter" then
							self:setBehaviour( "patrol" )
							self.movingMode = "patrol"
							self.behaviourTimer = self.patrolTime
						elseif self.movingMode == "patrol" then
							self:setBehaviour( "scatter" )
							self.movingMode = "scatter"
							self.behaviourTimer = self.scatterTime
						end
					end
				end
				-- Select next direction
				if self.isOnSpot then
					if game.level.blocks[ self.position ].directions then
						local block = game.level.blocks[ self.position ].directions
						local ways = {}
						for _, direction in pairs( block ) do
							if direction ~= self.forbiddenMove then table.insert( ways, direction ) end
						end
						-- Select next move according to current movement behaviour.
						if #ways > 1 then
							if self.movingMode == "scatter" then
								self.nextMove = ways[ love.math.random( #ways ) ]
							elseif self.movingMode == "patrol" then
								self.nextMove = ways[ love.math.random( #ways ) ]
								local gx, tx = math.abs( self.x ), math.abs( self.xTarget )
								local distX = math.max( gx, tx ) - math.min( gx, tx )
								local gy, ty = math.abs( self.y ), math.abs( self.yTarget )
								local distY = math.max( gy, ty ), math.min( gy, ty )
								local shorterDistance = math.min( distX, distY )
								--
								if shorterDistance == distY then
									
								elseif shorterDistance == distX then
									
								end
							elseif self.movingMode == "scared" then

							elseif self.movingMode == "dead" then

							end
						else -- If there is only one move available
							self.nextMove = ways[ 1 ]
						end
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
		self.anim:update( dt )
		-- Movement
		if not self.isOutOfBreath and self.delay == 0 then
			if self.isOnSpot then
				if kind == 0 then
					-- Add trace of the player to the block
					game.level.blocks[ self.position ].playerTrace = 5
					-- Object collection
					if game.level.blocks[ self.position ].hasBonus then 
						local block = game.level.blocks[ self.position ]
						if sounds.pickupCoin:isPlaying() then sounds.pickupCoin:stop() end
						sounds.pickupCoin:play()
						block.hasBonus = false
						game.level.count = game.level.count - 1
						score = score + 10
						table.insert( game.level.points, { value = "+10", x = block.x, y = block.y - 8, alpha = 255 } )
					elseif game.level.blocks[ self.position ].hasPower then
						scareEnemies( game.enemies )
						sounds.pickupPower:play()
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
				if self.position == 464 then
					self:move( 1, 0, 1 )
					self:setAnimation( self.rFirst, self.rLast )
				elseif self.position == 467 then
					self:move( -1, 0, -1 )
					self:setAnimation( self.lFirst, self.lLast )
				elseif self.position == 465 or self.position == 466 or self.position == 405 or self.position == 406 or self.position == 435 or self.position == 436 then
					self:move( 0, -1, -30 )
					self:setAnimation( self.uFirst, self.uLast )
				elseif kind > 0 and ( self.position == 375 or self.position == 376 ) then
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
					self:move( 1, 0, 1 )
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
				self.destination = 452
				self.position = 451
			elseif self.x == game.size then
				self.x = 29 * game.size
				self.destination = 478
				self.position = 479
			end
		end
	end
	function character:draw()
		if self.movingMode == "scared" then
			love.graphics.setColor( 0, 32, 255, self.alpha )
		else
			love.graphics.setColor( self.red, self.green, self.blue, self.alpha )
		end
		self.anim:draw( math.floor( self.x ), math.floor( self.y ), 0, 1, 1, ox, oy )
		--love.graphics.setFont( fonts.tiny )
		--love.graphics.setColor( 0, 0, 0 )
		--love.graphics.print( tostring( self.position ), self.x, self.y )
		--love.graphics.print( tostring( self.destination ), self.x, self.y + 10 )
		--love.graphics.draw( texture, self.frames[ self.index ], math.floor( self.x ), math.floor( self.y ), 0, 1, 1, ox, oy )
		--love.graphics.rectangle( "line", self.x, self.y, 16, 16 )
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
		if first ~= self.anim.first then
			self.anim:set( first, last, pace )
		end
	end
	function character:reset( full )
		self.delay = kind
		self.isAlive = true
		self.red, self.green, self.blue = 255, 255, 255
		self.operator = 1
		self.power = 0
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