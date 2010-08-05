function drawMapComposite(dt)
	debugTilesDrawn = 0
	debugSceneryDrawn = 0
	gr.setColorMode("replace")
	if fade.val < 255 then
		drawLowerLayer()

		for i,s in pairs(sprites) do
  		local elev = s.elev or 0
			--if s.x > xBounds[0]*32-128 and s.x < xBounds[1]*32+128 and s.y > yBounds[0]*32-512 and s.y < yBounds[1]*32+128 then
				local sl = sceneryLibrary[s.id]
				if s.n == "Scenery" then
					gr.setColor(255,0,0)
					i = sceneryLibrary[s.id].i
					q = sceneryLibrary[s.id].q
					if s.r ~= nil then r = s.r else r = 0 end

					local x, y = _f(s.x+mapOffsetX), _f(s.y+mapOffsetY)
					if sceneryLibrary[s.id].ani == true then
						if s.fra == nil then s.fra = math.random(1, sl.fra) end
						if s.sp == nil then s.sp = 1 end
						if s.active then s.fra = s.fra + dt * s.sp end
						if s.fra >= sl.fra+1 then s.fra = 1 end
						gr.drawq(sl.i, sl.q[_f(s.fra)], x, y, r, s.sx, s.sy, sl.ox, sl.oy - elev)
					else
						gr.drawq(sl.i, sl.q, x, y + elev, r, s.sx, s.sy, sl.ox, sl.oy)
					end
					debugSceneryDrawn = debugSceneryDrawn + 1
				elseif s.n == "Switch" then
					local sce
					if s.state == 1 then sce = s.imgOn else sce = s.imgOff end
					if sce == nil then sce = "Barrel" end
					sl = sceneryLibrary[sce]
					local x, y = s.x+mapOffsetX+sl.ox, s.y+mapOffsetY+sl.oy
					gr.drawq(sl.i, sl.q, x, y, 0, 1, 1, sl.ox, sl.oy)
				elseif s.n == "Pushable" then
					sl = sceneryLibrary[s.img]
					local x, y = s.x+mapOffsetX, s.y+mapOffsetY
					gr.drawq(sl.i, sl.q, x, y, 0, 1, 1, sl.ox, sl.oy)
				elseif s.n == "Enemy" then
					local sy, eof, px, py
					gr.setBlendMode("alpha")
					if s.inv > 0 then
						gr.setColor(255,255,255,100)
					else
						gr.setColor(255,255,255,255)
					end
					if s.simple == false then
						eof = (s.t - 1) * 64 + (_f(s.step/2) * 32)
						gr.drawq(enemies, enemyGrid[s.facing - 1][eof/32], _f((s.x+mapOffsetX)), _f((s.y+mapOffsetY))-32)
					else
						gr.drawq(enemies2, enemy2Grid[_f(s.step/2)], _f((s.x+mapOffsetX)), _f((s.y+mapOffsetY))-32)
					end
				elseif s.n == "NPC" then
					if s.map == mapNumber then
						local sy = ((_f(s.step/16)) + ((s.who - 1) * 2))
						gr.drawq(npcs, npcGrid[s.facing-1][sy], _f((s.x+mapOffsetX)), _f((s.y+mapOffsetY)), 0, 1, 1, 0, 48)
						if s.somethingToSay == true then
							gr.drawq(menuTitle, notifGrid[3], s.x + mapOffsetX+16, s.y + mapOffsetY - 8 + _s(time*5)*3, 0, 1, 1, 16, 48)
						end
					end
				elseif s.n == "Player" then
					--Draw the Player
					if player.invAnim == 0 then
						local px = (_f((player.x+mapOffsetX)))
						local py = (_f((player.y+mapOffsetY)))
						if player.attacking > 0 then
							--Draw the player attack pose
							gr.drawq(playerImg, playerGrid[player.facing - 1][4], px, py, 0, 1, 1, 32, 64)
						else
							--Regular walking player
							gr.drawq(playerImg, playerGrid[player.facing - 1][_f(player.walking/8)], px, py, 0, 1, 1, 32, 64)
						end
					end
				elseif s.n == "TargetArrow" then
					local a = notifGrid[1]
					if player.targetDist < 96 then a = notifGrid[2] end
					gr.drawq(menuTitle, a, s.x, s.y, 0, 1, 1, 16, 32)
				elseif s.n == "Dropped" then
					local drawIt = true
					if s.life <= 3 then if _f(time % 10)/10 == 1 then drawIt = false end end
					if drawIt == true then
						gr.setColor(0,0,0,255/2)
						gr.rectangle("fill",(s.x + mapOffsetX)+8-s.f/2, (s.y + mapOffsetY-2),16+(s.f),2)
						gr.drawq(dropItem, itemGrid[s.id], (s.x + mapOffsetX), (s.y + mapOffsetY+s.f-5)-32)
					end
				elseif s.n == "Projectile" then
					r = _d2r(s.r * 90 + s.spin)
					if s.time > 0 or s.ty ~= 2 then gr.drawq(projectiles, projectileGrid[s.ty][0], _f(s.x + mapOffsetX+16), _f(s.y + mapOffsetY-16), r, 1, 1, 16, 16) end
				elseif s.n == "Boomerang" then
					gr.drawq(projectiles, projectileGrid[3][0], _f(s.x+mapOffsetX), _f(s.y+mapOffsetY), s.boomSpin, 1, 1, 16, 16)
				elseif s.n == "Explosion" then
					gr.drawq(explosions, explosionGrid[_f(s.f)][0], _f(s.x + mapOffsetX)+16, _f(s.y + mapOffsetY)-(s.f*2)+16, s.f, 1+s.f/2, 1+s.f/2, 16, 16)
				else
					gr.setColor(0,0,255)
					gr.rectangle("fill", s.x+mapOffsetX, s.y+mapOffsetY-32, 32, 32)
					gr.setColor(0,0,0)
					gr.rectangle("line", s.x+mapOffsetX, s.y+mapOffsetY-32, 32, 32)
				end
				if debugVar == 2 then gr.print(tostring(s.n), _f((s.x+mapOffsetX)), _f((s.y+mapOffsetY))) end --DEBUG CODE
			--end
		end

		mapDraw()

		drawUpperLayer()
		drawWeather()

		if debugVar == 2 then debugDrawHotzones() end --DEBUG CODE

		if testMode then
      gr.setColor(255,255,255)
      gr.setFont(dialogFont)
      gr.print("Currently Running in Test Mode", 20, 30)
      gr.setFont(editorFontMono)
      gr.print("Click to place the Player anywhere", 20, 50)
		end
	end
