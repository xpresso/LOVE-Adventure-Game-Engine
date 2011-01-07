--Load the script of your choice.
function loadScript(s)
	print("Loaded Script "..s)
	chainScript = ""
	script = {}
	local mFile = "game/scripts/" .. s .. ".lua"
	if love.filesystem.exists(mFile) then
		love.filesystem.load(mFile)()
		table.insert(script, {c = "", p1 = nil, p2 = nil, p3 = nil, p4 = nil, d = false})
		scriptLength = table.getn(script) + 1
		scriptRunning = true
		scriptLine = 1
		scriptWaitingForCamera = false
	else
		error("Oops! It seems you are missing a certain script file.\nThe script \"" .. mFile .. "\" seems to be missing from its home.\nThis is not good since the game has no direction in life and must now end.")
	end
	player.walking = 0
	player.moving = false
end

--Do all the Script processing.
function runScript(dt)
	if actorIsMoving > -1 then moveActor(dt) end

	if scriptWaitingForCamera == true then
	  if camera.movingX == true or camera.movingY == true then
	    scriptPaused = true
	  else
	    scriptWaitingForCamera = false
	    scriptPaused = false
			script[scriptLine].d = true
	  end
	end

	if scriptWaiting == true then
		if time > scriptWaitTime + scriptWaitSeconds then
			scriptPaused = false
			scriptWaiting = false
			scriptWaitTime = 0
			scriptWaitSeconds = 0
			script[scriptLine].d = true
		end
	end

	if scriptPaused == false and scriptRunning == true then
		if scriptLine < scriptLength and (script[scriptLine].d == false or script[scriptLine].d == nil) then
			local l = script[scriptLine].c
			local p1 = script[scriptLine].p1 or nil
			local p2 = script[scriptLine].p2 or nil
			local p3 = script[scriptLine].p3 or nil
			local p4 = script[scriptLine].p4 or nil
			local p5 = script[scriptLine].p5 or nil
			if l == "DIALOG" then
				dialogWhoSaid = p1
				setDialogText(p2)
				openDialog()
				if script[scriptLine+1].c == "DIALOG" then dialog.nextToo = true else dialog.nextToo = false end
			elseif l == "PLAYSOUND" then
				playSound(p1)
				script[scriptLine].d = true
			elseif l == "WARP" then
				fade.to = 255
				if fade.val >= 255 then
					facePlayer(p4)
					player.x = tonumber(p2) * 32
					player.y = tonumber(p3) * 32
					scrollToX = player.x
					scrollToY = player.y
					camera.x = player.x
					camera.y = player.y
					mapNumber = p1
					changeMap = true
					calculateMapOffset()
					calculateMapBounds(dt)
					script[scriptLine].d = true
				end
			elseif l == "SETPLAYERPOS" then
				facePlayer(p3)
				player.x = tonumber(p1) * 32
				player.y = tonumber(p2) * 32
				script[scriptLine].d = true
			elseif l == "MOVEPLAYER" then
				actorIsMoving = 0
				actorMoveSteps = 32 * tonumber(p2)
				actorMoveDirection = p1
			elseif l == "CHANGEMAP" then
				fade.to = 255
				if fade.val >= 255 then
					changeMap = true
					mapNumber = p1
					script[scriptLine].d = true
				end
			elseif l == "GIVEMONEY" then
				player.money = player.money + tonumber(p1)
				if player.money > player.wallet then player.money = player.wallet end
				script[scriptLine].d = true
			elseif l == "TAKEMONEY" then
				player.money = player.money - tonumber(p1)
				if player.money < 0 then player.money = 0 end
				script[scriptLine].d = true
			elseif l == "MOVENPC" then
				for x=0,mapWidth/32-1 do
					for y=0,mapHeight/32-1 do
						if mapHit[x][y] == "n" then mapHit[x][y] = "." end
					end
				end
				actorIsMoving = tonumber(p1)
				actorMoveSteps = 32 * tonumber(p3)
				actorMoveDirection = p2
			elseif l == "FACENPC" then
				if p2 == "L" then
					npc[p1].facing = 1
				elseif p2 == "U" then
					npc[p1].facing = 2
				elseif p2 == "R" then
					npc[p1].facing = 3
				elseif p2 == "D" then
					npc[p1].facing = 4
				end
				script[scriptLine].d = true
			elseif l == "WARPNPC" then
				npc[p1].map = p2
				npc[p1].x = tonumber(p3) * 32
				npc[p1].y = tonumber(p4) * 32+32
				for x=0,mapWidth/32-1 do
					for y=0,mapHeight/32-1 do
						if mapHit[x][y] == "n" then mapHit[x][y] = "." end
					end
				end
				updateNPCs()
				script[scriptLine].d = true
			elseif l == "WAIT" then
				scriptWaiting = true
				scriptPaused = true
				scriptWaitSeconds = tonumber(p1)
				scriptWaitTime = time
			elseif l == "SCROLLLOCK" then
				if p1 == "PLAYER" then
					lockCamera(0,p4,player.x,player.y)
				elseif p1 == "COORDS" then
					lockCamera(1,p4,p2,p3)
				end
				script[scriptLine].d = true
			elseif l == "MOVECAMERA" then
			  setCamera(p1, p2)
				script[scriptLine].d = true
			elseif l == "WAITFORCAMERA" then
				scriptWaitingForCamera = true
			elseif l == "DEACTIVATEHOTZONE" then
				hotzone[p1].active = false
				script[scriptLine].d = true
			elseif l == "ACTIVATEHOTZONE" then
				hotzone[p1].active = true
				script[scriptLine].d = true
			elseif l == "DESTROYHOTZONE" then
				hotzone[p1].active = false
				script[scriptLine].d = true
			elseif l == "ACTIVATESWITCH" then
				if p3 > 0 then playSound(p3) end
				switch[p1].state = p2
				script[scriptLine].d = true
			elseif l == "CHANGEPUSHABLEIMG" then
				if p3 > 0 then playSound(p3) end
				pushables[p1].img = p2
				script[scriptLine].d = true
			elseif l == "SETMUSIC" then
        setMusic(p1)
				script[scriptLine].d = true
			elseif l == "SETWEATHER" then
				setWeather(p1, p2, p3)
				script[scriptLine].d = true
			elseif l == "QUAKEBEGIN" then
				camera.shaking = true
				script[scriptLine].d = true
			elseif l == "QUAKEEND" then
				camera.shaking = false
				script[scriptLine].d = true
			elseif l == "FILLHEALTH" then
				player.health = player.maxHealth
				script[scriptLine].d = true
			elseif l == "CUTSCENE" then
				if p1 == "IN" then
					cut.to = 50
					cut.statTo = 0
				elseif p1 == "OUT" then
					cut.to = 0
          cut.statTo = 255
				end
				script[scriptLine].d = true
			elseif l == "SOMETHINGTOSAY" then
				npc[p1].somethingToSay = p2
				script[scriptLine].d = true
			elseif l == "WALKUPSTAIRS" then
				script[scriptLine].d = true
			elseif l == "WALKDOWNSTAIRS" then
				script[scriptLine].d = true
			elseif l == "SETFLAG" then
        gameFlag[p1] = p2
				script[scriptLine].d = true
			else
				--Invalid Script Command / Ignore instead of freeze in an infinite loop
				script[scriptLine].d = true
			end
		end

		if script[scriptLine].d == true then scriptLine = scriptLine + 1 end

		if scriptLine >= scriptLength then unloadScript() end
	end
