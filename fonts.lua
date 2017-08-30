local fonts = {}
fonts.debug = love.graphics.getFont()
fonts.basic = love.graphics.newImageFont( "graphics/TorusSansShadow.png", '!"'.."#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_àabcdefghijklmnopqrstuvwxyz{|}~ ©←↵" )
fonts.dialog = love.graphics.newImageFont( "graphics/TorusSans.png", '!"'.."#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_àabcdefghijklmnopqrstuvwxyz{|}~ ©←↵" )
return fonts