end

function drawLowerLayer()
	--Draw Tiles and Lower Objects Layer
	for x=xBounds[0],xBounds[1]-1 do
		for y=yBounds[0],yBounds[1]-1 do
		  if x < 0 then x = 0 end
		  if y < 0 then y = 0 end
			drawTile(mapTiles[x][y], x, y)
			drawTile(mapDeco1[x][y], x, y)
		end
	end
end

function drawUpperLayer()
	--Draw Upper Objects Layer
 	gr.setColorMode("replace")
	for x=xBounds[0],xBounds[1]-1 do
		for y=yBounds[0],yBounds[1]-1 do
		  if x < 0 then x = 0 end
		  if y < 0 then y = 0 end
			drawTile(mapDeco2[x][y], x, y)
			if mapHit[x][y] ~= "." and debugVar > 0 then
				gr.setColor(255,0,0,100)
				gr.rectangle("fill", _f(x*32+mapOffsetX), _f(y*32+mapOffsetY), 32, 32)
			end
		end
	end
end

function drawTile(tmp, x, y)
	if tmp ~= "0000" then
		local xx = tonumber(string.sub(tmp, 1, 2))
		local yy = tonumber(string.sub(tmp, 3, 4))
		gr.drawq(imgScenery, tileGrid[xx][yy], _f(x*32+mapOffsetX), _f(y*32+mapOffsetY))
		debugTilesDrawn = debugTilesDrawn + 1
	end
