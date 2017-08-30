speech_bubble = love.graphics.newImage( "graphics/speech_bubble.png" )
speech_tail_phone = love.graphics.newImage( "graphics/phone_tail.png" )
speech_tail_think = love.graphics.newImage( "graphics/think_tail.png" )
function newSpeechBubble( text, y, tail_style, tail_x, tail_pos, tail_direction, show, hide )
	local tail_image
	local text_y = y + 10
	if tail_style == "phone" then
		tail_image = speech_tail_phone
	elseif tail_style == "normal" then
		tail_image = speech_tail_normal
	elseif tail_style == "think" then
		tail_image = speech_tail_think
	end
	local tail_y
	if tail_pos == 1 then
		tail_y = y - 28
	elseif tail_pos == -1 then
		tail_y = y + 76
	end
	local bubble = {}
	function bubble:draw( t )
		if t >= show and t <= hide then
			love.graphics.draw( tail_image, tail_x, tail_y, 0, tail_direction, tail_pos )
			love.graphics.draw( speech_bubble, 16, y )
			love.graphics.setColor( 0, 0, 0 )
			love.graphics.printf( text, 32, text_y, 160, "center" )
			love.graphics.setColor( 255, 255, 255 )
		end
	end
	return bubble
end