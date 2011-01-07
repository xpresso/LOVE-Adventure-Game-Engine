function drawMapComposite(dt)
	debugTilesDrawn = 0
	debugSceneryDrawn = 0
	if fade.val < 255 then
		drawLowerLayer()

		for i,s in pairs(sprites) do
		  local drawIt = true
      gr.setColorMode("modulate")
      gr.setBlendMode("alpha")
      gr.setColor(255,255,255)
  		local elev = s.elev or 0
      local sl = sceneryLibrary[s.id]
      if s.n == "Scenery" then
        i = sceneryLibrary[s.id].i
        q = sceneryLibrary[s.id].q
        if s.r ~= nil then r = s.r else r = 0 end

        local x, y = _f(s.x+mapOffsetX), _f(s.y+mapOffsetY)
        if sceneryLibrary[s.id].ani == true then
          if s.fra == nil then s.fra = _r(1, sl.fra) end
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
        gr.setColor(0,0,0,100)
        if s.inv > 0 and _s(time*50) < 0 then drawIt = false end
        gr.setColor(255,255,255,255)
        if drawIt == true then
          if s.simple == false then
            eof = (s.t - 1) * 64 + (_f(s.step/2) * 32)
            gr.drawq(enemies, enemyGrid[s.facing - 1][eof/32], _f((s.x+mapOffsetX)), _f((s.y+mapOffsetY)), 0, 1, 1, 16, 32)
          else
            gr.setColor(0,0,0,255*.5)
            gr.rectangle("fill",_f(s.x + mapOffsetX)-7, _f(s.y + mapOffsetY-1),15,1)
            gr.setColor(255,255,255,255)
            gr.drawq(enemies2, enemy2Grid[_f(s.step/2)], _f((s.x+mapOffsetX)), _f((s.y+mapOffsetY))-24, 0, 1, 1, 16, 32)
          end
        end
        gr.line(s.x+mapOffsetX-3, s.y+mapOffsetY, s.x+mapOffsetX+3, s.y+mapOffsetY)
        gr.line(s.x+mapOffsetX, s.y+mapOffsetY-3, s.x+mapOffsetX, s.y+mapOffsetY+3)
      elseif s.n == "NPC" then
        if s.map == mapNumber then
          local sy = ((_f(s.step/16)) + ((s.who - 1) * 2))
          gr.drawq(npcs, npcGrid[s.facing-1][sy], _f((s.x+mapOffsetX)), _f((s.y+mapOffsetY)), 0, 1, 1, 0, 48)
          if s.somethingToSay == true then
            gr.drawq(menuTitle, notifGrid[3], s.x + mapOffsetX+16, s.y + mapOffsetY - 8 + _s(time*5)*3, 0, 1, 1, 16, 72)
          end
        end
      elseif s.n == "Player" then
        --Draw the Player
        if player.invincible > 0 and _s(time*50) < 0 then drawIt = false end
        if drawIt then
          local px = (_f((player.x+mapOffsetX)))
          local py = (_f((player.y+mapOffsetY)))
          if player.attacking > 0 then
            --Draw the player attack pose
            gr.drawq(playerImg, playerGrid[player.facing - 1][4], px, py, 0, 1, 1, 48, 64)
          else
            --Regular walking player
            gr.drawq(playerImg, playerGrid[player.facing - 1][_f(player.walking/8)], px, py, 0, 1, 1, 48, 64)
          end
        end
      elseif s.n == "TargetArrow" then
        local a = notifGrid[1]
        if player.targetDist < 96 then a = notifGrid[2] end
        gr.drawq(menuTitle, a, _f(s.x), _f(s.y - 32 + _s(time*10) * 3), 0, 1, 1, 16, 32)
      elseif s.n == "Dropped" then
        local o = bounceOffset(s.num)
        if s.life <= 1 then if _s(time*50) < 0 then drawIt = false end end
        if drawIt == true then
          gr.setColor(0,0,0,255*.5)
          gr.rectangle("fill",_f(s.x + mapOffsetX)-7, _f(s.y + mapOffsetY-1),15,1)
          gr.setColor(255,255,255)
          gr.drawq(dropItem, itemGrid[dTable[s.id].spr][_f(s.frame)], _f(s.x + mapOffsetX), _f(s.y + mapOffsetY)-o, 0, 1, 1, 16, 32)
        end
      elseif s.n == "Projectile" then
        r = _d2r(s.r * 90 + s.spin)
        if s.time > 0 or s.ty ~= 2 then
          gr.setColor(0,0,0,255*.5)
          gr.rectangle("fill",_f(s.x + mapOffsetX)-7, _f(s.y + mapOffsetY-1),15,1)
          gr.setColor(255,255,255)
          gr.drawq(projectiles, projectileGrid[s.ty][0], _f(s.x + mapOffsetX), _f(s.y + mapOffsetY)-24, r, 1, 1, 16, 16)
        end
      elseif s.n == "Boomerang" then
        gr.drawq(projectiles, projectileGrid[3][0], _f(s.x+mapOffsetX), _f(s.y+mapOffsetY), s.boomSpin, 1, 1, 16, 16)
      elseif s.n == "Explosion" then
        gr.drawq(
          explosions,
          explosionGrid[_f(s.f)][0],
          _f(s.x + mapOffsetX)+16,
          _f(s.y + mapOffsetY)-(s.f*2)+16,
          s.f,
          1+s.f/2,
          1+s.f/2,
          16,
          16
        )
      elseif s.n == "Floater" then
        gr.setFont(floaterFont)
        gr.setColor(0,0,0,255/2)
        gr.printf(s.val, _f(s.x + mapOffsetX - 100)+1, _f(s.y + mapOffsetY - (60-s.life)-s.elev)+2, 200, "center")
        gr.setColor(s.c[1],s.c[2],s.c[3],255-(32-s.life)*3)
        gr.printf(s.val, _f(s.x + mapOffsetX - 100), _f(s.y + mapOffsetY - (60-s.life)-s.elev), 200, "center")
      else
        gr.setColor(0,0,255)
        gr.rectangle("fill", s.x+mapOffsetX-25, s.y+mapOffsetY-50, 50, 50)
        gr.setColor(0,0,0)
        gr.rectangle("line", s.x+mapOffsetX-25, s.y+mapOffsetY-50, 50, 50)
        gr.setFont(statusSmallFont)
        gr.setColor(255,255,255)
        gr.printf("Unknown", _f(s.x + mapOffsetX - 100), _f(s.y + mapOffsetY), 200, "center")
      end
		end

		mapDraw()

		drawUpperLayer()
		drawWeather()

		if debugVar == 2 then debugDrawHotzones() end --DEBUG CODE

		if testMode then
      gr.setColor(255,255,255)
      gr.setFont(dialogFont)
      gr.print("Currently Running in Test Mode", 20, 20)
      gr.setFont(editorFontMono)
      gr.print("Click to place the Player anywhere", 20, 40)
		end
	end