end

function drawStatusBar()
	gr.setColor(255,255,255) --Draw Status Area
	gr.setFont(numbers)

	local tt = screenH - 80 + cut.val

	if player.money > player.rollMoney then
		player.rollMoney = player.rollMoney + 4
		if player.rollMoney > player.money then player.rollMoney = player.money end
	end
	if player.money < player.rollMoney then
		player.rollMoney = player.rollMoney - 4
		if player.rollMoney < player.money then player.rollMoney = player.money end
	end
	gr.print("A" .. player.arrows, screenW - 100, tt)
	gr.print("B" .. player.bombs, screenW - 90, tt+40)
	gr.print("$" .. player.rollMoney, 40, tt)

	drawHeartGuage(48,tt + 54,player.health,player.maxHealth)
end

function drawHeartGuage(x,y,h,m)
	local s = 1
	gr.setColorMode("replace")
	local spacing = 28 * s
	for i=1,_f(m) do
		gr.drawq(menuTitle, heartGrid[1], x+((i-1)*spacing), y, 0, s, s, 16, 16)
		if i <= _f(h) then
			gr.drawq(menuTitle, heartGrid[2], x+((i-1)*spacing), y, 0, s, s, 16, 16)
		end
	end

	if _f(h) < h then
		local th = (h - _f(h)) * 4
		local o = th
		gr.drawq(menuTitle, heartGrid[o], x+((_f(h))*spacing), y, 0, s, s, 16, 16)
	end
end

function drawMenuScreen()
	local x = 50-- + menu.slide - 250
	local f = menu.fade-math.random(0,100)/10
	if menu.fade < 20 then f = menu.fade end

	if math.random(1,30) == 1 then
		camera.shakeY = math.random(-2,2)
	else
		camera.shakeY = 0
	end

	gr.setBlendMode("alpha")
 	gr.setColorMode("modulate")
 	if menu.block > 0 then
		gr.setColor(255,255,255,menu.block)
		gr.rectangle("fill", 0,0,screenW,screenH)
	end

	if math.random(0,4) == 1 then
		local gx = math.random(0,screenW)+.5
		gr.setColor(0,0,0,menu.fade*.5)
		gr.line(gx,0,gx,500)
	end

	gr.setColor(255,255,255,f)
	gr.drawq(menuTitle, imgLogoBackground, 0, 0)
	gr.setFont(menuFont)
	if menu.page == mpMain then
		local options = {"Continue", "New Game", "Options", "Quit Game"}

		for i, o in ipairs(options) do
			y = screenH - (menu.spacing * (4+2)) + (menu.spacing * i)
			gr.setColor(0,0,0,(menu.fade-menu.block)*.5)
			gr.print(options[i], x+2, y+15)
			if i == menu.selection then
				gr.setColor(255,255,255,menu.fade-menu.block)
			else
				gr.setColor(120,120,120,menu.fade-menu.block)
			end
			gr.print(options[i], x, y+14)
		end
	elseif menu.page == mpOptions then
		local options = {"Music", "Sound FX", "Volume", "Resolution", "Toggle Fullscreen", "Back"}
		local values = { musicOn, soundOn, soundVolume, resString, "", "" }

    gr.setColor(0,0,0,150)
    gr.print("Options", x+2, 71)
		gr.setColor(255,255,255)
		gr.print("Options", x, 70)

		for i, o in ipairs(options) do
			y = screenH - (menu.spacing * (6+2)) + (menu.spacing * i)
			local valTxt
			if i == 1 or i == 2 then if values[i] == true then valTxt = "On" else valTxt = "Off" end else valTxt = tostring(values[i]) end
			gr.setColor(0,0,0,150)
			gr.print(options[i], x+2, y+15)
			gr.print(valTxt, x+202, y+15)
			if i == menu.selectionB then
				gr.setColor(255,255,255)
			else
				gr.setColor(120,120,120)
			end
			gr.print(options[i], x, y+14)
			gr.print(valTxt, x+200, y+14)
		end
	elseif menu.page == mpScreens then
		gr.setColor(255,255,255,255)
		gr.print("Resolution:", 100, 24)

		for i, mode in ipairs(screenModes) do
			local desc = string.format("%dx%d", mode.width, mode.height)
			local y = (menu.spacing * i) + 30
			gr.print(desc, 120, y+14)
		end

	elseif menu.page == mpQuit then
		options = { "Continue", "Quit"}

    gr.setColor(0,0,0,150)
    gr.print("Quit Game?", x+2, 71)
		gr.setColor(255,255,255,255)
		gr.print("Quit Game?", x, 70)

		for i, o in ipairs(options) do
			y = screenH - (menu.spacing * (2+2)) + (menu.spacing * i)
			gr.setColor(0,0,0,150)
			gr.print(options[i], x+2, y+15)
			if i == quitSelection+1 then
				gr.setColor(255,255,255)
			else
				gr.setColor(120,120,120)
			end
			gr.print(options[i], x, y+14)
		end
		gr.setColorMode("replace")
	end
