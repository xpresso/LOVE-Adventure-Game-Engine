--LOAD GAME
function love.load()
	print("Entered love.load() at " .. ti.getTime())
	debugVar = 0 --DEBUG CODE
	debugTilesDrawn = 0
	debugSceneryDrawn = 0
	debugConsole = false
	debugConsoleText = ""

	currentMusic = ""

	testMode = false

	time = ti.getTime()

	math.randomseed(os.time())

	loadFonts()
	loadImages()
	filterImages()

	changedMessage = ""

	introLength = 2

	if love.filesystem.exists("settings.lua") then
		love.filesystem.load("settings.lua")()
	else
		musicOn = false
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

	inventory = { opened = false, page = 0, pages = 3, selected = 0 }

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

	inStartup, inGame, editMode = 0, 1, 100
	gameMode = inStartup

	loadedGame = -1

	quitSelection = 0

	mpClosed, mpMain, mpScreens, mpOptions, mpQuit = 0, 1, 2, 3, 4
	menu = { opened = false, slide = 0, slideTo = 0, fade = 255, fadeTo = 255, block = 0, blockTo = 0, filmSlide = 0, filmSlideTo = 0, selection = 1, selectionB = 1, page = mpMain, spacing = 0 }
	fade = { to = 255, val = 255, step = 1000, color = 0 }
	cut = { to = 0, val = 0, step = 150 }

	mapNameFade = 0
	mapNameFadeTo = 0
	mapNameTimer = 0

	closestEnemy = { id = 0, dist = 100000 }

	timeOut = {}
	timeOutSet = {}

	script = {}
	dialog = { opened = false, text = "", x = 0, y = 0, w = 0, h = 0, queryChoice = 1, cursor = 0, speed = 128, location = 1 }

	resetGameVars()

	kb.setKeyRepeat(400,30)

	if gameMode == inStartup then
		logoLoad()
		startupTimer = time
	end
	print("Finished love.load() at " .. ti.getTime())

	mapUpdate = function() end
	mapDraw = function() end
	mapUnload = function() end
end

--UPDATE
function love.update(dt)
	animateMenu(dt)
	updateTimeOut()
	sprites = {}

	local editModeKey = kb.isDown("e")

	if gameMode == inStartup then
		if logoExists == true then logoUpdate(dt) end
		if time - startupTimer >= introLength then
			if timeOutSet[10010] == nil then
				loadedGame = 1
				love.audio.stop()
				if love.filesystem.exists("savefile.lua") then
					setTimeOut(1,setupGame,10010)
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
			player.oldXY = tostring(_f(player.x) .. _f(player.y))
			local kLeft = kb.isDown("left")
			local kRight = kb.isDown("right")
			local kUp = kb.isDown("up")
			local kDown = kb.isDown("down")
			if kb.isDown("lshift") or kb.isDown("rshift") then local kShift = true else local kShift = false end

			local tpx, tpy

			player.cx = ((((player.x+16)/32) - _f((player.x+16)/32)) * 32)-16
			player.cy = ((((player.y-16)/32) - _f((player.y-16)/32)) * 32)-16

			if player.knockTime > 0 then
				if player.knockDir == 1 then
					tpx = player.x - 256 * dt
					if checkCol(tpx, player.y-31, 9901) == false and checkCol(tpx, player.y, 9902) == false then player.x = tpx else player.knockTime = 0 end
				elseif player.knockDir == 3 then
					tpx = player.x + 256 * dt
					if checkCol(tpx+31, player.y-31, 9903) == false and checkCol(tpx+31, player.y, 9904) == false then player.x = tpx else player.knockTime = 0 end
				elseif player.knockDir == 2 then
					tpy = player.y - 256 * dt
					if checkCol(player.x, tpy-31, 9905) == false and checkCol(player.x + 31, tpy-31, 9906) == false then player.y = tpy else player.knockTime = 0 end
				elseif player.knockDir == 4 then
					tpy = player.y + 256 * dt
					if checkCol(player.x, tpy-1, 9907) == false and checkCol(player.x + 31, tpy-1, 9908) == false then player.y = tpy else player.knockTime = 0 end
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
						if checkCol(tpx+1, player.y-16, 9909) == false and checkCol(tpx+1, player.y-1, 9910) == false then
							player.x = tpx
							player.moving = true
						else