end

--Delete the script from memory when done.
function unloadScript()
	print("Unloaded Script")
	script = {}
	scriptRunning = false
	scriptLine = 0
	currentScript = ""
	scriptLength = 0
	scriptPaused = false
	queryChoices = nil
	cut.to = 0
	cut.statTo = 255
end

--DIALOG
--Set the text and reset the cursor.
function setDialogText(t)
	print("Set Dialog Text \""..t.."\"")
	dialog.text = t
	dialog.cursor = 0
end

--Tell the system a dialog needs to be opened
function openDialog()
	print("Open Dialog")
	dialog.opened = true
	scriptPaused = true
	dialog.queryChoice = 1

	dialog.w = screenW
	dialog.h = 160

	local spaceAbove, spaceBelow, horizOffset
	if dialogWhoSaid > 0 then
		spaceAbove = npc[dialogWhoSaid].y + mapOffsetY - 60 + camera.shakeX
		spaceBelow = screenH - (npc[dialogWhoSaid].y + mapOffsetY) - 60 -- + camera.shakeY
		horizOffset = npc[dialogWhoSaid].x + mapOffsetX
	else
		spaceAbove = player.y + mapOffsetY - 60
		spaceBelow = screenH - spaceAbove - 50
		horizOffset = 0
	end
	dialog.w = 640-64

	if spaceAbove < 180 then
		dialog.location = 1
		dialog.y = screenH - dialog.h
	else
		dialog.location = 0
		dialog.y = 0
	end

	if horizOffset < screenW / 2 then
		dialog.x = 32
	else
		dialog.x = screenW - dialog.w - 32
	end

	print(spaceAbove)

	playSound(998)