end

function drawInventory()
end

--DEBUG CODE
function drawDebug(dt)
	gr.setColorMode("modulate")
	local fps = ti.getFPS()

	--Debug Information
	gr.setFont(mono)
	local gameData =	"\n"
	if gameMode == inStartup then
		gameData = gameData .. "STARTUP\n"
		gameData = gameData .. " Startup: " .. startupTimer .. "\n"
		gameData = gameData .. " Time:    " .. time .. "\n"
	elseif gameMode == editMode then
		gameData = gameData .. "EDIT MODE\n"
		gameData = gameData .. " Editor Mode: " .. editorMode .. "\n"
		gameData = gameData .. " List Selection: " .. editorMapListSelection .. "\n"
		gameData = gameData .. " Setup Selection: " .. editorMapSetupSelection .. "\n"
		gameData = gameData .. " Current Layer: " .. editorCurrentLayer .. "\n"
	elseif gameMode == inGame then
		gameData = gameData .. "PLAYER\n"
		gameData = gameData .. " X: " .. _f(player.x) .. "(" .. _f(player.x/32) .. "), Y: " .. _f(player.y) .. "(" .. _f(player.y/32) .. ")\n"
		gameData = gameData .. " CX: " .. player.cx .. ", CY: " .. player.cy .. "\n"
		gameData = gameData .. " Walk Frame:      " .. player.walking .. "\n"
		gameData = gameData .. " Invincibility:   " .. player.invincible .. "\n"
		gameData = gameData .. " Inv Animation:   " .. player.invAnim .. "\n"
		gameData = gameData .. " Attack Timer:    " .. player.attacking .. "\n"
		--gameData = gameData .. " Knock Time:		" .. player.knockTime .. "\n"
		--gameData = gameData .. " Knock Dir:		 " .. player.knockDir .. "\n"
		gameData = gameData .. " Weapon:          " .. player.weapon .. "\n"
		gameData = gameData .. " HP:              " .. player.health .. "\n"
		gameData = gameData .. " HP (Max):        " .. player.maxHealth .. "\n"
		gameData = gameData .. " Idle Time:       " .. player.idle .. "\n"
		gameData = gameData .. " Push Tile:       " .. player.pushX .. "," .. player.pushY .. "\n"
		gameData = gameData .. " Push Time:       " .. player.pushTime .. "\n"
		if player.targeting > 0 then
			gameData = gameData .. " Targeting:     " .. tostring(player.targeting) .. "\n"
			gameData = gameData .. " Target Dist:   " .. tostring(player.targetDist) .. "\n"
			gameData = gameData .. " Target Angle:  " .. tostring(player.targetAng) .. "\n"
			gameData = gameData .. " Angle Facing:  " .. returnFaceDirFromAng(player.targetAng) .. " -- " .. (_f((player.targetAng+45 % 360) / 90) % 4) + 1 .. "\n"
		end

		gameData = gameData .. "COUNTS\n"
		gameData = gameData .. " Enemies:       " .. table.getn(enemy) .. "\n"
		gameData = gameData .. " Projectiles:   " .. table.getn(projectile) .. "\n"
		gameData = gameData .. " Explosions:    " .. table.getn(explosion) .. "\n"
		gameData = gameData .. " Droppables:    " .. table.getn(dropped) .. "\n"
		gameData = gameData .. " Switches:      " .. table.getn(switch) .. "\n"
		gameData = gameData .. " NPCs:          " .. table.getn(npc) .. "\n"
		gameData = gameData .. " Scenery:       " .. debugSceneryDrawn .. "\n"
		gameData = gameData .. " Tiles:         " .. debugTilesDrawn .. "\n"


