love.filesystem.setIdentity("Adventure")

require("source/library/sound.lua") require("source/library/color.lua") require("source/library/richtext.lua")
require( "source/engine.lua" ) require( "source/game.lua" ) require( "source/world.lua" )
require( "source/scripting.lua" ) require( "source/editor.lua" ) require( "source/draw.lua" )

_r = math.random _f = math.floor _ce = math.ceil _c = math.cos _s = math.sin _sq = math.sqrt _at2 = math.atan2
_d2r = math.rad _r2d = math.deg _m = math.mod pi = math.pi
gr = love.graphics ti = love.timer kb = love.keyboard ms = love.mouse

function love.run()
	print("Entered love.run() at " .. formatTime(os.time()))

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
		gr.present()
		if love.event then
			for e,a,b,c in love.event.poll() do
				if e == "q" then
					if love.audio then love.audio.stop() end
					return
				end
				love.handlers[e](a,b,c)
			end
		end
		ti.sleep(1)
	end
end

--LOAD GAME
function love.load()
	print("Entered love.load() at " .. ti.getTime())

	enableAudio = true

  scrn = {}
  scrn.w = 640
  scrn.h = 400
  scrn.ts = 32
  scrn.tsh = scrn.ts / 2
  scrn.tw = _ce(scrn.w / scrn.ts)
  scrn.th = _ce(scrn.h / scrn.ts)
  scrn.scale = 2

	debugVar = 0 --DEBUG CODE
	debugTilesDrawn = 0
	debugSceneryDrawn = 0

	currentMusic = ""

	testMode = false

	time = ti.getTime()

	math.randomseed(os.time()) _r() _r() _r()

	loadFonts()
	loadImages()
	filterImages()

	changedMessage = ""

	introLength = 2

	if love.filesystem.exists("settings.lua") then
		love.filesystem.load("settings.lua")()
	else
		musicOn = true
		soundOn = true
		soundVolume = 10
		createSettings()
	end

	if enableAudio then loadAudio() end

	love.audio.setVolume(soundVolume/10)

	screenW = gr.getWidth()
	screenH = gr.getHeight()
	gr.setScissor(0, 0, screenW, screenH)
	resString = screenW .. "x" .. screenH

	fb3 = { x = (screenW - 640) / 2, y = (screenH - 480) / 2 }

	tmpName = ""

	mapLoaded = false

	inventory = { opened = false, page = 0, pages = 3, selected = 1 }

	loadSceneryLibrary()

	gameSession = 0

	mapTiles = {}
	mapHit = {}
	mapDeco1 = {}
	mapDeco2 = {}
	for x=0,249 do
		mapTiles[x] = {}
		mapHit[x] = {}
		mapDeco1[x] = {}
		mapDeco2[x] = {}
		for y=0,249 do
			mapTiles[x][y] = ""
			mapHit[x][y] = "x"
			mapDeco1[x][y] = ""
			mapDeco2[x][y] = ""
		end
	end

	savedGameExists = false

	inStartup, inGame, editMode, inLimbo = 0, 1, 100, -1
	gameMode = inLimbo

	loadedGame = -1

	quitSelection = 0

	mpClosed, mpMain, mpScreens, mpOptions, mpQuit = 0, 1, 2, 3, 4
	menu = { opened = false, slide = 0, slideTo = 0, fade = 255, fadeTo = 255, block = 0, blockTo = 0, filmSlide = 0, filmSlideTo = 0, selection = 1, selectionB = 1, page = mpMain, spacing = 0 }
	fade = { to = 255, val = 255, step = 1000, color = 0 }
	cut = { to = 0, val = 0, stat = 0, statTo = 255, step = 150 }

	mapNameFade = 0
	mapNameFadeTo = 0
	mapNameTimer = 0

	closestEnemy = { id = 0, dist = 100000 }

	timeOut = {}
	timeOutSet = {}

	script = {}
	dialog = { opened = false, text = "", x = 0, y = 0, w = 0, h = 0, queryChoice = 1, cursor = 0, speed = 64, location = 1 }

	resetGameVars()

	kb.setKeyRepeat(400,30)

	mapUpdate = function() end
	mapDraw = function() end
	mapUnload = function() end

	print("Finished love.load() at " .. ti.getTime())