--							player.x = (_f(tpx / 32)+1) * 32
							player.x = twoDown(player.x)
							player.pushTime = player.pushTime + dt
						end
						if kShift ~= true then player.facing = 1 end
						checkPush(player.x-16,player.y+16)
					end
					if kRight and kLeft == false and player.attacking <= 1 then
						if player.facing ~= 3 then resetPush() end
						tpx = player.x + player.speed * dt
						if checkCol(tpx+31, player.y-16, 9911) == false and checkCol(tpx+31, player.y-1, 9912) == false then
							player.x = tpx
							player.moving = true
						else
--							player.x = (_f(tpx / 32)) * 32
							player.x = twoDown(player.x)
							player.pushTime = player.pushTime + dt
						end
						if kShift ~= true then player.facing = 3 end
						checkPush(player.x+48,player.y+16)
					end
					if kUp and kDown == false and player.attacking <= 1 then
						if player.facing ~= 2 then resetPush() end
						tpy = player.y - player.speed * dt
						if checkCol(player.x+1, tpy-16, 9913) == false and checkCol(player.x+31, tpy-16, 9914) == false then
							player.y = tpy
							player.moving = true
						else
--							player.y = ((_f(tpy / 32)+1) * 32)
							player.y = twoDown(player.y)
							player.pushTime = player.pushTime + dt
						end
						if kShift ~= true then player.facing = 2 end
						checkPush(player.x+16,player.y-16)
					end
					if kDown and kUp == false and player.attacking <= 1 then
						if player.facing ~= 4 then resetPush() end
						tpy = player.y + player.speed * dt
						if checkCol(player.x+1, tpy-1, 9915) == false and checkCol(player.x+31, tpy-1, 9916) == false then
							player.y = tpy
							player.moving = true
						else
--							player.y = ((_f(tpy / 32)) * 32)
							player.y = twoDown(player.y)
							player.pushTime = player.pushTime + dt
						end
						if kShift ~= true then player.facing = 4 end
						checkPush(player.x+16,player.y+48)
					end
					if kLeft == false and kRight == false and kUp == false and kDown == false then
						resetPush()
						player.walking = 0
						player.moving = false
					end
				end
			end

			if player.moving == true then player.idle = 0 end

			if kb.isDown(" ") then
				local check = checkForThing()
				if player.attackDone == false then
					if check > 0 and check < 1001 then
						turnNPCToFaceMe(check)
						currentScript = npc[check].script
						check = 0
						player.attackDone = true
					elseif check > 1000 then
						currentScript = switch[check-1000].script
						check = 0
						player.attackDone = true
					elseif player.attacking <= 0 then
						playSound(10)
						player.attacking = 10
						player.attackDone = true
					end
				end
			end
			if kb.isDown(" ") == false then player.attackDone = false end

			if player.attacking > 0 then player.attacking = player.attacking - 1 end

			if player.invincible > 0 then
				player.invincible = player.invincible - 1
				if player.invAnim == 0 then player.invAnim = 1 else player.invAnim = 0 end
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
			end
		end

		--Calculate enemy collision and AI
		for j, e in pairs(enemy) do
			if actionPaused == false then
				if e.inv > 0 then e.inv = enemy[j].inv - 1 end
				--Check collision Player with Enemy
				if overlap(_f(e.x), _f(e.y-32), e.w, e.h, _f(player.x)+4, _f(player.y)-28, 24, 24, 7901) == true then hurtPlayer(e.takeHP, 1) end
				--Check for sword hitting enemy
				if player.attacking > 0 then
					hitEnemy = false
					if player.facing == 1 then
						if overlap(_f(player.x-32), _f(player.y-32), 48, 32, _f(e.x), _f(e.y-32), e.w, e.h, 7902) == true and enemy[j].HP > 0 then hitEnemy = true end
					elseif player.facing == 3 then
						if overlap(_f(player.x+16), _f(player.y-32), 48, 32, _f(e.x), _f(e.y-32), e.w, e.h, 7903) == true and enemy[j].HP > 0 then hitEnemy = true end
					elseif player.facing == 2 then
						if overlap(_f(player.x), _f(player.y-64), 32, 48, _f(e.x), _f(e.y-32), e.w, e.h, 7904) == true and enemy[j].HP > 0 then hitEnemy = true end
					elseif player.facing == 4 then
						if overlap(_f(player.x), _f(player.y-16), 32, 48, _f(e.x), _f(e.y-32), e.w, e.h, 7905) == true and enemy[j].HP > 0 then hitEnemy = true end
					end
					if hitEnemy == true and e.inv <= 0 then
						knockEnemy(j, player.facing, player.swordPower)
					end
				end
				moveEnemy(j, dt)
			end

			if e.x >= xBounds[0] * 32 and e.x <= xBounds[1] * 32 and e.y >= yBounds[0] * 32 and e.y <= yBounds[1] * 32 and e.HP > 0 then
				local ss = #sprites+1
				sprites[ss] = e
				sprites[ss].n = "Enemy"
			end
		end


		updateDropped(dt)