--[[		gameData = gameData .. "MAP (#" .. mapNumber .. ")\n"
		gameData = gameData .. " Size:			" .. mapWidth .. "(" .. mapWidth/32 .. ")/" .. mapHeight .. "(" .. mapHeight/32 .. ")\n"
		gameData = gameData .. " Bounds:		" .. xBounds[0] .. "-" .. xBounds[1] .. ",".. yBounds[0] .. "-" .. yBounds[1] .. "\n"
		gameData = gameData .. " Offset:		" .. mapOffsetX .. ",".. mapOffsetY .. "\n"
		gameData = gameData .. " ChangeMap: " .. tostring(changeMap) .. "\n"

		gameData = gameData .. "CAMERA\n"
		gameData = gameData .. " Camera:		" .. camera.x .. ",".. camera.y .. "\n"
		gameData = gameData .. " From:			" .. camera.scrollFromX .. ",".. camera.scrollFromY .. "\n"
		gameData = gameData .. " To:				" .. camera.scrollToX .. ",".. camera.scrollToY .. "\n"
		gameData = gameData .. " Speed:		 " .. camera.speedX .. ",".. camera.speedY .. "\n"
		gameData = gameData .. " Moving:		" .. tostring(camera.movingX) .. ",".. tostring(camera.movingY) .. "\n"

		gameData = gameData .. "FADE\n"
		gameData = gameData .. " Fade Val:	" .. fade.val .. "\n"
		gameData = gameData .. " Fade To:	 " .. fade.to .. "\n"
		gameData = gameData .. "CUT\n"
		gameData = gameData .. " Cut Val:	 " .. cut.val .. "\n"
		gameData = gameData .. " Cut To:		" .. cut.to .. "\n"--]]

		gr.setBlendMode("alpha")
		gr.setColorMode("modulate")
		if scriptRunning == true and scriptLine < scriptLength + 1 then
			local scriptData = ""
			scriptData = scriptData .. "SCRIPT\n"
			scriptData = scriptData .. " Opened:         " .. tostring(scriptRunning) .. "\n"
			scriptData = scriptData .. " Line:           " .. scriptLine .. " of " .. scriptLength .. "\n"
			scriptData = scriptData .. " Command:        " .. script[scriptLine].c .. "\n"
			scriptData = scriptData .. " Current:        " .. currentScript .. "\n"
			scriptData = scriptData .. " Paused:         " .. tostring(scriptPaused) .. "\n"
			scriptData = scriptData .. " Waiting:        " .. tostring(scriptWaiting) .. "\n"
			scriptData = scriptData .. " Wait For Cam:   " .. tostring(scriptWaitingForCamera) .. "\n"
			scriptData = scriptData .. " npcIsMoving:    " .. tostring(npcIsMoving) .. "\n"
			scriptData = scriptData .. " npcMoveSteps:   " .. tostring(npcMoveSteps) .. "\n"
			if objIsMoving > 0 then
				scriptData = scriptData .. " objIsMoving:  " .. tostring(objIsMoving) .. "\n"
				scriptData = scriptData .. " objMoveSteps: " .. tostring(objMoveSteps) .. "\n"
				scriptData = scriptData .. " objX:         " .. tostring(_f(switch[objIsMoving].x)) .. " (" .. _f(switch[objIsMoving].x/32) .. ")\n"
				scriptData = scriptData .. " objY:         " .. tostring(_f(switch[objIsMoving].y)) .. " (" .. _f(switch[objIsMoving].y/32) .. ")\n"
			end
			scriptData = scriptData .. " chainScript:				" .. chainScript .. "\n"
			scriptData = scriptData .. " dialog.queryChoice: " .. dialog.queryChoice .. "\n"
			if queryChoices ~= nil then scriptData = scriptData .. " Choices:					" .. table.getn(queryChoices) .. "\n" end

			scriptData = scriptData .. "COMMANDS\n"
			for i=1,scriptLength-2 do
				scriptData = scriptData .. " " .. tostring(script[i].c) .. " " .. tostring(script[i].p1) .. " " .. string.sub(tostring(script[i].p2),0,10) .. " (" .. tostring(script[i].d) .. ")\n"
			end

			gr.setColor(0,0,0,50)
			gr.rectangle("fill", screenW - 180, 0, 180, screenH)
			gr.setColor(255,255,255,255)
			gr.print(scriptData, screenW - 170, 10)
		end
	end

	local debugData = ""
	debugData = debugData .. "FPS: " .. fps .. " DT: " .. dt
	debugData = debugData .. "\n Mode:        " .. gameMode
	debugData = debugData .. "\n Timer:       " .. formatTime(time)
	debugData = debugData .. "\n Loaded:      " .. loadedGame
	debugData = debugData .. "\n Name:        " .. player.name
	if gameMode == inGame then
		debugData = debugData .. "\n Session:   " .. formatTime(gameSession)
		debugData = debugData .. "\n SessionP:  " .. formatTime(gameSessionPrevious)
		debugData = debugData .. "\n Start:     " .. formatTime(gameStartTime)
		debugData = debugData .. "\n Mouse:     " .. love.mouse.getX()-mapOffsetX .. "," .. love.mouse.getY()-mapOffsetY
	end

	menuData = ""
	if menu.opened == true then
		menuData = menuData .. "\nMENU:"
		menuData = menuData .. "\n Fade:        " .. menu.fade .. "/" .. menu.fadeTo
		menuData = menuData .. "\n Slide:       " .. menu.slide .. "/" .. menu.slideTo
		menuData = menuData .. "\n Page:        " .. menu.page
		menuData = menuData .. "\n Page1 Sel:   " .. menu.selection
		menuData = menuData .. "\n Page2 Sel:   " .. menu.selectionB
	end

	if menu.opened == true then
		gr.setColor(255,255,255,255)
		gr.print(debugData .. menuData, 10, 10)
		gr.setColor(255,255,255,255)
	else
		gr.setColor(0,0,0,255)
		gr.print(debugData .. gameData .. menuData, 11, 11)
		gr.setColor(255,255,255,255)
		gr.print(debugData .. gameData .. menuData, 10, 10)
	end
end

function debugDrawHotzones()
	for h, z in ipairs(hotzone) do
		if z.active then
			gr.setColor(0,0,255,100)
		else
			gr.setColor(255,0,0,100)
		end
		gr.rectangle("fill", z.x + mapOffsetX, z.y + mapOffsetY, z.w, z.h)
		gr.setColor(255,255,255,255)
		gr.setFont(mono)
		gr.print("#" .. h .. "\nS:" .. z.script, z.x + 2 + mapOffsetX, z.y + 2 + mapOffsetY)
	end
end
--/DEBUG CODE