end

function drawLowerLayer()
	--Draw Tiles and Lower Objects Layer
  gr.setColorMode("replace")
  gr.setBlendMode("alpha")
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
  gr.setBlendMode("alpha")
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

function drawStatusBar(dt)
  gr.setColorMode("modulate")
  gr.setBlendMode("alpha")
	gr.setFont(statusFont)

	if player.money > player.rollMoney then
		player.rollMoney = player.rollMoney + 4
		if player.rollMoney > player.money then player.rollMoney = player.money end
	end
	if player.money < player.rollMoney then
		player.rollMoney = player.rollMoney - 4
		if player.rollMoney < player.money then player.rollMoney = player.money end
	end

  if cut.stat > 0 then
    local mm = formatNumber(player.rollMoney)
    gr.setColor(0,0,0,cut.stat/2)
    gr.printf("$" .. mm, screenW - 248+2, screenH - 59, 200, "right")
    gr.setColor(255,255,255,cut.stat)
    gr.printf("$" .. mm, screenW - 248, screenH - 60, 200, "right")
    drawHealthGuage(48+20, screenH - 50, player.health, player.maxHealth, dt)
  end
end

function drawHealthGuage(x,y,h,m,dt)
  local w = _f((200/player.maxHealth)*player.health)
	gr.setColor(255,255,255,cut.stat)
  gr.drawq(menuTitle,imgHealthBack,x,y,0,1,1,0,0)
	gr.setColor(0,255,0,cut.stat)
	gr.rectangle("fill", x, y, w, 10)
	gr.setColor(0,200,0,cut.stat)
	gr.rectangle("fill", x, y+10, w, 10)
	gr.setColor(255,255,255,cut.stat)
  gr.drawq(menuTitle,imgHealthHeart,x,y,0,1,1,33,12)

  local t = "Level: " .. player.level .. "  XP: " .. player.XP .. "  Next: " .. player.nextLevelAt
  gr.setFont(statusSmallFont)
	gr.setColor(0,0,0,cut.stat/2)
  gr.print(t, x+11, y-15)
	gr.setColor(255,255,255,cut.stat)
  gr.print(t, x+10, y-16)

	for i, h in pairs(healthNuggets) do
    h.grav = h.grav + 16 * dt
    h.x = h.x + 32 * dt
    h.y = h.y + h.grav

    gr.setColor(0,255,0,255)
    gr.rectangle("fill", h.x, h.y, h.w, 10)
    gr.setColor(0,200,0,255)
    gr.rectangle("fill", h.x, h.y+10, h.w, 10)

	  if h.y > screenH+10 then table.remove(healthNuggets, i) end
  end
end

