require( "game/engine.lua" ) require( "game/game.lua" ) require( "game/draw.lua" )
require( "game/world.lua" ) require( "game/scripting.lua" ) require( "game/editor.lua" )
love.filesystem.setIdentity("Adventure")

_r = math.random _f = math.floor _c = math.cos _s = math.sin _sq = math.sqrt _at2 = math.atan2 _d2r = math.rad _r2d = math.deg _m = math.mod pi = math.pi
gr = love.graphics ti = love.timer kb = love.keyboard

function love.run()
	print("Entered love.run() at " .. formatTime(os.time()))
	screenModes = gr.getModes()
	enableAudio = love.filesystem.exists("game/audio/")
	firstRun = false
	if love.filesystem.exists("conf.lua") == false then
		local sw = 800 sh = 500
		createConfiguration(sw, sh)
		local _ = gr.setMode(sw, sh, false, true, 0)
		firstRun = true
	end
	love.load(arg)
	if arg[2] == "-edit" then end
	local dt = 0
	while true do
		ti.step()
		time = ti.getTime()
		dt = ti.getDelta()
		gr.clear()
		love.update(dt)
		love.draw(dt)
		if love.event then
			for e,a,b,c in love.event.poll() do
				if e == "q" then
					if love.audio then love.audio.stop() end
					print("Quit Game (Current Mode: " .. gameMode .. ") at " .. formatTime(time) .. "\n- END GAME ------------------------------------\n\n")
					return
				end
				love.handlers[e](a,b,c)
			end
		end
		ti.sleep(1)
		gr.present()
	end
end