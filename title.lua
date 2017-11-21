-- Title and attract screen.
local sw, sh = 608, 640 -- Width and height of title.png
local title = {
	demos = { love.graphics.newVideo( "videos/demo1.ogg", false ), love.graphics.newVideo( "videos/demo2.ogg", false ), love.graphics.newVideo( "videos/demo3.ogg", false ) },
	demoIndex = 1,
	eagle = love.graphics.newQuad( 224, 450, 180, 190, sw, sh ),
	logo = love.graphics.newQuad( 224, 416, 160, 33, sw, sh ),
	flag = love.graphics.newQuad( 0, 0, 608, 320, sw, sh ),
	wdud = love.graphics.newQuad( 0, 320, 224, 320, sw, sh ),
	portrait = love.graphics.newQuad( 410, 320, 198, 160, sw, sh ),
	page = 1,
	timer = 0,
	r = 255,
	g = 0,
	b = 0,
}
title.glitch = {
	trigger = true,
	timer = 0,
}
function title:colorCycle( dt, speed )
	if self.r == 255 and self.g < 255 and self.b < 255 then
		self.g = self.g + dt * speed
		self.b = self.g
		if self.g > 255 then
			self.g = 254.9
			self.b = 255
			self.r = 254.9
		end
	elseif self.r < 255 and self.b == 255 then
		self.g = self.g - dt * speed
		self.r = self.g
		if self.g < 0 then
			self.g = 0
			self.b = 244.9
			self.r = 0
		end
	elseif self.b < 255 and self.g == 0 then
		self.r = self.r + dt * speed
		self.b = self.b - dt * speed
		if self.r > 255 then
			self.r = 255
			self.b = 0
		end
	end
end
function title:update( dt )
	self.timer = self.timer + dt
	self.wave:send( "time", self.timer )
	self:colorCycle( dt, 350 )
	if self.timer > 2 and self.timer < 3 then
		if self.glitch.trigger then
			self.glitch.trigger = false
			if settings[ 4 ] == 1 then
				sounds.glitch:play()
			end
		end
		self.glitch.timer = self.glitch.timer + dt
		if self.glitch.timer > 0.01 then
			self.glitch.timer = 0
			self.glitch.anim.index = love.math.random( 2, 5 )
		end
	elseif self.timer > 65.5 then
		self.glitch.trigger = true
		self.currentDemo = self.demos[ self.demoIndex ]
		self.currentDemo:play()
		if not self.currentDemo:isPlaying() then
			music:play()
			self.currentDemo:pause()
			self.currentDemo:rewind()
			self.demoIndex = self.demoIndex + 1
			if self.demoIndex > 3 then self.demoIndex = 1 end
			self.currentDemo = nil
			self.glitch.index = 1
			self.timer = 0
		end
	elseif self.timer > 3 then
		self.glitch.anim.index = 6
	end
	if credits > 0 then
		cheatCode:update( dt )
	end
end
function title:draw()
	if self.currentDemo then
		love.graphics.draw( self.currentDemo, 224, 0, math.rad( 90 ) )
	elseif self.timer < 5 then
		love.graphics.draw( sheets.title, self.wdud, 0, 0 )
		self.glitch.anim:draw( 20, 240 )
	else
		love.graphics.setShader( self.wave )
		love.graphics.draw( sheets.title, self.flag, -90, 0 )
		love.graphics.setShader()
		love.graphics.draw( sheets.title, self.logo, 32, 32 )
		love.graphics.setFont( fonts.basic )
		love.graphics.setColor( self.r, self.g, self.b )
		love.graphics.printf( "Make America Great Again", 0 , 72, 224, "center" )
		love.graphics.setColor( 255, 255, 255 )
		if math.floor( self.timer / 10 ) % 2 == 0 then
			love.graphics.draw( sheets.title, self.portrait, 0, 161)
		else
			love.graphics.setColor( 255, 255, 255, 200 )	
			love.graphics.draw( sheets.title, self.eagle, 20, 90 )
			love.graphics.setColor( 255, self.g, 0 )
			love.graphics.printf( "--GREAT OF THE GREAT--", 0, 100, 224, "center" )
			for i = 1, #hiscores do
				love.graphics.setColor( 255, 255, 255 )
				love.graphics.printf( hiscores[ i ].name, 20, 100 + 25 * i - i, 100, "right" )
				love.graphics.setColor( 0, 255, 0 )
				love.graphics.printf( "$"..hiscores[ i ].value, 130, 100 + 25 * i - i, 100, "left" )
			end
			love.graphics.setColor( 255, 255, 255 )
		end
		local invite = ""
		if credits == 0 then
			invite = "INSERT COIN"
		elseif credits == 1 then
			invite = "CREDIT: "..credits.."\nPRESS START"
		else
			invite = "CREDITS: "..credits.."\nPRESS START"
		end
		love.graphics.print( invite, 8, 300 )
	end
end
function title:keypressed( key )
	if key == input.start and credits > 0 then
		credits = credits - 1
		if sounds.glitch:isPlaying() then sounds.glitch:stop() end
		gameSelect:switch( true )
	end
end
function title:switch()
	self.glitch.index = 1
	self.glitch.trigger = true
	self.timer = 0
	if music then music:stop() end
	music = musics.anthem
	if settings[ 4 ] == 1 then
		music:setVolume( 1 )
	else
		music:setVolume( 0 )
	end
	music:play()
	phase = self
end
function title:setShader()
	local shader = [[extern number time;
	extern vec2 inputSize;
	vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords )
	{	
	vec2 uv = texture_coords.xy / inputSize.xy;
	float y = 
		0.7*sin((uv.y + time) * 4.0) * 0.038 +
		0.3*sin((uv.y + time) * 8.0) * 0.010 +
		0.05*sin((uv.y + time) * 40.0) * 0.05;

	float x = 
		0.5*sin((uv.y + time) * 5.0) * 0.1 +
		0.2*sin((uv.x + time) * 10.0) * 0.05 +
		0.2*sin((uv.x + time) * 30.0) * 0.02;

	return color = texture2D(texture, 0.79*(uv + vec2(y+0.11, x+0.11)));
	}]]
	self.wave = love.graphics.newShader( shader )
	self.wave:send( "inputSize", { 1.1, 1.1 } )
end
return title