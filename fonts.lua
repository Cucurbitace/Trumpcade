local fonts = {
	debug = love.graphics.getFont(),
	tweeter = love.graphics.newImageFont( "graphics/font_LilD0t_by_Maiku_Davis.png", " ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789~ˋ!@#$%^&²()-_+=[]{}|\\:;\"'.,<>/?" ),
	basic = love.graphics.newImageFont( "graphics/TorusSansShadow.png", '!"'.."#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_àabcdefghijklmnopqrstuvwxyz{|}~ ©←↵" ),
	dialog = love.graphics.newImageFont( "graphics/TorusSans.png", '!"'.."#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_àabcdefghijklmnopqrstuvwxyz{|}~ ©←↵" ),
	arcade = love.graphics.newImageFont( "graphics/font_arcade.png", "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-+*/=()\"'& ", 1 ),
	score = love.graphics.newImageFont( "graphics/geebeeyay.png", "+0123456789" ),
	tiny = love.graphics.newImageFont( "graphics/tiny_font.png", "1234567890.,", 1 ), -- Debug
}
return fonts