end

--UPDATE
function love.update(dt)
  --soundmanager:update(dt)
	animateMenu(dt)
	updateTimeOut()
	sprites = {}

	local editModeKey = kb.isDown("e")

  if gameMode == inLimbo then
    if time > 1 then
      gameMode = inStartup
      logoLoad()
      startupTimer = time
    end
	elseif gameMode == inStartup then
    logoUpdate(dt)
		if time - startupTimer >= introLength then
			if timeOutSet[10010] == nil then
				loadedGame = 1
				love.audio.stop()
				if love.filesystem.exists("savefile.lua") then
					setupGame()
				else
					menu.fadeTo = 255
					menu.fade = 255
					menu.slideTo = 0
					menu.slide = 0
					menu.blockTo = 255
					menu.block = 255
					setTimeOut(3,newGame,10010)
				end
			end
		end
		if editModeKey then
			gameMode = editMode
			loadEditor()
		end
	end
	if gameMode == editMode then --Go into EDIT MODE!!!
		editorUpdate(dt)
	elseif gameMode == inSetup then
		if kb.isDown("lshift") or kb.isDown("rshift") then local kShift = true else local kShift = false end
	elseif gameMode == inGame then
		if dialog.opened == false and scriptRunning == false and inventory.opened == false and menu.opened == false then actionPaused = false else actionPaused = true end

		if editModeKey then
			gameMode = editMode
			loadEditor()
		end

   	updateGameTime(dt)

    mapUpdate()
    updateBounce(dt)
    updateFloaters(dt)

		sprites[1] = player
		sprites[1].n = "Player"

		player.idle = player.idle + dt
		gameSession = time - gameStartTime

		--Calculate NPC AI
		for i, n in pairs(npc) do
			if n.map == mapNumber then
				if n.walking == true and actionPaused == false then
					n.step = n.step % 31 + 1 else n.step = 0
				end

				local ss = #sprites+1
				sprites[ss] = n
				sprites[ss].n = "NPC"
			end
		end

		doFade(dt)
		updateHotZones()
		calculateMapBounds(dt)

		if changeMap == true and fade.val >= 255 then mapUnload() loadMap(mapNumber) end
		if changeMusic ~= mapMusic then
			love.audio.stop()
			setMusic(changeMusic, true)
			mapMusic = changeMusic
		end

		if scriptRunning == false and menu.opened == false then
			if mapNameTimer > 0 then
				mapNameTimer = mapNameTimer - dt
				if mapNameTimer <= 0 then mapNameFadeTo = 0 end
			end
		end

		if actionPaused == false then
      calculateFloaters(dt)

			player.oldXY = tostring(_f(player.x) .. _f(player.y))
			local kLeft = kb.isDown("left")
			local kRight = kb.isDown("right")
			local kUp = kb.isDown("up")
			local kDown = kb.isDown("down")
			if kb.isDown("lshift") or kb.isDown("rshift") then local kShift = true else local kShift = false end

			local tpx, tpy

			player.cx = ((((player.x)/scrn.ts) - _f((player.x)/scrn.ts)) * scrn.ts)-scrn.tsh
			player.cy = ((((player.y-scrn.tsh)/scrn.ts) - _f((player.y-scrn.tsh)/scrn.ts)) * scrn.ts)-scrn.tsh

			if player.knockTime > 0 then
				if player.knockDir == 1 then
					tpx = player.x - 256 * dt
					if checkCol(tpx-15, player.y-31, "Col_Player_Knock_1A") == false and checkCol(tpx-15, player.y, "Col_Player_Knock_1B") == false then player.x = tpx else player.knockTime = 0 end
				elseif player.knockDir == 3 then
					tpx = player.x + 256 * dt
					if checkCol(tpx+15, player.y-31, "Col_Player_Knock_3A") == false and checkCol(tpx+15, player.y, "Col_Player_Knock_3B") == false then player.x = tpx else player.knockTime = 0 end
				elseif player.knockDir == 2 then
					tpy = player.y - 256 * dt
					if checkCol(player.x-15, tpy-31, "Col_Player_Knock_2A") == false and checkCol(player.x+15, tpy-31, "Col_Player_Knock_2B") == false then player.y = tpy else player.knockTime = 0 end
				elseif player.knockDir == 4 then
					tpy = player.y + 256 * dt
					if checkCol(player.x-15, tpy-1, "Col_Player_Knock_4A") == false and checkCol(player.x+15, tpy-1, "Col_Player_Knock_4B") == false then player.y = tpy else player.knockTime = 0 end
				end
				player.knockTime = player.knockTime - 256 * dt
			elseif player.knockTime <= 0 and player.knockDir > -1 then
				player.knockTime = -1
				player.knockDir = -1
			elseif fade.val <= 0 then
				if player.targeting > 0 then
					if kLeft and kRight == false and player.attacking <= 1 then
						player.targetAng = player.targetAng + player.speed * dt
						local npx = enemy[player.targeting].x + (_s((player.targetAng-90) * pi / 180) * player.targetDist) * 1
						local npy = enemy[player.targeting].y + (_c((player.targetAng-90) * pi / 180) * player.targetDist) * 1
						if notInWall(npx,npy) then
							player.x = npx
							player.y = npy
						end
					end
					if kRight and kLeft == false and player.attacking <= 1 then
						player.targetAng = player.targetAng - player.speed * dt
						local npx = enemy[player.targeting].x + (_s((player.targetAng-90) * pi / 180) * player.targetDist) * 1
						local npy = enemy[player.targeting].y + (_c((player.targetAng-90) * pi / 180) * player.targetDist) * 1
						if notInWall(npx,npy) then
							player.x = npx
							player.y = npy
						end
					end
					if kUp and kDown == false and player.attacking <= 1 then
						player.targetDist = player.targetDist - player.speed * dt
						local npx = enemy[player.targeting].x + (_s((player.targetAng-90) * pi / 180) * player.targetDist) * 1
						local npy = enemy[player.targeting].y + (_c((player.targetAng-90) * pi / 180) * player.targetDist) * 1
						if notInWall(npx,npy) then
							player.x = npx
							player.y = npy
						end
					end
					if kDown and kUp == false and player.attacking <= 1 then
						player.targetDist = player.targetDist + player.speed * dt
						local npx = enemy[player.targeting].x + (_s((player.targetAng-90) * pi / 180) * player.targetDist) * 1
						local npy = enemy[player.targeting].y + (_c((player.targetAng-90) * pi / 180) * player.targetDist) * 1
						if notInWall(npx,npy) then
							player.x = npx
							player.y = npy
						end
					end
					local newAng = returnFaceDirFromAng(player.targetAng)
					player.facing = newAng
				else
					if kLeft and kRight == false and player.attacking <= 1 then
						if player.facing ~= 1 then resetPush() end
						tpx = player.x - player.speed * dt
						if checkCol(tpx-15, player.y-16, "Col_Player_Wall_L1") == false and checkCol(tpx-15, player.y-1, "Col_Player_Wall_L2") == false then
							player.x = tpx
							player.moving = true
						else
							player.x = twoDown(player.x)
							player.pushTime = player.pushTime + dt
						end
						if kShift ~= true then player.facing = 1 end
						checkPush(player.x,player.y+16)
					end
					if kRight and kLeft == false and player.attacking <= 1 then
						if player.facing ~= 3 then resetPush() end
						tpx = player.x + player.speed * dt
						if checkCol(tpx+15, player.y-16, "Col_Player_Wall_R1") == false and checkCol(tpx+15, player.y-1, "Col_Player_Wall_R2") == false then
							player.x = tpx
							player.moving = true
						else
							player.x = twoDown(player.x)
							player.pushTime = player.pushTime + dt
						end
						if kShift ~= true then player.facing = 3 end
						checkPush(player.x+scrn.ts,player.y+scrn.tsh)
					end
					if kUp and kDown == false and player.attacking <= 1 then
						if player.facing ~= 2 then resetPush() end
						tpy = player.y - player.speed * dt
						if checkCol(player.x-15, tpy-16, "Col_Player_Wall_U1") == false and checkCol(player.x+15, tpy-16, "Col_Player_Wall_U2") == false then
							player.y = tpy
							player.moving = true
						else
							player.y = twoDown(player.y)
							player.pushTime = player.pushTime + dt
						end
						if kShift ~= true then player.facing = 2 end
						checkPush(player.x,player.y-16)
					end
					if kDown and kUp == false and player.attacking <= 1 then
						if player.facing ~= 4 then resetPush() end
						tpy = player.y + player.speed * dt
						if checkCol(player.x-15, tpy-1, "Col_Player_Wall_D1") == false and checkCol(player.x+15, tpy-1, "Col_Player_Wall_D2") == false then
							player.y = tpy
							player.moving = true
						else
							player.y = twoDown(player.y)
							player.pushTime = player.pushTime + dt
						end
						if kShift ~= true then player.facing = 4 end
						checkPush(player.x,player.y+48)
					end
					if kLeft == false and kRight == false and kUp == false and kDown == false then
						resetPush()
						player.walking = 0
						player.walkframe = 0
						player.moving = false
					end
				end
			end

			if player.moving == true then player.idle = 0 end

			if kb.isDown(" ") then
				if player.attackDone == false then
  				local check = checkForThing()
					if check > 0 and check < 1001 then
						turnNPCToFaceMe(check)
						currentScript = npc[check].script
						check = 0
						player.attackDone = true
					elseif check > 1000 then
						currentScript = switch[check-1000].script
						check = 0
						player.attackDone = true
					elseif player.attacking <= 0 and player.hasMeleeWeapon then
						playSound(10)
						player.attacking = 20
						player.attackDone = true
					end
				end
			end
			if kb.isDown(" ") == false then player.attackDone = false end

			if player.attacking > 0 then
			  player.attacking = player.attacking - player.yoyospeed * dt
        if player.attacking > 8 and player.attacking <= 16 then
          player.yoyo = (8-(player.attacking-8)) * player.yoyodist * player.yoyopow
        elseif player.attacking <= 8 then
          player.yoyo = player.attacking * player.yoyodist * player.yoyopow
        else
          player.yoyo = 0
        end
        if player.facing == 1 then
          player.yyx = -player.yoyo
          player.yyy = 0
        elseif player.facing == 3 then
          player.yyx = player.yoyo
          player.yyy = 0
        elseif player.facing == 2 then
          player.yyx = 0
          player.yyy = -player.yoyo
        elseif player.facing == 4 then
          player.yyx = 0
          player.yyy = player.yoyo
        end
		  end

			if player.invincible > 0 then
				player.invincible = player.invincible - 1 * dt
			end

			if player.pushTime > .05 and player.pushX > -1 and player.pushY > -1 and player.cx > -6 and player.cx < 6 then
				local check = checkForPushSwitch()
				if check > 1000 and check <= 3000 then
					currentScript = switch[check-1000].script
					check = 0
					resetPush()
				elseif check > 3000 and check <= 4000 and player.pushTime > .15 then
					currentScript = pushables[check-3000].script
					movePushable(check-3000,player.facing)
					check = 0
					resetPush()
				end
			end
			updateProjectiles(dt)
			updateBoomerang(dt)

			if tostring(_f(player.x) .. _f(player.y)) ~= player.oldXY then
				player.moving = true
			else
				player.moving = false
				player.walking = 0
        player.walkframe = 0
			end
		end

		--Calculate enemy collision and AI
		for j, e in pairs(enemy) do
			if actionPaused == false then
				if e.inv > 0 then e.inv = e.inv - 1 * dt end
				--Check collision Player with Enemy
				if overlap(_f(e.x-e.w/2), _f(e.y-e.h), e.w, e.h, _f(player.x-scrn.tsh), _f(player.y)-scrn.tsh, scrn.ts, scrn.tsh, "Col_Player_Enemy") == true then hurtPlayer(e.takeHP, 1) end
				--Check for sword hitting enemy
				if player.attacking > 0 then
					hitEnemy = false
					if overlap(_f(player.x+player.yyx-12), _f(player.y+player.yyy-12-24), 24, 24, _f(e.x-scrn.tsh), _f(e.y-scrn.ts), e.w, e.h, "Col_Hit_Enemy_4") == true and e.HP > 0 then hitEnemy = true end
					if hitEnemy == true and e.inv <= 0 then
						knockEnemy(j, player.facing, player.meleePower)
					end
				end
				moveEnemy(j, dt)
			end

			if e.x >= xBounds[0] * scrn.ts and e.x <= xBounds[1] * scrn.ts and e.y >= yBounds[0] * scrn.ts and e.y <= yBounds[1] * scrn.ts and e.HP > 0 then
				local ss = #sprites+1
				sprites[ss] = e
				sprites[ss].n = "Enemy"
			end
		end


		updateDropped(dt)

