-- Game 2
local game = {
	phase = "intro",
	timer = 0
}
game.intro = {
	step = 1,
	music = love.audio.newSource( "music/secret_intro.ogg", "stream" )
}
game.intro.sounds = {
	{ name = love.audio.newSource( "sounds/phone_ringing.wav" ), trigger = 0, done = false },
	{ name = love.audio.newSource( "sounds/takeoff.ogg" ), trigger = 34, done = false },
	{ name = love.audio.newSource( "sounds/landing.ogg" ), trigger = 39, done = false },
}
game.intro.bg = {
	newBGImage( "graphics/phone_idle.png", 0, 10, 0, 10 ),
	newBGImage( "graphics/trump_phone.png", 0, 10, 10, 34 ),
	newBGImage( "graphics/putin_phone.png", 0, 170, 14, 34 ),
	newBGImage( "graphics/jfk.png", 0, 0, 34, 39 ),
	newBGImage( "graphics/af1_takeoff.png", -100, 210, 34, 39, 220, -20 ),
	newBGImage( "graphics/moscow.png", 0, 0, 39, 44 ),
	newBGImage( "graphics/af1_landing.png", -100, 180, 39, 44, 220, 30 ),
}
game.intro.bubbles = {
	newSpeechBubble( "Best president ever, here! Who you are? What you want?", 90, "phone", 40, 1, 1, 10, 14 ),
	newSpeechBubble( "Hello Little Bitch, Big Daddy speaking.", 120, "phone", 65, -1, 1, 14, 18 ),
	newSpeechBubble( "Oh, Vlad! I wanted to tell you, I did as you request-", 90, "phone", 40, 1, 1, 18, 22 ),
	newSpeechBubble( "Da. You've been a good boy, that's why I have present for you...", 120, "phone", 65, -1, 1, 22, 26 ),
	newSpeechBubble( "I've setup you favorite one, in the usual hotel in Moscow.", 120, "phone", 65, -1, 1, 26, 30 ),
	newSpeechBubble( "Awesome! You're the man! I'm coming RIGHT NOW!", 90, "phone", 40, 1, 1, 30, 34 )
}
function game:update( dt )
	self.timer = self.timer + dt
	for _, bg in pairs( self.intro.bg ) do
		if bg.update then bg:update( dt, self.timer ) end
	end
	for _, sound in pairs( self.intro.sounds ) do
		if self.timer > sound.trigger and not sound.done then
			sound.done = true
			sound.name:play()
		end
	end
	if self.phase == "intro" and self.timer > 40 then
		self.intro.music:stop()
		self.timer = 0
		self.phase = "game"
	end
end
function game:draw()
	love.graphics.setFont( fonts.dialog ) -- temp
	if self.phase == "intro" then
		love.graphics.print( self.timer)
		--Background
		for _, bg in pairs( self.intro.bg ) do
			bg:draw( self.timer )
		end
		--Dialogs
		for _, bubble in pairs( self.intro.bubbles ) do
			bubble:draw( self.timer )
		end
	elseif self.phase == "game" then
		love.graphics.print( "This is the actual game" )
	end
end
function game:keypressed( key )
	-- body
end
function game:switch()
	phase = self
	self.intro.music:play()
end
return game