function love.conf(t)
	t.author = "Jason Anderson"
	t.title = "Untitled Adventure Game"
	t.screen.width = 800
	t.screen.height = 500
	t.console = true
	t.version = 0.7
	t.screen.vsync = false
	t.modules.joystick = false
	t.modules.audio = true
	t.modules.keyboard = true
	t.modules.event = true
	t.modules.image = true
	t.modules.graphics = true
	t.modules.timer = true
	t.modules.mouse = true
	t.modules.sound = true
	t.modules.physics = false
end