--		if player.pushTime > 0 then player.moving = false player.walking = 0 end
		if player.moving == true then player.walking = player.walking % 30 + 1 end

		updateWeather(dt)

		if player.targeting > 0 then
			player.targetDist = distanceFrom(player.x, player.y, enemy[player.targeting].x, enemy[player.targeting].y)
			player.targetAng = findAngle(player.x, player.y, enemy[player.targeting].x, enemy[player.targeting].y)
			player.targetFacingAng = 0
			if player.targetDist > 256 then player.targeting = 0 end
		end

		for j,s in pairs(scenery) do
			if player.x > s.x - 32 and player.x < s.x + 32 and player.y > s.y - 32 and player.y < s.y + 32 then
				if debugVar == 2 then
					gr.setColor(255,255,0,255)
					gr.rectangle("fill", s.x-32+mapOffsetX, s.y-32+mapOffsetY, 64, 64)
				end
			end

			local i = #sprites+1
			sprites[i] = s
			sprites[i].n = "Scenery"
		end

		for j, d in ipairs(dropped) do
			local i = #sprites+1
			sprites[i] = d
			sprites[i].n = "Dropped"
		end

		for j, w in pairs(switch) do
			if w.map == mapNumber and w.x >= xBounds[0] * 32 - 128 and w.x <= xBounds[1] * 32 + 128 and w.y >= yBounds[0] * 32 - 128 and w.y <= yBounds[1] * 32 + 128 then
				local i = #sprites+1
				sprites[i] = w
				sprites[i].sid = j
				sprites[i].n = "Switch"
			end
		end

		for j, e in ipairs(explosion) do
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
			sprites[#sprites+1] = { x = enemy[player.targeting].x + mapOffsetX + 16, y = _f(enemy[player.targeting].y + mapOffsetY - 8) + _s(time*5)*3, n = "TargetArrow" }
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
		if logoExists then logoDraw() end
	elseif gameMode == inGame then
		shakeScreen()
		calculateMapOffset()
		drawMapComposite(dt)
		if menu.opened == false and testMode == false then drawStatusBar() end
		drawFade()
		if dialog.opened == true then drawDialog(dt) end
		drawInventory()

		if mapNameFade >= 200 and menu.opened == false then
			gr.setBlendMode("alpha")
			gr.setColorMode("modulate")
			gr.setFont(menuFont)
			gr.setColor(255,255,255,150)
			gr.printf(mapName, 2, screenH-120+1, screenW, "center")
			gr.setColor(0,0,0,255)
			gr.printf(mapName, 0, screenH-120, screenW, "center")
		end
	end

	if (menu.fade > 0 or menu.slide > 0) and gameMode ~= inStartup and gameMode ~= editMode then
		drawMenuScreen()
	end

	if gameMode == editMode then
		editorDraw(dt)
	end

	gr.setColorMode("replace")
	if debugVar > 0 then drawDebug(dt) end --DEBUG CODE
	if debugConsole then
		gr.setBlendMode("alpha")
		gr.setColorMode("modulate")
		gr.setColor(0,0,0,100)
		gr.rectangle("fill",0,0,screenW,screenH)
		gr.setColor(255,255,255,255)
		gr.setFont(mono)
		local cur
		if _f(time*8 % 2) == 1 then
			cur = "_"
		else
			cur = ""
		end
		gr.print("Debug Console:\n> " .. debugConsoleText .. cur, 20, 30)
	end
end

--KEYPRESSED
function love.keypressed(k)
	if k == "`" then
		if debugConsole == true then debugConsole = false else debugConsole = true end
		k = ""
	end
	if debugConsole then
		if kb.isDown("lshift") or kb.isDown("rshift") or kb.isDown("capslock") then
			if k == "9" then
				k = "("
			elseif k == "0" then
				k = ")"
			elseif k == "'" then
				k = "\""
			elseif k == "=" then
				k = "+"
			else
				k = string.upper(k)
			end
		end
		if k == "backspace" then
			debugConsoleText = string.sub(debugConsoleText,0,string.len(debugConsoleText)-1)
		elseif k == "return" or k == "enter" then
			love.filesystem.write("tmp.lua", debugConsoleText, all)
			love.filesystem.load("tmp.lua")()
		else
			if string.len(k) == 1 then
				debugConsoleText = debugConsoleText .. k
			end
		end
	else
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
					elseif k == "return" or k == "enter" or k == " " then
						if menu.selection == 1 then
							menu.opened = false
							menu.fadeTo = 0
							menu.slideTo = 0
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
							menu.selection = 1
							player.moving = false
						end

						if k == "c" then collectgarbage("collect") end
						if k == "s" then saveGame() end
						if k == "m" then openInventory() end
						if k == "f" then print(ti.getFPS()) end

						if k == "a" then
							for i=1,50 do
								spawnDropped(_r(0,2),player.x+_r(-100,100),player.y+_r(50,250),-1)
							end
						end
						if k == "e" then
							for x=0,mapWidth/32 do
								for y=0,mapHeight/32 do
									if _r(1,20) == 1 and mapHit[x][y] == "." then
										createEnemy(_r(1,5), x*32, y*32, "", true)
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
						if k == "x" then fireArrow(pArrow, player.facing, 512, 1) end
						if k == "b" then placeBomb(player.x, player.y-16, 100, 1) end
						if k == "v" then throwBoomerang(player.boomerangPower * 50, player.facing, player.boomerangPower * 256, 1) end
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
					elseif k == "down" then
						playSound(1)
					elseif k == "left" then
						playSound(1)
					elseif k == "right" then
						playSound(1)
					elseif k == "return" or k == " " then
						playSound(2)
						closeInventory()
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
end

function movePushable(id, dir)
  if pushables[id].times ~= 0 then
    if pushables[id].canMove == true then
      local can = true
      if dir == 1 then
        if checkCol(pushables[id].x-32, pushables[id].y-32, 111111) == false then
          pushables[id].tx = pushables[id].tx - 32
        else
          can = false
        end
      elseif dir == 2 then
        if checkCol(pushables[id].x, pushables[id].y-32-32, 111112) == false then
          pushables[id].ty = pushables[id].ty - 32
        else
          can = false
        end
      elseif dir == 3 then
        if checkCol(pushables[id].x+32, pushables[id].y-32, 111113) == false then
          pushables[id].tx = pushables[id].tx + 32
        else
          can = false
        end
      elseif dir == 4 then
        if checkCol(pushables[id].x, pushables[id].y+32-32, 111114) == false then
          pushables[id].ty = pushables[id].ty + 32
        else
          can = false
        end
      end
      if can == true then
        if pushables[id].times > 0 then pushables[id].times = pushables[id].times - 1 end
        player.speed = 64
        pushables[id].moving = true
        mapHit[pushables[id].x/32][(pushables[id].y-32)/32] = "."
        mapHit[pushables[id].tx/32][(pushables[id].ty-32)/32] = "w"
        playSound(pushables[id].sound)
      else
        print("Can't move Pushable #"..id.." because of obstruction.")
      end
    else
      playSound(pushables[id].sound)
      currentScript = pushables[id].script
    end
  end
end

function updatePushables(dt)
	for i, p in pairs(pushables) do
		if p.moving then
			if p.tx < p.x then
				p.x = p.x - player.speed*dt
				if p.x < p.tx then p.x = p.tx p.moving = false currentScript = p.script player.speed = 192 end
			end
			if p.ty < p.y then
				p.y = p.y - player.speed*dt
				if p.y < p.ty then p.y = p.ty p.moving = false currentScript = p.script player.speed = 192 end
			end
			if p.tx > p.x then
				p.x = p.x + player.speed*dt
				if p.x > p.tx then p.x = p.tx p.moving = false currentScript = p.script player.speed = 192 end
			end
			if p.ty > p.y then
				p.y = p.y + player.speed*dt
				if p.y > p.ty then p.y = p.ty p.moving = false currentScript = p.script player.speed = 192 end
			end
		end
	end
end


function checkPush(x,y)
	local cpx, cpy = _f(x/32), _f(y/32)
	if player.pushTime > 0 then
		if player.cx ~= 0 then
			if player.cx >= 1 and player.cx < 16 then player.x = player.x - 1 end
			if player.cx <= -1 and player.cx > -16 then player.x = player.x + 1 end
			if player.cx < 1 and player.cx > -1 then
				player.x = twoDown(player.x)
				player.cx = 0
				player.pushTime = 0
			end
		end
		if player.cy ~= 0 then
			if player.cy >= 1 and player.cy < 16 then player.y = player.y - 1 end
			if player.cy <= -1 and player.cy > -16 then player.y = player.y + 1 end
			if player.cy < 1 and player.cy > -1 then
				player.y = twoDown(player.y)
				player.cy = 0
				player.pushTime = 0
			end
		end
		player.pushX, player.pushY = cpx, cpy
	else
		player.pushX, player.pushY = -1, -1
	end
end

function notInWall(npx,npy)
	if checkCol(npx, npy, 9917) == false and checkCol(npx+31, npy, 9918) == false and checkCol(npx+31, npy, 9919) == false and checkCol(npx+31, npy+31, 9920) == false then
		return true
	else
		return false
	end
end

function findClosestEnemy()
	local cid = 0
	local ced = 100000
	local d = 0
	for i, e in pairs(enemy) do
		d = distanceFrom(player.x, player.y, e.x, e.y)
		if d < ced then cid = i ced = d end
	end
	print("Returning Closest Enemy: " .. cid)
	return cid
end

function resetPush()
	player.pushTime = 0
	player.pushX = -1
	player.pushY = -1
end

--TIMEOUT DELAY
function setTimeOut(d,c,n)
	if timeOutSet[n] ~= true then
		d = d + time
		table.insert(timeOut, { id = n, delay = d, callback = c } )
		timeOutSet[n] = true
	end
end

function updateTimeOut()
	local a = time
	for i, t in pairs(timeOut) do
		if a >= t.delay then
			local cb = t.callback()
			timeOutSet[t.id] = false
			table.remove(timeOut, i)
		end
	end
end

--HURTPLAYER
function hurtPlayer(h, dir)
	if player.invincible == 0 then
		playSound(18)
		if player.health > 0 then player.health = player.health - h end
		if player.health < 0 then player.health = 0 end
		player.invincible = player.invincibleTime
		player.knockTime = 24
		player.knockDir = dir
	end
end

--INVENTORY
function openInventory()

	inventory.opened = true
end

function closeInventory()

	inventory.opened = false
end

--OVERLAP
function overlap(x1,y1,w1,h1,x2,y2,w2,h2, i)
	local tl, bl, tr, br = false, false, false, false
	if (x2 >= x1 and x2 <= (x1 + w1)) and (y2 >= y1 and y2 <= (y1 + h1)) then tl = true end
	if (x2+w2 >= x1 and x2+w2 <= (x1 + w1)) and (y2 >= y1 and y2 <= (y1 + h1)) then tr = true end
	if (x2 >= x1 and x2 <= (x1 + w1)) and (y2+h2 >= y1 and y2+h2 <= (y1 + h1)) then bl = true end
	if (x2+w2 >= x1 and x2+w2 <= (x1 + w1)) and (y2+h2 >= y1 and y2+h2 <= (y1 + h1)) then br = true end

	if (x1 >= x2 and x1 <= (x2 + w2)) and (y1 >= y2 and y1 <= (y2 + h2)) then tl = true end
	if (x1+w1 >= x2 and x1+w1 <= (x2 + w2)) and (y1 >= y2 and y1 <= (y2 + h2)) then tr = true end
	if (x1 >= x2 and x1 <= (x2 + w2)) and (y1+h1 >= y2 and y1+h1 <= (y2 + h2)) then bl = true end
	if (x1+w1 >= x2 and x1+w1 <= (x2 + w2)) and (y1+h1 >= y2 and y1+h1 <= (y2 + h2)) then br = true end

	if debugVar == 2 then
		gr.setColor(0,0,0,100)
		gr.line(x1+mapOffsetX, y1+mapOffsetY, x2+mapOffsetX, y2+mapOffsetY)
		gr.setColor(255,0,0,100)
		gr.rectangle("fill", x1+mapOffsetX, y1+mapOffsetY, w1, h1)
		gr.setColor(0,255,255,100)
		gr.rectangle("fill", x2+mapOffsetX, y2+mapOffsetY, w2, h2)
		gr.setColor(0,0,0,255)
		gr.setFont(mono)
		gr.print(i, x1+mapOffsetX, y1+mapOffsetY+h1+10)
		gr.print(i, x2+mapOffsetX, y2+mapOffsetY+h2+10)
	end
	if tl or tr or bl or br then return true else return false end
end

--CHECK COLLISION
function checkCol(x,y, i ,w)
	if debugVar == 2 then
		gr.setColor(0,255,0,200)
		gr.circle("fill", x+mapOffsetX, y+mapOffsetY, 6, 32)
		gr.setBlendMode("alpha")
		gr.setColor(0,0,0,255)
		gr.setFont(mono)
		gr.print(i, x+mapOffsetX, y+mapOffsetY)
	end
	local cpx = _f(x / 32)
	local cpy = _f(y / 32)
	if cpx >= 0 and cpy >= 0 then
		if mapHit[cpx][cpy] == "x" or mapHit[cpx][cpy] == "n" or (mapHit[cpx][cpy] == "w" and w ~= 2) then return true else return false end
	else
		return true
	end
end

--TURN A SPECIFIED NPC TO FACE THE PLAYER
function turnNPCToFaceMe(n) if player.facing == 1 then npc[n].facing = 3 elseif player.facing == 3 then npc[n].facing = 1 elseif player.facing == 2 then npc[n].facing = 4 elseif player.facing == 4 then npc[n].facing = 2 end end

--UPDATE FADE
function doFade(dt)
	if fade.to > fade.val then
		fade.val = fade.val + (fade.step * dt)
		if fade.val > 255 then fade.val = 255 end
	end
	if fade.to < fade.val then
		fade.val = fade.val - (fade.step * dt)
		if fade.val < 0 then fade.val = 0 end
	end

	if cut.to > cut.val then
		cut.val = cut.val + (cut.step * dt)
		if cut.val > 100 then cut.val = 100 end
	end
	if cut.to < cut.val then
		cut.val = cut.val - (cut.step * dt)
		if cut.val < 0 then cut.val = 0 end
	end

	if mapNameFadeTo > mapNameFade then
		mapNameFade = mapNameFade + (500 * dt)
		if mapNameFade > 200 then mapNameFade = 200 end
	end
	if mapNameFadeTo < mapNameFade then
		mapNameFade = mapNameFade - (500 * dt)
		if mapNameFade < 0 then mapNameFade = 0 end
	end
end

--DRAW FADE
function drawFade()
	if fade.val > 0 then
		gr.setColor(fade.color,fade.color,fade.color,fade.val)
		gr.rectangle("fill", 0, 0, screenW, screenH)
	end
	if cut.val > 0 then
		gr.setColor(0,0,0,255)
		gr.rectangle("fill", 0, 0, screenW, cut.val)
		gr.rectangle("fill", 0, screenH - cut.val, screenW, cut.val)
	end
end

--MENU
function animateMenu(dt)
	if menu.slideTo > menu.slide then
		menu.slide = menu.slide + 2000 * dt
		if menu.slide > menu.slideTo then menu.slide = menu.slideTo end
	elseif menu.slideTo < menu.slide then
		menu.slide = menu.slide - 2000 * dt
		if menu.slide < menu.slideTo then menu.slide = menu.slideTo end
	end

	if menu.fadeTo > menu.fade then
		menu.fade = menu.fade + 1024 * dt
		if menu.fade > menu.fadeTo then menu.fade = menu.fadeTo end
	elseif menu.fadeTo < menu.fade then
		menu.fade = menu.fade - 1024 * dt
		if menu.fade < menu.fadeTo then menu.fade = menu.fadeTo end
	end

	if menu.blockTo > menu.block then
		menu.block = menu.block + 1024 * dt
		if menu.block > menu.blockTo then menu.block = menu.blockTo end
	elseif menu.blockTo < menu.block then
		menu.block = menu.block - 1024 * dt
		if menu.block < menu.blockTo then menu.block = menu.blockTo end
	end

	if menu.filmSlideTo > menu.filmSlide then
		local s = 512
		if menu.filmSlide > 250 then s = 500-menu.filmSlide end
		menu.filmSlide = menu.filmSlide + s * dt
	end

  menu.spacing = 42
end

function setMusic(m,l)
  if m == -1 then m = currentMusic end
	if musicOn and enableAudio and m ~= 0 and currentMusic ~= m then
	  love.audio.stop()
		love.audio.play(muzac[m])
		muzac[m]:setLooping(l)
	end
	if m == 0 then love.audio.stop() end
	currentMusic = m
end

function playSound(s)
	if soundOn and enableAudio and s > -1 then love.audio.play(sfx[s]) end
end

function createConfiguration(sw, sh)
	local data = ""
	data = data .. "function love.conf(t)\n"
	data = data .. "	t.author = \"Jason Anderson\"\n"
	data = data .. "	t.title = \"Untitled Adventure Game\"\n"
	data = data .. "	t.screen.width = "..sw.."\n"
	data = data .. "	t.screen.height = "..sh.."\n"
	data = data .. "	t.console = true\n"
	data = data .. "	t.version = 0.6\n"
	data = data .. "	t.screen.vsync = true\n"
	data = data .. "	t.screen.fsaa = 4\n"
	data = data .. "	t.modules.joystick = false\n"
	data = data .. "	t.modules.audio = true\n"
	data = data .. "	t.modules.keyboard = true\n"
	data = data .. "	t.modules.event = true\n"
	data = data .. "	t.modules.image = true\n"
	data = data .. "	t.modules.graphics = true\n"
	data = data .. "	t.modules.timer = true\n"
	data = data .. "	t.modules.mouse = true\n"
	data = data .. "	t.modules.sound = true\n"
	data = data .. "	t.modules.physics = true\n"
	data = data .. "end"

	love.filesystem.write("conf.lua", data, all)
end

function createSettings()
	local data = ""
	data = data .. "musicOn = " .. tostring(musicOn) .. "\n"
	data = data .. "soundOn = " .. tostring(soundOn) .. "\n"
	data = data .. "soundVolume = " .. tostring(soundVolume) .. "\n"

	love.filesystem.write("settings.lua", data, all)
end


function logoLoad()
	logoExists = true
	world = love.physics.newWorld(0,-1000, screenW, 10000, 0, 250)
	world:setMeter(100)

	logoBox_shape = {}
	logoBox = love.physics.newBody(world, 620, -256, 0)
	logoBox_shape[1] = love.physics.newRectangleShape(logoBox, -256, -55, 512, 110, 0)
	logoBox:setMassFromShapes()
	logoBox:setAngle(_d2r(-20))
	logoBox:setBullet(true)
	logoBox_shape[1]:setRestitution(0.4)
	logoBox_shape[1]:setData("Logo")
	logoBox:setAngularVelocity(.1)

	presentsBox_shape = {}
	presentsBox = love.physics.newBody(world, 650, -350, 0)
	presentsBox_shape[1] = love.physics.newRectangleShape(presentsBox, -133, -27, 266, 54, 0)
	presentsBox:setAngle(_d2r(5))
	presentsBox:setBullet(true)
	presentsBox_shape[1]:setRestitution(0.2)
	presentsBox:setAngularVelocity(.1)
	presentsBox_shape[1]:setData("Presents")

	ground = love.physics.newBody(world, 0, 0, 0)
	ground_shape = love.physics.newRectangleShape(ground, screenW/2, screenH/2+100, screenW, 100, _d2r(0))
	ground:setBullet(true)
	ground_shape:setData("Ground")

	world:setGravity(0,500)
	world:setCallbacks(logoCollide)
	world:setAllowSleep(true)

	gr.setColorMode("modulate")
	gr.setBlendMode("alpha")
	menuTitle:setFilter("nearest","nearest")

	logoGround = true
	presentsDropped = false

	logoFade = 0
	logoFadeTo = 0
end

function logoUpdate(dt)
	world:update(dt)

	if time > 5 and logoGround == true then
		ground:setAngularVelocity(-1)
		ground:setMassFromShapes()
		presentsBox:setAngularVelocity(5)
		logoGround = false
	end
	if presentsBox:getY() > 850 then
		logoBox:destroy()
		logoBox = nil
		logoBox_shape = nil
		presentsBox:destroy()
		presentsBox = nil
		presentsBox_shape = nil
		world = nil
		collectgarbage("collect")
		logoExists = false
	end

	if logoFadeTo > logoFade and logoFade < 255 then
		logoFade = logoFade + 1024 * dt
		if logoFade > 255 then logoFade = 255 end
	end
end

function logoDraw()

	gr.setBlendMode("alpha")
	gr.setColorMode("modulate")

	gr.setBackgroundColor(logoFade,logoFade,logoFade)

	gr.setColor(255,255,255,logoFade-math.random(0,200)/10)
	gr.drawq(menuTitle, imgLogoBackground, 0, 0)

	gr.setColor(0,0,0,100)
	gr.drawq(menuTitle, imgLogoJasoco, (logoBox:getX()-30), (logoBox:getY()+20), logoBox:getAngle(), 1, 1, 512, 110)
	gr.drawq(menuTitle, imgLogoPresents, (presentsBox:getX()-30), (presentsBox:getY()+20), presentsBox:getAngle(), 1, 1, 266, 50)

	gr.setColor(255,255,255)
	gr.drawq(menuTitle, imgLogoJasoco, _f(logoBox:getX()), _f(logoBox:getY()), logoBox:getAngle(), 1, 1, 512, 110)
	gr.drawq(menuTitle, imgLogoPresents, _f(presentsBox:getX()), _f(presentsBox:getY()), presentsBox:getAngle(), 1, 1, 266, 50)

	local gx = math.random(0,screenW)+.5
	gr.setColor(0,0,0,logoFade*.5)
	gr.line(gx,0,gx,500)
end

function logoCollide(a, b, c)
	if a == "Logo" and b == "Ground" then
		if presentsDropped == false then
			presentsBox:setMassFromShapes()
			presentsDropped = true
			logoFadeTo = 255
			playSound(59)
		end
	end
end

function returnFaceDirFromAng(a)
	local r, na = 1, (_f((a+45 % 360) / 90) % 4) + 1
	if na == 1 then r = 3 elseif na == 2 then r = 2 elseif na == 3 then r = 1 elseif na == 4 then r = 4 end
	return r
end

--GENERAL MATH RELATED FUNCTIONS
function distanceFrom(x1,y1,x2,y2) return _sq((x2 - x1) ^ 2 + (y2 - y1) ^ 2) end

function findAngle(x1, y1, x2, y2)
	local t = _r2d(_at2(y1 - y2, x2 - x1))
	if t < 0 then t = t + 360 end
	return t
end

function formatTime(t, m)
  local r = _f(_m(t/60/60,60)) .. ":" .. string.sub("0" .. _f(_m(t/60,60)),-2) .. ":" .. string.sub("0" .. _f(_m(t,60)),-2)
  if m then r = r .. (t - _f(t)) end
  return r
end

function trim(s) return (string.gsub(s, "^%s*(.-)%s*$", "%1")) end

function sort(T) table.sort(T, function(a, b) return a.y < b.y end ) end

function twoDown(n) return _f((n) / 2) * 2 end

function love.mousepressed( x, y, button )
	if gameMode == editMode then
		editorMouseDown(x,y,button)
	elseif gameMode == inGame and testMode then
	  player.x = _f((x-mapOffsetX)/32)*32
	  player.y = _f((y-mapOffsetY)/32)*32+32
	end
end

function love.mousereleased( x, y, button )
	if gameMode == editMode then
		editorMouseUp(x,y,button)
	end
end

function bezier_curveline( x1, y1, hx1, hy1, x2, y2, hx2, hy2, samples )
	local samples = samples or 500
	local s = 1/samples
	local Ax = x1 + hx1
	local Ay = y1 + hy1
	local Bx = x2 + hx2
	local By = y2 + hy2
	local n,xn,yn
	local myLocations = { }

	for t=0,1,s do
		n = 1-t
		xn = ( x1 * n^3 ) + t * ( ( 3 * n^2 * Ax ) + t * ( ( 3 * n * Bx ) + ( x2 * t ) ) )
		yn = ( y1 * n^3 ) + t * ( ( 3 * n^2 * Ay ) + t * ( ( 3 * n * By ) + ( y2 * t ) ) )
		table.insert( myLocations, { myXn = xn, myYn = yn } )
	end

	local data = ""
	for i, v in pairs( myLocations ) do
		boomerangPoints[i] = { x = v.myXn, y = v.myYn }
		if i ~= #myLocations then
			love.graphics.line(
				v.myXn,
				v.myYn,
				myLocations[i + 1].myXn,
				myLocations[i + 1].myYn
			)
			data = data .. v.myXn .. "," .. v.myYn .. "\n"
		end
	end

	for i, p in pairs(boomerangPoints) do
		print(p.x, p.y)
	end

	return data
end

