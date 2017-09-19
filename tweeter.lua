local tweeter = { isActive = false, x = 20, y = 20, xMax = 60, yMax = 230, width = 160, height = 40, isFading = false, comboMultiplier = 1, comboBonus = 1000 }
tweeter.image = love.graphics.newImage( "graphics/tweet.png" )
function tweeter:reset()
	self.tweets = require( "tweets" )
end
tweeter:reset()
function tweeter:resetCombo()
	self.comboMultiplier = 1
end
function tweeter:type( x, y )
	if not self.isFading then
		if not self.isActive then
			self.alpha = 255
			self.x = x - 100
			if self.x > self.xMax then
				self.x = self.xMax
			elseif self.x < 0 then
				self.x = 0
			end
			self.y = y - 100

			if self.y > self.yMax then
				self.y = self.yMax
			elseif self.y < 10 then
				self.y = 10
			end
			self.isActive = true
			self.currentTweetIndex = love.math.random( #self.tweets )
			self.currentTweet = self.tweets[ self.currentTweetIndex ]
			self.position = 0
		else
			self.position = self.position + 1
			if self.position == #self.currentTweet.text then
				self.isActive = false
				self.isFading = true
				score = score + self.comboBonus * self.comboMultiplier
			end
		end
	end
end
function tweeter:update( dt )
	if self.isFading then
		self.y = self.y - dt * 20
		self.alpha = self.alpha - dt * 400
		if self.alpha < 0 then
			self.isFading = false
			self:remove( score )
		end
	end
end
function tweeter:remove()
	table.remove( self.tweets, self.currentTweetIndex )
end
function tweeter:draw( player, mainFont, secondaryFont )
	if self.isFading or self.isActive then
		love.graphics.setFont( mainFont )
		local text = self.currentTweet.text:sub( 1, self.position )
		love.graphics.setColor( 255, 255, 255, self.alpha )
		love.graphics.draw( self.image, self.x, self.y, 0, 1, 1, 0, 20 )
		love.graphics.setColor( 0, 0, 0, self.alpha )
		if player.isAlive then
			love.graphics.printf( text, self.x, self.y, self.width, "center" )
		else
			love.graphics.printf( text.."vfefe", self.x, self.y, self.width, "center" )
		end
		love.graphics.setColor( 117, 198, 242, self.alpha )
		love.graphics.setFont( secondaryFont )
		love.graphics.print( self.currentTweet.like, self.x, self.y, 0, 1, 1, -5, -44 )
		love.graphics.print( self.currentTweet.retweet, self.x, self.y, 0, 1, 1, -27, -44 )
		love.graphics.setColor( 255, 255, 255 )
	end
end
return tweeter