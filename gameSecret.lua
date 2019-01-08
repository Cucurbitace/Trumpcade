-- Secret Game
local function newSplash( x, y )
	local splash = { x = x, y = y }
	local angle = math.rad( -love.math.random( 0, 180 ) )
	splash.speed = love.math.random( 35, 40 )
	splash.sx = splash.speed * math.cos( angle )
	splash.sy = splash.speed * math.sin( angle )
	splash.alpha = 255
	function splash:update( dt )
		self.alpha = self.alpha - dt * self.speed * 10
		if self.alpha < 0 then
			self.alpha = 0
			self.isDone = true
		end
		self.x = self.x + self.sx * dt
		self.y = self.y + self.sy * dt
	end
	function splash:draw()
		love.graphics.setColor( 255, 255, 0, self.alpha )
		love.graphics.points( self.x, self.y )
	end
	return splash
end
local function newDrop( x, y, angle, target )
	drop = { x = x, y = y, angle = angle }
	local s = 17 + ( love.math.random( 3 ) - 2 ) 
	local a = math.rad( angle + ( love.math.random( 40 ) - 20 ) / 50 )
	drop.sx = s * math.cos( a )
	drop.sy = s * math.sin( a )
	function drop:update( dt )
		self.sy = self.sy + dt * 60
		if self.sy > s then
			self.sy = s
		end
		self.x = self.x + self.sx * s * dt
		self.y = self.y + self.sy * s * dt
		if self.x > target.x and self.x < target.x + target.w and self.y > target.y then
			self.isOnTarget = true
			score = score + 1
		elseif self.y > 300 then
			self.isOut = true
		end
	end
	function drop:draw()
		love.graphics.setColor( 255, 255, 0 )
		love.graphics.rectangle( "fill", self.x, self.y, 2, 6 )
	end
	return drop
end
function newHooker( x, y, angle, min, max, target )
	local hooker = {}
	local direction = 1
	local splash = {}
	local stream = {}
	local timer = 0
	local limit = love.math.random( 1, 2 )
	local pulse = 0
	local speed = love.math.random( 30, 50 )
	function hooker:update( dt, contact )
		-- Pace of the stream
		timer = timer + dt
		if timer > limit then
			timer = 0
			limit = love.math.random( 1, 4 )
			speed = love.math.random( 2, 4 )
		end
		-- Angle of the stream
		angle = angle + speed * dt * direction
		if angle < min then
			angle = min
			direction = -direction
		elseif angle > max then
			angle = max
			direction = -direction
		end
		-- Stream pulse
		pulse = pulse + dt
		if pulse > 0.03 then
			pulse = 0
			table.insert( stream, newDrop( x, y, angle, target ) )
		end
		-- Update pulse
		for index, drop in pairs( stream ) do
			drop:update( dt )
			if drop.isOut or drop.isOnTarget then
				if drop.isOnTarget then
					contact = contact + 0.1
					if contact > 0.1 then
						contact = 0.1
					end
				end
				for i = 1, 4 do
					table.insert( splash, newSplash( drop.x, drop.y ) )
				end
				table.remove( stream, index )
			end
		end
		-- Update splash
		for index, drop in pairs( splash ) do
			drop:update( dt )
			if drop.isDone then
				table.remove( splash, index )
			end
		end
		return contact
	end
	function hooker:draw( )
		for _, drop in pairs( stream ) do drop:draw() end
		for _, drop in pairs( splash ) do drop:draw() end
	end
	return hooker
end

local pig = { x = 0, y = 240, w = 40, h = 64, speed = 0, pace = 0, direction = 1 }
pig.happy = love.graphics.newImage( "graphics/trump_happy.png" )
pig.angry = love.graphics.newImage( "graphics/trump_angry.png" )
function pig:update( dt )
	if love.keyboard.isDown( input.left ) then
		self.speed = self.speed - dt * 40
		if self.speed < -50 then self.speed = -50 end
	elseif love.keyboard.isDown( input.right ) then
		self.speed = self.speed + dt * 40
		if self.speed > 50 then self.speed = 50 end
	else
		if self.speed > 0 then
			self.speed = self.speed - dt * 100
			if self.speed < 0 then self.speed = 0 end
		elseif self.speed < 0 then
			self.speed = self.speed + dt * 100
			if self.speed > 0 then self.speed = 0 end
		end
	end
	self.x = self.x + self.speed * dt
end
function pig:draw( contact )
	love.graphics.setColor( 255, 255, 255 )
	local image
	if contact == 0 then
		image = self.angry
	else
		image = self.happy
	end
	love.graphics.draw( image, self.x - 8, self.y )
end

local game = {
	hookers = { newHooker( 16, 64, 280, 270, 300, pig ), newHooker( 198, 64, 260, 240, 270, pig ) },
	contact = 0,
	isComplete = false,
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
	for _, bg in pairs( self.intro.bg ) do
		if bg.update then bg:update( dt, self.timer ) end
	end
	for _, sound in pairs( self.intro.sounds ) do
		if self.timer > sound.trigger and not sound.done and self.phase == "intro" then
			sound.done = true
			sound.name:play()
		end
	end
	if self.phase == "intro" and self.timer > 40 then
		self.intro.music:stop()
		self.timer = 40
		self.phase = "game"
	elseif self.phase == "game" then
		self.timer = self.timer - dt
		if self.timer < 0 then
			self:reset()
			--gameSelect:switch()
			switchTo( gameSelect, true )
		end
		self.contact = self.contact - dt
		if self.contact < 0 then self.contact = 0 end
		pig:update( dt )
		for _, hooker in pairs( self.hookers ) do self.contact = hooker:update( dt, self.contact ) end
	else
		self.timer = self.timer + dt
	end
end
function game:draw()
	if self.phase == "intro" then
		love.graphics.print( self.timer)
		--Background
		for _, bg in pairs( self.intro.bg ) do
			bg:draw( self.timer )
		end
		--Dialogs
		love.graphics.setFont( fonts.dialog )
		for _, bubble in pairs( self.intro.bubbles ) do
			bubble:draw( self.timer )
		end
	elseif self.phase == "game" then
		pig:draw( self.contact )
		for _, hooker in pairs( self.hookers ) do hooker:draw() end
		printScore( score, fonts.basic )
		love.graphics.printf( math.ceil( self.timer ), 0, 300, 224, "center" )
	end
end
function game:keypressed( key )
	if key == input.start then
		for _, sound in pairs( self.intro.sounds ) do
			if sound.name:isPlaying() then sound.name:stop() end
		end
		self.intro.music:stop()
		self.phase = "game"
		self.timer = 40
	end
end
function game:complete()
	self.isComplete = true
	--gameSelect:switch()
	switchTo( gameSelect, true )
end
function game:switch()
	currentGame = self
	phase = self
	music = self.intro.music
	music:play()
end
function game:reset()
	self.timer = 0
	self.isComplete = false
	self.contact = 0
end
return game