--		if player.pushTime > 0 then player.moving = false player.walking = 0 end
		if player.moving == true then
		  player.walking = player.walking + 96 * dt % 30
		  player.walkframe = player.walkframe + 16 * dt
		  if player.walkframe >= 4 then player.walkframe = 0 end
	  end

		updateWeather(dt)

		if player.targeting > 0 then
			player.targetDist = distanceFrom(player.x, player.y, enemy[player.targeting].x, enemy[player.targeting].y)
			player.targetAng = findAngle(player.x, player.y, enemy[player.targeting].x, enemy[player.targeting].y)
			player.targetFacingAng = 0
			if player.targetDist > 256 then player.targeting = 0 end
		end

		for j,s in pairs(scenery) do
			local i = #sprites+1
			sprites[i] = s
			sprites[i].n = "Scenery"
		end

		for j, d in pairs(dropped) do
      if bounce[j] then
        local nx, ny = d.x + bounce[j].xslide * dt, d.y + bounce[j].yslide * dt
        if checkCol(nx, d.y, "Col_Bounce_A") == false then
          d.x = nx
        else
          bounce[j].xslide = -bounce[j].xslide
        end
        if checkCol(d.x, ny, "Col_Bounce_B") == false then
          d.y = ny
        else
          bounce[j].yslide = -bounce[j].yslide
        end
      end
			local i = #sprites+1
			sprites[i] = d
			sprites[i].num = j
			sprites[i].n = "Dropped"
		end

    for i, f in pairs(floater) do
			local i = #sprites+1
			sprites[i] = f
			sprites[i].n = "Floater"
    end

		for j, w in pairs(switch) do
			if w.map == mapNumber and w.x >= xBounds[0] * scrn.ts - (scrn.ts*4) and w.x <= xBounds[1] * scrn.ts + (scrn.ts*4) and w.y >= yBounds[0] * scrn.ts - (scrn.ts*4) and w.y <= yBounds[1] * scrn.ts + (scrn.ts*4) then
				local i = #sprites+1
				sprites[i] = w
				sprites[i].sid = j
				sprites[i].n = "Switch"
			end
		end

		for j, e in pairs(explosion) do
			e.f = e.f + 5 * dt
			if e.f > 3 then destroyExplosion(j) end

			local i = #sprites+1
			sprites[i] = e
			sprites[i].n = "Explosion"
		end

		updatePushables(dt)

		for j, p in pairs(pushables) do
			if p.img ~= "" then
				local i = #sprites+1
				sprites[i] = p
				sprites[i].n = "Pushable"
			end
		end

		if player.targeting > 0 then
			sprites[#sprites+1] = { x = enemy[player.targeting].x + mapOffsetX, y = (enemy[player.targeting].y + mapOffsetY - 8), n = "TargetArrow" }
		end

		sort(sprites)

		if chainScript ~= "" and scriptRunning == false then currentScript = chainScript end	--Make sure the scripts chain together
		if currentScript ~= "" and scriptRunning == false then loadScript(currentScript) end	--Load the new script
		if scriptRunning == true then runScript(dt) end																				--Process the script
	end
end

--DRAW
function love.draw(dt)
	if gameMode == inStartup then
		logoDraw()
	elseif gameMode == inGame then
		shakeScreen()
		calculateMapOffset()
		drawMapComposite(dt)
		if menu.opened == false and testMode == false then drawStatusBar(dt) end
		if dialog.opened == true then drawDialog(dt) end
		drawFade()

		if mapNameFade >= 200 and menu.opened == false and dialog.opened == false then
			gr.setBlendMode("alpha")
			gr.setColorMode("modulate")
			gr.setFont(menuFont)
			gr.setColor(255,255,255,150)
			gr.printf(mapName, 2, screenH-130+1, screenW, "center")
			gr.setColor(0,0,0,255)
			gr.printf(mapName, 0, screenH-130, screenW, "center")
		end
		if onScreenTutorialTime > 0 then
		  onScreenTutorialTime = onScreenTutorialTime - 1 * dt
			gr.setBlendMode("alpha")
			gr.setColorMode("modulate")
			gr.setFont(menuFont)
			gr.setColor(0,0,0,255)
			gr.printf(onScreenTutorialMsg, 2, screenH-80+1, screenW, "center")
			gr.setColor(255,255,255,150)
			gr.printf(onScreenTutorialMsg, 0, screenH-80, screenW, "center")
		end

		drawInventory()
	end

	if (menu.fade > 0 or menu.slide > 0) and gameMode ~= inStartup and gameMode ~= editMode and gameMode ~= inLimbo then
		drawMenuScreen()
	end

	if gameMode == editMode then
		editorDraw(dt)
	end

	gr.setColorMode("replace")
	if debugVar > 0 then drawDebug(dt) end --DEBUG CODE
end

--KEYPRESSED
function love.keypressed(k)
	if k == "`" then
	  print("\n\nDEBUG CONSOLE: (Type 'cont' to continue when done)")
    debug.debug()
    print("\n\n")
	end

  if gameMode == inGame then
    if k == "d" then
      debugVar = debugVar + 1
      if debugVar > 2 then debugVar = 0 end
    end --DEBUG CODE

    if k == "e" then
      gameMode = editMode
      loadEditor()
    end

    if menu.opened == true then
      if k == "f" then gr.toggleFullscreen() filterImages() end
      if menu.page == mpMain then
        --Main Menu Page
        if k == "up" then
          menu.selection = menu.selection - 1
          if menu.selection <= 0 then menu.selection = 4 end
          playSound(1)
        elseif k == "down" then
          menu.selection = menu.selection + 1
          if menu.selection >= 5 then menu.selection = 1 end
          playSound(1)
        elseif k == "escape" then
          menu.opened = false
          menu.fadeTo = 0
          menu.slideTo = 0
					cut.statTo = 255
        elseif k == "return" or k == "enter" or k == " " then
          if menu.selection == 1 then
            menu.opened = false
            menu.fadeTo = 0
            menu.slideTo = 0
  					cut.statTo = 0
          elseif menu.selection == 2 then
            menu.fadeTo = 255
            menu.slideTo = 0
            menu.slide = 200
            menu.blockTo = 255
            menu.filmSlideTo = 600
            setTimeOut(1,newGame,00001)
          else
            menu.page = menu.selection
            menu.spacing = 0
          end
          playSound(2)
        end
      elseif menu.page == mpScreens then
        --Options Menu Page
        if k == "up" then

        elseif k == "down" then

        elseif k == "escape" then
          menu.page = mpMain
          menu.spacing = 0
        elseif k == "return" or k == "enter" or k == " " then

        end
      elseif menu.page == mpOptions then
        --New Game Menu Page
        if k == "up" then
          playSound(1)
          menu.selectionB = menu.selectionB - 1
          if menu.selectionB < 1 then menu.selectionB = 6 end
          changedMessage = ""
        elseif k == "down" then
          playSound(1)
          menu.selectionB = menu.selectionB + 1
          if menu.selectionB > 6 then menu.selectionB = 1 end
          changedMessage = ""
        elseif k == "left" then
          if menu.selectionB == 1 then
            musicOn = false
            love.audio.stop()
          elseif menu.selectionB == 2 then
            soundOn = false
          elseif menu.selectionB == 3 then
            soundVolume = soundVolume - 1
            if soundVolume == 0 then soundOn = false musicOn = false end
            if soundVolume < 0 then soundVolume = 0 end
            love.audio.setVolume(soundVolume/10)
          elseif menu.selectionB == 4 then
            if resString == "800x500" then
              createConfiguration(640, 480)
              resString = "640x480"
            else
              createConfiguration(800, 500)
              resString = "800x500"
            end
            changedMessage = "Changes will take effect on restart"
          end
          createSettings()
          playSound(2)
        elseif k == "right" then
          if menu.selectionB == 1 then
            musicOn = true
            setMusic(-1, true)
          elseif menu.selectionB == 2 then
            soundOn = true
          elseif menu.selectionB == 3 then
            soundVolume = soundVolume + 1
            if soundVolume > 10 then soundVolume = 10 end
            love.audio.setVolume(soundVolume/10)
          elseif menu.selectionB == 4 then
            if resString == "800x500" then
              createConfiguration(640, 480)
              resString = "640x480"
            else
              createConfiguration(800, 500)
              resString = "800x500"
            end
            changedMessage = "Changes will take effect on restart"
          end
          createSettings()
          playSound(2)
        elseif k == "escape" then
          menu.page = mpMain
          menu.spacing = 0
					cut.statTo = 0
        elseif k == "return" or k == "enter" or k == " " then
          if menu.selectionB == 1 then
            if musicOn then musicOn = false love.audio.stop() else musicOn = true end
          elseif menu.selectionB == 2 then
            if soundOn then soundOn = false soundVolume = 0 else soundOn = true if soundVolume == 0 then soundVolume = 10 end end
          elseif menu.selectionB == 3 then
            soundVolume = soundVolume + 1
            if soundVolume > 10 then soundVolume = 10 end
          elseif menu.selectionB == 4 then
            menu.page = mpScreens
          elseif menu.selectionB == 5 then
            local var = gr.setMode(screenW, screenH, true, true, 0)
            filterImages()
          elseif menu.selectionB == 6 then
            menu.page = 1
            menu.spacing = 0
          end
          love.audio.setVolume(soundVolume/10)
          setMusic(-1, true)
          playSound(2)
        end
      elseif menu.page == mpQuit then
        --Quit Menu Page
        if k == "down" or k == "up" then
          quitSelection = quitSelection + 1
          if quitSelection > 1 then quitSelection = 0 end
          playSound(1)
        elseif k == "return" or k == "enter" or k == " " then
          if quitSelection == 1 then
            menu.page = mpClosed
            setTimeOut(1, function()
              fade.to = 255
              love.audio.stop()
              love.event.push("q")
            end, 10011)
          elseif quitSelection == 0 then
            menu.page = mpMain
            menu.selection = 1
            menu.spacing = 0
          end
          playSound(2)
        end
      end
    else
      if inventory.opened == false then
        if scriptRunning == false then
          if k == "escape" then
            menu.opened = true
            menu.page = mpMain
            menu.slideTo = 250
            menu.fadeTo = 255
  					cut.statTo = 0
            menu.selection = 1
            player.moving = false
          end

          if k == "c" then collectgarbage("collect") end
          if k == "s" then saveGame() end
          if k == "m" then openInventory() end
          if k == "f" then print(ti.getFPS()) end

          if k == "h" then player.health = player.maxHealth end

          if k == "a" then
            for i=1,50 do
              local x, y = player.x+_r(-100,100), player.y+_r(50,250)
              if checkCol(x,y) == false then
                spawnDropped(_r(1,6),x,y,-1)
              end
            end
          end
          if k == "]" then
            for x=0,mapWidth/scrn.ts-1 do
              for y=0,mapHeight/scrn.ts-1 do
                if _r(1,20) == 1 and checkCol(x*scrn.ts,(y-1)*scrn.ts) == false then
                  createEnemy(_r(1,5), x*scrn.ts, y*scrn.ts, "", true)
                end
              end
            end
          end

          if k == "comma" then
            player.weapon = player.weapon - 1
            if player.weapon < 0 then player.weapon = 2 end
          end
          if k == "period" then
            player.weapon = player.weapon + 1
            if player.weapon > 2 then player.weapon = 0 end
          end

          if k == "," then
            if player.weapon == 0 then
              fireArrow(pArrow, player.facing, 512, 1)
            elseif player.weapon == 1 then
              placeBomb(player.x, player.y-16, 100, 1)
            elseif player.weapon == 2 then
              throwBoomerang(player.boomerangPower * 50, player.facing, player.boomerangPower * 256, 1)
            elseif player.weapon == 3 then
              --
            end
          end
          if k == "x" then fireArrow(pArrow, player.facing, (scrn.ts*8), 1) end
          if k == "b" then placeBomb(player.x, player.y-scrn.tsh, 100, 1) end
          if k == "v" then throwBoomerang(player.boomerangPower * 50, player.facing, player.boomerangPower * (scrn.ts*4), 1) end
          if k == "z" and player.moving == false then
            if player.targeting == 0 then
              local c = findClosestEnemy()
              if c > 0 then
                local d = distanceFrom(player.x, player.y, enemy[c].x, enemy[c].y)
                if d < 256 then player.targeting = c end
              end
            else
              player.targeting = 0
            end
          end
        end

        if dialog.opened == true and queryChoices ~= nil then
          if k == "left" then
            dialog.queryChoice = dialog.queryChoice - 1
            if dialog.queryChoice < 1 then dialog.queryChoice = 1 end
          elseif k == "right" then
            dialog.queryChoice = dialog.queryChoice + 1
            if dialog.queryChoice > table.getn(queryChoices) then dialog.queryChoice = table.getn(queryChoices) end
          end
        end

        if k == " " then
          if dialog.opened == true then
            if dialog.cursor < string.len(dialog.text) then
              dialog.cursor = string.len(dialog.text)
            else
              closeDialog()
              player.attackDone = true
            end
          end
        end
      else --KEYS FOR INVENTORY SCREENS
        if k == "m" then closeInventory() end

        if k == "up" then
          playSound(1)
          inventory.selected = inventory.selected - 10
          if inventory.selected < 1 then inventory.selected = 1 end
        elseif k == "down" then
          playSound(1)
          inventory.selected = inventory.selected + 10
          if inventory.selected > #inventoryList then inventory.selected = #inventoryList end
        elseif k == "left" then
          playSound(1)
          inventory.selected = inventory.selected - 1
          if inventory.selected < 1 then inventory.selected = 1 end
        elseif k == "right" then
          playSound(1)
          inventory.selected = inventory.selected + 1
          if inventory.selected > #inventoryList then inventory.selected = #inventoryList end
        elseif k == "return" or k == " " then
          if inventoryList[inventory.selected].count > 0 then
            inventoryList[inventory.selected].give()
            inventoryList[inventory.selected].count = inventoryList[inventory.selected].count - 1
            if inventoryList[inventory.selected].count < 0 then inventoryList[inventory.selected].count = 0 end
            --closeInventory()
            playSound(2)
          else
            playSound(90)
          end
        elseif k == "z" then
          if inventory.page > 0 then inventory.page = inventory.page - 1 end
        elseif k == "x" then
          if inventory.page < inventory.pages-1 then inventory.page = inventory.page + 1 end
        end
      end
    end
  elseif gameMode == inStartup then
    if k == "d" then
      debugVar = debugVar + 1
      if debugVar > 2 then debugVar = 0 end
    end --DEBUG CODE

  elseif gameMode == editMode then
    editorPressKey(k)
  end
end

function love.mousepressed( x, y, button )
	if gameMode == editMode then
		editorMouseDown(x,y,button)
	elseif gameMode == inGame then
	  if testMode then
      player.x = _f((x-mapOffsetX)/scrn.ts)*scrn.ts
      player.y = _f((y-mapOffsetY)/scrn.ts)*scrn.ts+scrn.ts
    else
      createEnemy(_r(1,5), _f((x-mapOffsetX)/scrn.ts)*scrn.ts, _f((y-mapOffsetY)/scrn.ts)*scrn.ts+scrn.ts, "", true)
    end
	end
end

function love.mousereleased( x, y, button )
	if gameMode == editMode then
		editorMouseUp(x,y,button)
	end
end

function love.focus(f)
  if not f then
    menu.opened = true
    menu.page = mpMain
    menu.slideTo = 250
    menu.fadeTo = 255
    cut.statTo = 0
    menu.selection = 1
    player.moving = false
    print("LOST FOCUS")
  else
    print("GAINED FOCUS")
  end
end