function drawMenuScreen()
	local x = 50
	f = menu.fade

  colors={}
  colors["menutext"] = {127,127,127,f-menu.block}
  colors["menushadow"] = {255,255,255,(f-menu.block)/2}
  colors["menuselected"] = {0,0,0,f-menu.block}
  colors["white"] = {255,255,255,f-menu.block}
  colors["background"] = {255,255,255,f-menu.block}

	gr.setBlendMode("alpha")
 	gr.setColorMode("modulate")
 	if menu.block > 0 then
		gr.setColor(255,255,255,menu.block)
		gr.rectangle("fill", 0,0,screenW,screenH)
	end

	gr.setColor(unpack(colors["white"]))
	gr.drawq(menuTitle, imgLogoBackground, 0, 0)
	gr.setFont(menuFont)
	if menu.page == mpMain then
		local options = {"Continue", "New Game", "Options", "Quit Game"}

		for i, o in ipairs(options) do
			y = screenH - (menu.spacing * (4+2)) + (menu.spacing * i)
      gr.setColor(unpack(colors["menushadow"]))
			gr.print(options[i], x, y)
			if i == menu.selection then
      	gr.setColor(unpack(colors["menuselected"]))
			else
      	gr.setColor(unpack(colors["menutext"]))
			end
			gr.print(options[i], x, y+2)
		end
	elseif menu.page == mpOptions then
		local options = {"Music", "Sound FX", "Volume", "Resolution", "Toggle Fullscreen", "Back"}
		local values = { musicOn, soundOn, soundVolume, resString, "", "" }

    gr.setColor(unpack(colors["menushadow"]))
    gr.print("Options", x, 58)
    gr.setColor(unpack(colors["menuselected"]))
		gr.print("Options", x, 60)

		for i, o in ipairs(options) do
			y = screenH - (menu.spacing * (6+2)) + (menu.spacing * i)
			local valTxt
			if i == 1 or i == 2 then if values[i] == true then valTxt = "On" else valTxt = "Off" end else valTxt = tostring(values[i]) end
      gr.setColor(unpack(colors["menushadow"]))
			gr.print(options[i], x, y)
			gr.print(valTxt, x+200, y)
			if i == menu.selectionB then
      	gr.setColor(unpack(colors["menuselected"]))
			else
      	gr.setColor(unpack(colors["menutext"]))
			end
			gr.print(options[i], x, y+2)
			gr.print(valTxt, x+200, y+2)
		end
	elseif menu.page == mpScreens then
		gr.setColor(255,255,255,255)
		gr.print("Resolution:", 100, 24)

		for i, mode in ipairs(screenModes) do
			local desc = string.format("%dx%d", mode.width, mode.height)
			local y = (menu.spacing * i) + 30
			gr.print(desc, 120, y)
		end

	elseif menu.page == mpQuit then
		options = { "Continue", "Quit"}

    gr.setColor(0,0,0,150)
    gr.print("Quit Game?", x+2, 58)
		gr.setColor(255,255,255,255)
		gr.print("Quit Game?", x, 60)

		for i, o in ipairs(options) do
			y = screenH - (menu.spacing * (2+2)) + (menu.spacing * i)
      gr.setColor(unpack(colors["menushadow"]))
			gr.print(options[i], x, y)
			if i == quitSelection+1 then
      	gr.setColor(unpack(colors["menuselected"]))
			else
      	gr.setColor(unpack(colors["menutext"]))
			end
			gr.print(options[i], x, y+2)
		end
		gr.setColorMode("replace")
	end
end

function drawInventory()
  if inventory.opened == true then
    gr.setColor(0,0,0,200)
    gr.rectangle("fill", 0,0,800,500)
    gr.setFont(dialogFont)
    gr.print("Inventory:", 16,16)
    local row, col = 0, 0
  	for i, v in pairs(inventoryList) do
      local x, y = (col * 72) + 24, (row * 72) + 48
      if i == inventory.selected then
        gr.setColor(255,255,255)
      else
        gr.setColor(150,150,150)
      end
  	  gr.print(v.name, x,y+50)
  	  gr.print(v.count, x+32,y+50)
      gr.rectangle("line", x-.5,y-.5,64,64)
      gr.setColor(200,100,255)
      gr.rectangle("fill", x+8, y+2, 48, 48)

      col = col + 1
      if col >= 10 then
        col = 0
        row = row + 1
      end
  	end
  end
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
			scriptData = scriptData .. " actorIsMoving:    " .. tostring(actorIsMoving) .. "\n"
			scriptData = scriptData .. " actorMoveSteps:   " .. tostring(actorMoveSteps) .. "\n"
			if objIsMoving > 0 then
				scriptData = scriptData .. " objIsMoving:  " .. tostring(objIsMoving) .. "\n"
				scriptData = scriptData .. " objMoveSteps: " .. tostring(objMoveSteps) .. "\n"
				scriptData = scriptData .. " objX:         " .. tostring(_f(switch[objIsMoving].x)) .. " (" .. _f(switch[objIsMoving].x/32) .. ")\n"
				scriptData = scriptData .. " objY:         " .. tostring(_f(switch[objIsMoving].y)) .. " (" .. _f(switch[objIsMoving].y/32) .. ")\n"
			end
			scriptData = scriptData .. " chainScript:        " .. chainScript .. "\n"
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
		debugData = debugData .. "\n Mouse:     " .. ms.getX()-mapOffsetX .. "," .. ms.getY()-mapOffsetY
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