end

--Draw the complex dialog on screen depending on the method and type used.
function drawDialog(dt)
	if dialog.opened == true then
		gr.setColorMode("modulate")
		if dialogWhoSaid <= 0 then
			gr.setColor(0,0,0,127)
			gr.rectangle("fill", 0, dialog.y, screenW, dialog.h)
		else
			--TALK BALLOON SHADOW
			local sOff = 6
			gr.setColor(0,0,0,127)
			gr.rectangle("fill", 0, dialog.y+sOff, screenW, dialog.h)
			gr.setColor(0,0,0,255)
			if dialog.location ~= 1 then gr.drawq(menuTitle, dialogGrid[4][0], npc[dialogWhoSaid].x + mapOffsetX + camera.shakeX - 16, dialog.y + dialog.h + sOff) end

			--TALK BALLOON
			gr.setColor(255,255,255,255)
			gr.rectangle("fill", 0, dialog.y, screenW, dialog.h)
			if dialog.location == 1 then
				gr.drawq(menuTitle, dialogGrid[1][0], npc[dialogWhoSaid].x + mapOffsetX + camera.shakeX - 16, dialog.y - 32)
			else
				gr.drawq(menuTitle, dialogGrid[0][0], npc[dialogWhoSaid].x + mapOffsetX + camera.shakeX - 16, dialog.y + dialog.h)
			end
		end

    dit = 60
    if dialog.location == 1 then dit = 20 end
		m = string.sub(dialog.text, 1, dialog.cursor)
		m2 = string.sub(dialog.text, 1, dialog.cursor+1)
		gr.setFont(dialogFont)
		if dialogWhoSaid <= 0 then gr.setColor(255,255,255,10) else gr.setColor(0,0,0,10) end
    for i=1,10 do
  		gr.printf(m2, 32+_r(-4,4), dialog.y + dit+_r(-4,4), screenW-64, "center")
  	end
		if dialogWhoSaid <= 0 then gr.setColor(255,255,255,255) else gr.setColor(0,0,0,255) end
		gr.printf(m, 32, dialog.y + dit, screenW-64, "center")

		if dialog.cursor < string.len(dialog.text) then
			if string.sub(m, -1) ~= " " then playSound(997) end
			dialog.cursor = dialog.cursor + dialog.speed * dt
		else
			if queryChoices ~= nil then
				gr.setColor(255,255,255,255)
				gr.rectangle("fill", (screenW/2)-200+((dialog.queryChoice-1)*200), screenH - 40, 200, 32)

				for i=1,table.getn(queryChoices) do
					if i == dialog.queryChoice then gr.setColor(0,0,0,255) else gr.setColor(255,255,255,255) end
					gr.printf(queryChoices[i], (screenW/2)-200+((i-1)*200), screenH - 40+5, 200, "center")
				end
			end
			gr.setColor(255,255,255,255)
			gr.setFont(dialogFont)
			gr.print("PRESS SPACE", screenW - 180, 10)
		end
		gr.setColorMode("replace")
	end
