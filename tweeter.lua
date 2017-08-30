local tweeter = {
	isActive = false,
}
function tweeter:reset()
	self.tweets = require( "tweets" )
end
tweeter:reset()
function tweeter:type()
	if not self.isActive then
		self.isActive = true
		self.currentTweetIndex = love.math.random( #self.tweets )
		self.currentTweet = self.tweets[ self.currentTweetIndex ]
		self.position = 0
	else
		self.position = self.position + 1
		if self.position == #self.currentTweet.text then
			self.isActive = false
			table.remove( self.tweets, self.currentTweetIndex )
		end
	end
end
function tweeter:update( dt )
	if self.isActive then

	end
end
function tweeter:draw()
	if self.isActive then
		local text = self.currentTweet.text:sub( 1, self.position )
		print( text )
		love.graphics.setColor( 255, 255, 255 )
		love.graphics.rectangle( "fill", 0, 0, 200, 150 )
		love.graphics.setColor( 0, 0, 0 )
		if player.isAlive then
			love.graphics.printf( text, 5, 0, 140, "center" )
		else
			love.graphics.printf( text.."vfefe", 5, 0, 140, "center" )
		end
		love.graphics.setColor( 255, 255, 255 )
	end
end
return tweeter