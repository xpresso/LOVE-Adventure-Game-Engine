function movePushable(id, dir)
  if pushables[id].times ~= 0 then
    if pushables[id].canMove == true then
      local can = true
      if dir == 1 then
        if checkCol(pushables[id].x-32, pushables[id].y-32, "Col_Pushable_1") == false then
          pushables[id].tx = pushables[id].tx - 32
        else
          can = false
        end
      elseif dir == 2 then
        if checkCol(pushables[id].x, pushables[id].y-32-32, "Col_Pushable_2") == false then
          pushables[id].ty = pushables[id].ty - 32
        else
          can = false
        end
      elseif dir == 3 then
        if checkCol(pushables[id].x+32, pushables[id].y-32, "Col_Pushable_3") == false then
          pushables[id].tx = pushables[id].tx + 32
        else
          can = false
        end
      elseif dir == 4 then
        if checkCol(pushables[id].x, pushables[id].y+32-32, "Col_Pushable_4") == false then
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
	if checkCol(npx, npy, "Col_Check_Wall_TL") == false and checkCol(npx+31, npy, "Col_Check_Wall_TR") == false and checkCol(npx+31, npy, "Col_Check_Wall_BR") == false and checkCol(npx+31, npy+31, "Col_Check_Wall_TR") == false then
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
	if player.invincible <= 0 then
		playSound(18)
		if player.health > 0 then player.health = player.health - h end
		if player.health < 0 then player.health = 0 end
		player.invincible = player.invincibleTime
		player.knockTime = 24
		player.knockDir = dir
		local nw = (200/player.maxHealth)
		table.insert(healthNuggets, { x = 48+20+nw*player.health, y = screenH-50, w = nw*h, grav = -4 })
	end
end

--INVENTORY
function openInventory()
  inventoryList = {}
  for i, v in pairs(inventoryItems) do
    inventoryList[#inventoryList+1] = v
  end
  table.sort(inventoryList, function(a, b) return a.name < b.name end )
	inventory.opened = true
end

function closeInventory()
  inventoryList = nil
	inventory.opened = false
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

	if cut.statTo > cut.stat then
		cut.stat = cut.stat + (1020 * dt)
		if cut.stat > 255 then cut.stat = 255 end
	end
	if cut.statTo < cut.val then
		cut.stat = cut.stat - (1020 * dt)
		if cut.stat < 0 then cut.stat = 0 end
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
  print("Playing Music: "..m)
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
  --print("Playing Sound FX: "..s)
	if soundOn and enableAudio and sfx[s] then
	  --love.audio.play(sfx[s])
	  soundmanager:play(sfx[s])
	end
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
  if logoExists == nil then
    logoExists = true
    menuTitle:setFilter("nearest","nearest")

    logoFade = 0
    logoFadeTo = 255
    logoFadeSpeed = 1024
    playSound(59)
    logoBounceJ = startBounce(30, 5, 4)
    bounce[logoBounceJ].bounceCall = function() playSound(15) end
    setTimeOut(1,function()
      logoBounceP = startBounce(20, 4, 4)
      bounce[logoBounceP].bounceCall = function() playSound(15) end
    end,10101)

  end
end

function logoUpdate(dt)
	if logoFadeTo > logoFade and logoFade < 255 then
		logoFade = logoFade + logoFadeSpeed * dt
		if logoFade > 255 then logoFade = 255 end
	end
	if logoFadeSpeed > 1 then logoFadeSpeed = logoFadeSpeed - 1024 * dt end
	updateBounce(dt)
end

function logoDraw()
	gr.setBlendMode("alpha")
	gr.setColorMode("modulate")

	gr.setBackgroundColor(255,255,255)

  local sc = logoFade/255
--[[
	gr.setColor(0,0,0,100)
	gr.drawq(menuTitle, imgLogoJasoco, screenW/2+2, screenH/2+5-50, 0, sc, sc, 256, 55)
	gr.drawq(menuTitle, imgLogoPresents, screenW/2+2, screenH/2+5+60, 0, sc, sc, 130, 27)
--]]

	gr.setColor(0,0,0,5)
  for i=1,20 do
  	gr.drawq(menuTitle, imgLogoJasoco, screenW/2+(_r(-20,20)*sc), _f(screenH/2-50-bounceOffset(logoBounceJ))+(_r(-20,20)*sc), 0, sc*(_r(10,12)/10), sc*(_r(10,12)/10), 256, 110)
  end
	gr.setColor(255,255,255)
	gr.drawq(menuTitle, imgLogoJasoco, screenW/2, _f(screenH/2-50-bounceOffset(logoBounceJ)), 0, sc, sc, 256, 110)
	if logoBounceP then gr.drawq(menuTitle, imgLogoPresents, screenW/2, _f(screenH/2+30-bounceOffset(logoBounceP)), 0, sc, sc, 130, 54) end
end

function setTutorMsg(t)
  onScreenTutorialTime = 3
  onScreenTutorialMsg = t
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

function formatNumber(number)
   return (string.format("%d", number):reverse():gsub( "(%d%d%d)" , "%1," ):reverse():gsub("^(-?),","%1"))
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

