function love.conf(t)
	t.identity = nil
	t.appendidentity = false
	t.version = "11.3"
	t.console = true
	t.accelerometerjoystick = false
	t.externalstorage = false
	t.modules.audio = false
	t.modules.data = true
	t.modules.event = true
	t.modules.font = false
	t.modules.graphics = false
	t.modules.image = false
	t.modules.joystick = false
	t.modules.keyboard = false
	t.modules.math = true
	t.modules.mouse = false
	t.modules.physics = false
	t.modules.sound = false
	t.modules.system = true
	t.modules.thread = false
	t.modules.timer = true
	t.modules.touch = false
	t.modules.video = false
	t.modules.window = false
end