end

--Called to close the dialog and return control to the scripting system.
function closeDialog()
	print("Close Dialog")
	dialog.text = ""
	dialog.cursor = 0
	if dialog.nextToo == false then dialog.opened = false end
	scriptPaused = false
	script[scriptLine].d = true
end

--Turn the player in the direction you want without moving.
function facePlayer(d)
	if d == "L" then
		player.facing = 1
	elseif d == "U" then
		player.facing = 2
	elseif d == "R" then
		player.facing = 3
	elseif d == "D" then
		player.facing = 4
	end
end

--When the script calls for an NPC to be moved, this does the moving.
function moveActor(dt)
  if actorIsMoving == 0 then
    player.moving = true
		scriptPaused = true
		if actorMoveSteps > 0 then
			if actorMoveDirection == "L" then
				player.x = player.x - 2
				player.facing = 1
			elseif actorMoveDirection == "U" then
				player.y = player.y - 2
				player.facing = 2
			elseif actorMoveDirection == "R" then
				player.x = player.x + 2
				player.facing = 3
			elseif actorMoveDirection == "D" then
				player.y = player.y + 2
				player.facing = 4
			end
			actorMoveSteps = actorMoveSteps - 2
			player.walking = player.walking + 1
			if player.walking >= 32 then player.walking = 0 end
		else
			player.x = _f(player.x)
			player.y = _f(player.y)
			player.moving = false
			player.walking = 0
			actorIsMoving = -1
		end
	elseif actorIsMoving > 0 then
		npc[actorIsMoving].walking = true
		scriptPaused = true
		if actorMoveSteps > 0 then
			if actorMoveDirection == "L" then
				npc[actorIsMoving].x = npc[actorIsMoving].x - 4
				npc[actorIsMoving].facing = 1
			elseif actorMoveDirection == "U" then
				npc[actorIsMoving].y = npc[actorIsMoving].y - 4
				npc[actorIsMoving].facing = 2
			elseif actorMoveDirection == "R" then
				npc[actorIsMoving].x = npc[actorIsMoving].x + 4
				npc[actorIsMoving].facing = 3
			elseif actorMoveDirection == "D" then
				npc[actorIsMoving].y = npc[actorIsMoving].y + 4
				npc[actorIsMoving].facing = 4
			end
			actorMoveSteps = actorMoveSteps - 4
			npc[actorIsMoving].step = npc[actorIsMoving].step + 2
			if npc[actorIsMoving].step >= 32 then npc[actorIsMoving].step = 0 end
		else
			npc[actorIsMoving].x = _f(npc[actorIsMoving].x)
			npc[actorIsMoving].y = _f(npc[actorIsMoving].y)
			npc[actorIsMoving].walking = false
			npc[actorIsMoving].step = 0
			actorIsMoving = -1
		end
	end
	if actorIsMoving == -1 then
		updateNPCs()
		scriptPaused = false
		script[scriptLine].d = true
	end
end

function insertDialog(txt,who,lines)
	table.insert(script, {c = "DIALOG", p1 = who, p2 = txt, p3 = lines, p4 = nil, d = false})
end

function insertWait(t)
	table.insert(script, {c = "WAIT", p1 = t, p2 = nil, p3 = nil, p4 = "D", d = false})
end

function insertWarp(map, x, y, face)
	table.insert(script, {c = "WARP", p1 = map, p2 = x, p3 = y, p4 = face, d = false})
end

function insertCutSceneBars(d)
	table.insert(script, {c = "CUTSCENE", p1 = d, p2 = nil, p3 = nil, p4 = nil, d = false})
end