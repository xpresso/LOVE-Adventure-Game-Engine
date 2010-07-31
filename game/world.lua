--Update locations of projectile weapons, either from enemies or the player.
function updateProjectiles(dt)
	for i, p in pairs(projectile) do
		if p.time > -1 then
			p.time = p.time - 1
			if p.ty == pBoom then
				if p.time < 0 then
					--reflectProjectile(i)
				end
			else
				if p.time == 0 then
					playSound(91)
					spawnExplosion(p.x-16,p.y-32)
					spawnExplosion(p.x+16,p.y-32)
					spawnExplosion(p.x-32,p.y)
					spawnExplosion(p.x,p.y)
					spawnExplosion(p.x+32,p.y)
					spawnExplosion(p.x-16,p.y+32)
					spawnExplosion(p.x+16,p.y+32)
					p.detonated = true
				end
			end
		end

		--Move the Projectile
		p.x = p.x + (p.xs * dt)
		p.y = p.y + (p.ys * dt)
		if p.ty ~= pBoom then
			if p.x > xBounds[1] * 32 then destroyProjectile(i) end
			if p.y > yBounds[1] * 32 then destroyProjectile(i) end
			if p.x < xBounds[0] * 32 then destroyProjectile(i) end
			if p.y < yBounds[0] * 32 then destroyProjectile(i) end
		end

		local hitTarget = false
		if p.owner == 1 then
			--If the owner is the PLAYER, then check for collision with an ENEMY
			for j, e in ipairs(enemy) do
				if p.ty ~= pBomb then
					--General projectile hits
					if overlap(_f(e.x), _f(e.y-32), 32, 32, _f(p.x)+8, _f(p.y-32)+8, 16, 16, 7921) == true then
						if p.xs < 0 and p.ys == 0 then d = 1 elseif p.xs > 0 and p.ys == 0 then d = 3 elseif p.xs == 0 and p.ys < 0 then d = 2 elseif p.xs == 0 and p.ys > 0 then d = 4 else d = 0 end
						knockEnemy(j, d, p.pow)
						if p.ty ~= pArrow then spawnExplosion(p.x,p.y) end
						if p.ty == pArrow then playSound(502) end
						destroyProjectile(i)
					end
				elseif p.ty == pBomb and p.detonated then
				 	--BOMB EXPLOSION!
					if overlap(_f(p.x)-32, _f(p.y)-32, 96, 96, _f(enemy[j].x), _f(enemy[j].y), 32, 32, 7922) == true then
						damageEnemy(j, 5)
					end
				end
			end
		elseif p.owner == 2 then
			--If the owner is an ENEMY, then check for collision with PLAYER
			if p.ty ~= pBomb then
				--General projectile hits
				if overlap(_f(player.x), _f(player.y), 32, 24, _f(p.x)+8, _f(p.y)+8, 16, 16, 7923) == true then
					if player.hasShield == true then
						if (p.f == 1 and player.facing == 3) or (p.f == 3 and player.facing == 1) or (p.f == 2 and player.facing == 4) or (p.f == 4 and player.facing == 2) then
							if p.ty == pRock then
								reflectProjectile(i)
							else
								--spawnExplosion(p.x,p.y)
								destroyProjectile(i)
							end
						else
							hurtPlayer(p.pow, 1)
							spawnExplosion(p.x,p.y)
							destroyProjectile(i)
						end
					else
						hurtPlayer(p.pow)
						spawnExplosion(p.x,p.y)
						destroyProjectile(i)
					end
				end
			elseif p.ty == pBomb and p.time == 0 then
				--BOMB EXPLOSION!
				if overlap(_f(p.x)-32, _f(p.y)-32, 128, 128, _f(player.x), _f(player.y), 32, 32, 7924) == true then
					knockEnemy(j, 4, p.pow)
				end
			end
		end
		if checkCol(p.x+16, p.y-16, 8901, 2) == true or hitTarget == true then
			if p.ty == pArrow then playSound(502) end
			if p.ty ~= pArrow then spawnExplosion(p.x,p.y) end
			if p.ty ~= pBomb then destroyProjectile(i) end
		end
		if p.detonated == true then
			destroyProjectile(i)
		end
		local ss = #sprites+1
		sprites[ss] = p
		sprites[ss].n = "Projectile"
	end
end

function spawnProjectile(x,y,t,d,s,o,tm,p)
	print("Spawning Projectile @ " .. time)
	local xs, ys, r
	if d == 1 then
		xs = -s ys = 0
	elseif d == 3 then
		xs = s ys = 0
	elseif d == 2 then
		xs = 0 ys = -s
	elseif d == 4 then
		xs = 0 ys = s
	end
	if t == pBoom then r = 0 else r = d-1 end
	table.insert(projectile, {x = x, y = y, xs = xs, ys = ys, spd = s, ty = t, owner = o, r = r, size = 1, time = tm, pow = p, spin = 0, hasReflected = false, detonated = false, f = d, step = 0})
end

function destroyProjectile(p)
	print("Removing Projectile: " .. p .. " @ " .. time)
	table.remove(projectile, p)
end

function reflectProjectile(p)
	print("Reflecting: " .. p)
	print(projectile[p].xs)
	projectile[p].xs = -projectile[p].xs
	projectile[p].ys = -projectile[p].ys
	projectile[p].hasReflected = true
	projectile[p].time = -1
	projectile[p].f = projectile[p].f - 2
	if projectile[p].f == 0 then projectile[p].f = 4 end
	if projectile[p].f == -1 then projectile[p].f = 3 end
	if projectile[p].owner == 2 then projectile[p].owner = 1 end
	if projectile[p].ty ~= pBoom then playSound(15) end
end

function fireArrow(ty, d, s, o)
	if player.arrows > 0 then
		player.arrows = player.arrows - 1
		spawnProjectile(player.x, player.y, ty, d, s, o, -1, player.arrowPower)
		playSound(501)
	end
end

function placeBomb(x, y, tm, o)
	if player.bombs > 0 then
		playSound(90)
		player.bombs = player.bombs - 1
		spawnProjectile(x, y, pBomb, 1, 0, o, tm, 5)
	end
end

function throwBoomerang(tm, d, s, o)
	if player.boomerangActive == false then
		player.boomX = player.x+16
		player.boomY = player.y-16
		player.boomDist = 0
		player.boomMaxDist = 512
		if player.targeting > 0 then
			player.boomAngle = player.targetAng+90
			player.boomTargetX = enemy[player.targeting].x
			player.boomTargetY = enemy[player.targeting].y
		else
			if player.facing == 1 then
				player.boomAngle = 270
			elseif player.facing == 2 then
				player.boomAngle = 180
			elseif player.facing == 3 then
				player.boomAngle = 90
			elseif player.facing == 4 then
				player.boomAngle = 0
			end
			player.boomTargetX = (player.x+16) + (_s((player.boomAngle) * pi / 180) * player.boomMaxDist) * 1
			player.boomTargetY = (player.y-16) + (_c((player.boomAngle) * pi / 180) * player.boomMaxDist) * 1
		end
		player.boomReturn = false
	end
	player.boomerangActive = true
end

function returnBoomerang()
	player.boomerangActive = false
	if player.boomerangActive == false then
		player.boomDist = 0
		player.boomMaxDist = 512
		player.boomAngle = 270
		player.boomTargetX = player.x+16
		player.boomTargetY = player.y-16
		player.boomReturn = true
	end
	player.boomerangActive = true
end

--pboom
function updateBoomerang(dt)
	if player.boomerangActive then
		--Spin the Boomerang
		player.boomSpin = player.boomSpin + 360 * dt

		if player.boomReturn then
			player.boomAngle = findAngle(player.x+16, player.y+16, player.boomX, player.boomY)-90
			player.boomX = player.boomX + (_s((player.boomAngle) * pi / 180) * (player.boomSpeed * dt)) * 1
			player.boomY = player.boomY + (_c((player.boomAngle) * pi / 180) * (player.boomSpeed * dt)) * 1
			if player.boomX+16 > player.x and player.boomX < player.x+32 and player.boomY+16 > player.y and player.boomY < player.y+32 then
				player.boomerangActive = false
			end
		else
			if player.boomDist < player.boomMaxDist then
				player.boomDist = player.boomDist + (player.boomSpeed * dt)
			else
				returnBoomerang()
			end
			if player.targeting > 0 then
				player.boomAngle = player.targetAng+90
			end
			player.boomX = player.boomX + (_s((player.boomAngle) * pi / 180) * (player.boomSpeed * dt)) * 1
			player.boomY = player.boomY + (_c((player.boomAngle) * pi / 180) * (player.boomSpeed * dt)) * 1
		end

		--Collect items
		for k, d in ipairs(dropped) do
			if overlap(_f(d.x), _f(d.y), 32, 32, _f(player.boomX-16), _f(player.boomY-16), 32, 32, 7925) == true then
				giveItem(d.id)
				destroyDropped(k)
			end
		end

		for j, e in ipairs(enemy) do
			if overlap(_f(e.x), _f(e.y), 32, 32, _f(player.boomX)-16, _f(player.boomY)-16, 32, 32, 7926) == true then
				if player.boomReturn == false and player.boomerangPower == 1 then returnBoomerang() end
				if player.boomerangPower == 1 then
					e.stunned = true
					e.dTimer = 200
				else
					knockEnemy(j, 0, p.pow)
				end
			end
		end

		if checkCol(player.boomX, player.boomY, 8902) == true then
			returnBoomerang()
		end

		local ss = #sprites+1
		sprites[ss] = {
			x = player.boomX,
			y = player.boomY,
			boomSpin = player.boomSpin }
		sprites[ss].n = "Boomerang"
	end
end

explosion = {}

function spawnExplosion(x,y)
	print("Spawning Explosion: " .. x .. "," .. y)
	table.insert(explosion, {x = x, y = y, f = 0})
end

function destroyExplosion(e)
	print("Destroying Explosion: " .. e)
	table.remove(explosion, e)
end

--NPCS
function addNPC(id, map, x, y, name, who, facing, walking, script)
	table.insert(npc, id, {x = x, y = y, map = map, step = 0, walking = walking, who = who, facing = facing, name = name, script = script, somethingToSay = false})
end

function updateNPCs()
	for i, p in ipairs(npc) do
		if mapNumber == p.map then
			mapHit[p.x/32][p.y/32] = "n"
		end
	end

	for i, s in pairs(switch) do
		if mapNumber == s.map and s.t == 2 then
			--print(switch[i].sx, i)
			mapHit[_f(switch[i].sx/32)][_f(switch[i].sy/32)-1] = "x"
		end
	end
end

--SWITCHES
function addSwitch(id, map, x, y, state, i1, i2, t, s, ox, oy)
	switch[id] = {map = map, sx = x+ox, sy = y+oy, x = x, y = y, state = state, imgOn = i1, imgOff = i2, t = t, script = s, ox = ox, oy = oy}
end

function addPushable(id, x, y, so, cm, i, sc, t)
  if t == nil then t = -1 end
	pushables[id] = { x = x, y = y+32, img = i, script = sc, moving = false, tx = x, ty = y+32, sound = so, canMove = cm, times = t }
	if mapHit[x/32][y/32] == "." then mapHit[x/32][y/32] = "w" end
end

--ITEMS/DROPPED
function spawnDropped(id,xx,yy,t)
	table.insert(dropped, { x = _f(xx), y = _f(yy), time = t, id = id, f = 0, dt = time, life = 10 })
end

function updateDropped(dt)
	for i, d in ipairs(dropped) do
		d.f = _s((time-d.dt)*5)*2
		if menu.opened == false then
			d.life = d.life - dt
			if d.life <= 0 then destroyDropped(i) end
			if overlap(_f(d.x), _f(d.y-32), 32, 32, _f(player.x)+2, _f(player.y-32)+2, 28, 28, 7927) == true then
				giveItem(d.id)
				destroyDropped(i)
			end
		end
	end
end

function destroyDropped(dr) table.remove(dropped, dr) end

function giveItem(d)
	player.health = player.health + tonumber(dTable[d].giveHP)
	player.money = player.money + tonumber(dTable[d].giveMoney)
	player.arrows = player.arrows + tonumber(dTable[d].giveArrows)
	player.bombs = player.bombs + tonumber(dTable[d].giveBombs)
	if player.health > player.maxHealth then player.health = player.maxHealth end
	if dTable[d].giveMoney > 0 then
		playSound(50)
	elseif dTable[d].giveHP > 0 then
		playSound(52)
	else
		playSound(51)
	end
end

function createEnemy(t, x, y, s, e)
	local ww = 32
	local hh = 32
	local simple, hw, f, spd, pt, thp
	if t == 1 then h = 1 elseif t == 2 then h = 2 elseif t == 3 then h = 3 elseif t == 4 then h = 2 elseif t == 5 then h = 1 end
	if t == 4 then pt = pArrow else pt = pRock end
	if t == 5 then
		simple = true
		hw = false
		f = true
		thp = .25
	else
		simple = false
		hw = true
		f = false
		thp = .5
	end
	if t == 1 then spd = 32 elseif t == 2 then spd = 64 elseif t == 3 then spd = 128 else spd = 64 end
	table.insert(enemy, {x = x, y = y, w = ww, h = hh, HP = h, t = t, inv = 0, facing = _r(1,4), XP = 10, pt = pt, doing = 0, dTimer = _r(20,100), flying = f, step = 0, speed = spd, mh = 0, mv = 0, frozen = false, knockTime = -1, knockDir = -1, takeHP = thp, hasWeapon = hw, stunned = false, simple = simple, script = s, dist = 0})
	if e then spawnExplosion(x,y) end
end

function damageEnemy(e, d)
	print("Damage Enemy "..e.." with "..d)
	playSound(100)
	enemy[e].HP = enemy[e].HP - d
	if enemy[e].HP <= 0 then destroyEnemy(e) end
end

function knockEnemy(e, dir, p)
	print("Knock Enemy "..e.." with "..p)
	if enemy[e].inv < 1 then enemy[e].inv = 10 end
	enemy[e].takeHP = p
	enemy[e].knockTime = 24
	enemy[e].knockDir = dir
end

function moveEnemy(e, dt)
	local tex, tey
	if enemy[e].knockTime > 0 then
		if enemy[e].knockDir == 1 then
			tex = enemy[e].x - 256 * dt
			if checkCol(tex, enemy[e].y-31, 8903) == false and checkCol(tex, enemy[e].y-1, 8904) == false then enemy[e].x = tex else enemy[e].knockTime = 0 end
		elseif enemy[e].knockDir == 3 then
			tex = enemy[e].x + 256 * dt
			if checkCol(tex+32, enemy[e].y-31, 8905) == false and checkCol(tex+32, enemy[e].y-1, 8906) == false then enemy[e].x = tex else enemy[e].knockTime = 0 end
		elseif enemy[e].knockDir == 2 then
			tey = enemy[e].y - 256 * dt
			if checkCol(enemy[e].x + 1, tey-31, 8907) == false and checkCol(enemy[e].x + 31, tey-31, 8908) == false then enemy[e].y = tey else enemy[e].knockTime = 0 end
		elseif enemy[e].knockDir == 4 then
			tey = enemy[e].y + 256 * dt
			if checkCol(enemy[e].x + 1, tey-1, 8909) == false and checkCol(enemy[e].x + 31, tey-1, 8910) == false then enemy[e].y = tey else enemy[e].knockTime = 0 end
		end
		enemy[e].knockTime = enemy[e].knockTime - 256 * dt
	elseif enemy[e].knockTime <= 0 and enemy[e].knockDir > -1 then
		enemy[e].knockTime = -1
		enemy[e].knockDir = -1
		damageEnemy(e, enemy[e].takeHP)
	else
		--Move the enemies -- Enemy AI -- 0 = Standing, 1 = Moving, 2 = Turning, 3 = Firing
		if enemy[e].dTimer > 0 then enemy[e].dTimer = enemy[e].dTimer - 1 end
		if enemy[e].stunned == false then
			if enemy[e].dTimer <= 0 then
				lastDid = enemy[e].doing
				if enemy[e].simple == true then u = 2 else u = 3 end
				enemy[e].doing = _r(0,u)
				if enemy[e].doing == lastDid then enemy[e].doing = 0 end
				if enemy[e].doing == 2 then
					enemy[e].facing = _r(1,4)
				elseif enemy[e].doing == 1 then
					if enemy[e].t == 5 then
						if enemy[e].facing == 1 then
							enemy[e].mh = -enemy[e].speed
							enemy[e].mv = -enemy[e].speed
						elseif enemy[e].facing == 2 then
							enemy[e].mh = enemy[e].speed
							enemy[e].mv = -enemy[e].speed
						elseif enemy[e].facing == 3 then
							enemy[e].mh = enemy[e].speed
							enemy[e].mv = enemy[e].speed
						elseif enemy[e].facing == 4 then
							enemy[e].mh = -enemy[e].speed
							enemy[e].mv = enemy[e].speed
						end
						enemy[e].dTimer = 50
					else
						enemy[e].dTimer = _r(1,4) * 16
					end
				else
					enemy[e].dTimer = _r(1,4) * 16
				end
			end
			if enemy[e].doing == 1 then
				enemyBehavior(e, dt)
				enemy[e].step = enemy[e].step + .2
				if enemy[e].step > 3 then enemy[e].step = 0 end
			elseif enemy[e].doing == 3 then
				if enemy[e].hasWeapon == true then
					if _r(1,3) == 1 then
						spawnProjectile(enemy[e].x, enemy[e].y, enemy[e].pt, enemy[e].facing, 256, 2, -1, 1)
					end
				end
				enemy[e].doing = 0
			elseif enemy[e].doing == 0 then
				if enemy[e].simple == true then
					enemy[e].step = enemy[e].step + .05
					if enemy[e].step > 3 then enemy[e].step = 0 end
				end
			end
		else
			if enemy[e].dTimer <= 0 then
				enemy[e].stunned = false
				enemy[e].doing = 1
			end
		end
	end
end

function enemyBehavior(e, dt)
	if enemy[e].t == 5 then
		local tex = enemy[e].x - enemy[e].mh * dt
		local tey = enemy[e].y - enemy[e].mv * dt
		if checkCol(tex + 16, enemy[e].y + 16, 8911) == false then
			enemy[e].x = tex
		else
			enemy[e].mh = -enemy[e].mh
		end
		if checkCol(enemy[e].x + 16, tey + 16, 8912) == false then
			enemy[e].y = tey
		else
			enemy[e].mv = -enemy[e].mv
		end
	else
		if enemy[e].facing == 1 then
			tex = enemy[e].x - enemy[e].speed * dt
			if checkCol(tex, enemy[e].y-31, 8913) == false and checkCol(tex, enemy[e].y-1, 8914) == false then enemy[e].x = tex end
		elseif enemy[e].facing == 3 then
			tex = enemy[e].x + enemy[e].speed * dt
			if checkCol(tex+32, enemy[e].y-31, 8915) == false and checkCol(tex+32, enemy[e].y-1, 8916) == false then enemy[e].x = tex end
		elseif enemy[e].facing == 2 then
			tey = enemy[e].y - enemy[e].speed * dt
			if checkCol(enemy[e].x + 1, tey-31, 8917) == false and checkCol(enemy[e].x + 31, tey-31, 8918) == false then enemy[e].y = tey end
		elseif enemy[e].facing == 4 then
			tey = enemy[e].y + enemy[e].speed * dt
			if checkCol(enemy[e].x + 1, tey, 8919) == false and checkCol(enemy[e].x + 31, tey, 8920) == false then enemy[e].y = tey end
		end
	end
end

function destroyEnemy(e)
	print("Destroy Enemy "..e)
	spawnDropped(_r(0,5),enemy[e].x,enemy[e].y,-1)
	spawnExplosion(enemy[e].x,enemy[e].y-16)
	if enemy[e].script ~= "" then currentScript = enemy[e].script end
	table.remove(enemy, e)
	playSound(101)
	closestEnemy.id = 0
	player.targeting = 0
end

function addHotZone(x, y, w, h, s)
	table.insert(hotzone, {x = x, y = y, w = w, h = h, active = true, script = s})
end

function updateHotZones()
	for h, z in ipairs(hotzone) do
		if overlap(z.x, z.y, z.w, z.h, player.x+4, player.y-28, 24, 24, 7928) == true then
			if z.active == true then
				currentScript = z.script
				z.active = false
			end
		end
	end
end

function checkForThing()
	local found = 0
	for i, p in ipairs(npc) do
		if mapNumber == p.map then
			local x,y,w,h
			if player.facing == 1 then
				x,y,w,h = player.x-26,player.y-18,26,4
			elseif player.facing == 3 then
				x,y,w,h = player.x+32,player.y-18,26,4
			elseif player.facing == 2 then
				x,y,w,h = player.x+14,player.y-64,4,32
			elseif player.facing == 4 then
				x,y,w,h = player.x+14,player.y,4,32
			end
			if overlap(x, y, w, h, p.x, p.y, 32, 32, 7929) then
				found = i
				break
			end
		end
	end
	if found == 0 then
		for i, p in pairs(switch) do
			if mapNumber == p.map and p.t ~= 2 then
				local x,y,w,h
				if player.facing == 1 then
					x,y,w,h = player.x-26,player.y-18,26,4
				elseif player.facing == 3 then
					x,y,w,h = player.x+32,player.y-18,26,4
				elseif player.facing == 2 then
					x,y,w,h = player.x+14,player.y-64,4,32
				elseif player.facing == 4 then
					x,y,w,h = player.x+14,player.y,4,32
				end
				if overlap(x, y, w, h, p.x, p.y, 32, 32, 7930) then
					found = i + 1000
					break
				end
			end
		end
	end
	return found
end

function checkForPushSwitch()
	local found = 0
	for i, p in pairs(pushables) do
		if p.x/32 == player.pushX and p.y/32 == player.pushY then
			found = i + 3000
			break
		end
	end
	if found == 0 then
		for j, p in pairs(switch) do
			if mapNumber == p.map then
				if p.sx == player.pushX * 32 and p.sy == player.pushY * 32 and p.t == 2 then
					found = j + 1000
					break
				end
			end
		end
	end
	return found
end

function findByID(val)
	local f = -1
	for h, z in ipairs(hotzone) do
		if z.id == val then
			f = h
		end
	end
	return f
end

--WEATHER
function setWeather(dark, rain, lightning)
	weather.rainRoll = rain
	weather.skyRoll = dark
	weather.lightning = lightning
	weather.lightningNext = _r(100,1000)
end

function updateWeather(dt)
	if weather.lightning == true then
		if weather.lightningTime == 200 then playSound(700) end
		if weather.lightningTime > 0 then
			weather.lightningTime = weather.lightningTime - ((100 * dt) * 5)
		else
			weather.lightningTime = 0
		end
		if weather.lightningNext > 0 then
			weather.lightningNext = weather.lightningNext - (100 * dt)
		elseif weather.lightningNext <= 0 then
			weather.lightningTime = 200
			weather.lightningNext = _r(100,1000)
		end
	end
end

function drawWeather()
	local rx, ry
	if weather.skyRoll > weather.sky then weather.sky = weather.sky + 5 end
	if weather.skyRoll < weather.sky then weather.sky = weather.sky - 5 end

	if weather.sky > 0 or weather.fog > 0 then
		if weather.sky > 0 then
			gr.setColor(0,0,0,weather.sky)
			gr.rectangle("fill", 0, 0, screenW, screenH)
			gr.setColorMode("replace")
		end
		if weather.fog > 0 then
			gr.setColor(255,255,255,weather.fogRoll)
			gr.rectangle("fill", 0, 0, screenW, screenH)
		end
	end

	if weather.rainRoll > weather.rain then weather.rain = weather.rain + .1 end
	if weather.rainRoll < weather.rain then weather.rain = weather.rain - .1 end

	if weather.rain > 0 and weather.sky == weather.skyRoll then
		for r=1,_f(weather.rain) do
			rx = _r(0,screenW/32)
			ry = _r(0,screenH/32)
			gr.draw(rain, rx*32+16, ry*32+16, 0)
		end
	end

	if weather.lightning == true and weather.lightningTime > 0 then
		gr.setColor(255,255,255,weather.lightningTime)
		gr.rectangle("fill", 0, 0, screenW, screenH)
	end
end

function loadMap(m)
	print("Load Map "..m)
	local oldName = mapName
	mapUpdate = function() end
	mapDraw = function() end
	mapUnload = function() end
	mapLoaded = false
	scriptPaused = true
	local mFile = "game/maps/data/" .. tostring(m) .. ".map"
	if love.filesystem.exists(mFile) then
		local i = 0
		local mD = {}
		for line in love.filesystem.lines(mFile) do
			mD[i] = line
			i = i + 1
		end

		mapHeight = i * 32
		mapWidth = _f((tonumber(string.len(mD[1]))+1) / 13) * 32

		for x=0,mapWidth/32-1 do
			for y=0,mapHeight/32-1 do
				mapTiles[x][y] = string.sub(mD[y], (x * 13) + 1, (x * 13) + 4)
				mapDeco1[x][y] = string.sub(mD[y], (x * 13) + 5, (x * 13) + 8)
				mapDeco2[x][y] = string.sub(mD[y], (x * 13) + 9, (x * 13) + 12)
				mapHit[x][y] = string.sub(mD[y], (x * 13) + 13, (x * 13) + 13)
			end
		end

		changeMap = false
		fade.to = 0
	else
		error("Oops! It seems you are missing a certain map file.\nThe map \"" .. mFile .. "\" seems to be missing from its home.\nOr maybe your character has wandered into uncharted territory.")
	end

	--Reset the object tables to clear them from the new map
	dropped = {}
	projectile = {}
	explosion = {}
	hotzone = {}
	enemy = {}
	scenery = {}
	pushables = {}

	player.targeting = 0
	player.boomerangActive = false

	local mFile = "game/maps/scenery/" .. tostring(m) .. ".lua"
	if love.filesystem.exists(mFile) then love.filesystem.load(mFile)() end

	local mFile = "game/maps/post/" .. tostring(m) .. ".lua"
	if love.filesystem.exists(mFile) then love.filesystem.load(mFile)() end

	updateNPCs()

	if mapName ~= oldName then
		mapNameFadeTo = 200
		mapNameTimer = 2
	end

	scriptPaused = false
	if scriptRunning then script[scriptLine].d = true end
	mapLoaded = true
	collectgarbage("collect")
end

function lockCamera(mode,t,a1,a2)
	camera.scrollFromX = camera.scrollToX
	camera.scrollFromY = camera.scrollToY
	camera.scrollToX = a1
	camera.scrollToY = a2
	camera.movingX = true
	camera.movingY = true
	camera.time = t * 1000
	if camera.scrollFromX > camera.scrollToX then
		camera.speedX = camera.scrollFromX - camera.scrollToX
	elseif camera.scrollFromX < camera.scrollToX then
		camera.speedX = camera.scrollToX - camera.scrollFromX
	else
		camera.speedX = 0
		camera.movingX = false
	end
	if camera.scrollFromY > camera.scrollToY then
		camera.speedY = camera.scrollFromY - camera.scrollToY
	elseif camera.scrollFromY < camera.scrollToY then
		camera.speedY = camera.scrollToY - camera.scrollFromY
	else
		camera.speedY = 0
		camera.movingY = false
	end
	camera.locked = mode
end

function panCamera(dt)
	if camera.locked == 0 and camera.movingX == false and camera.movingY == false then
		camera.x = player.x
		camera.y = player.y
		camera.scrollToX = player.x
		camera.scrollToY = player.y
		camera.scrollFromX = player.x
		camera.scrollFromY = player.y
	else
		if camera.movingX == false and camera.movingY == false then
			camera.x = camera.scrollToX
			camera.y = camera.scrollToY
			if camera.locked == 0 then
				camera.scrollToX = player.x
				camera.scrollToY = player.y
			end
		else
			if camera.scrollFromX < camera.scrollToX then
				camera.x = camera.x + camera.speedX * dt
				if camera.x >= camera.scrollToX then
					camera.x = camera.scrollToX
					camera.movingX = false
				end
			elseif camera.scrollFromX > camera.scrollToX then
				camera.x = camera.x - camera.speedX * dt
				if camera.x <= camera.scrollToX then
					camera.x = camera.scrollToX
					camera.movingX = false
				end
			end

			if camera.scrollFromY < camera.scrollToY then
				camera.y = camera.y + camera.speedY * dt
				if camera.y >= camera.scrollToY then
					camera.y = camera.scrollToY
					camera.movingY = false
				end
			elseif camera.scrollFromY > camera.scrollToY then
				camera.y = camera.y - camera.speedY * dt
				if camera.y <= camera.scrollToY then
					camera.y = camera.scrollToY
					camera.movingY = false
				end
			end
		end
	end
end

function calculateMapBounds(dt)
	--Calculate the bounds of the map to speed up rendering by not looping through offscreen tiles.

	panCamera(dt)
	local fx, fy = _f(camera.x), _f(camera.y)

	if mapWidth / 32 <= _f(screenW / 32) then
		xBounds[0] = 0
		xBounds[1] = (mapWidth / 32)
	else
		xBounds[0] = _f(fx / 32) - (_f(screenW/2/32)+1)
		xBounds[1] = _f(fx / 32) + (_f(screenW/2/32)+2)
		if xBounds[0] < 0 then
			xBounds[0] = 0
			xBounds[1] = _f(screenW / 32) + 2
		end
		if xBounds[1] > mapWidth/32 then
			xBounds[0] = (mapWidth/32) - (_f(screenW/32) + 2)
			xBounds[1] = (mapWidth/32)
		end
	end

	if mapHeight / 32 <= _f(screenH / 32)+1 then
		yBounds[0] = 0
		yBounds[1] = (mapHeight / 32)
	else
		yBounds[0] = _f(fy / 32) - (_f(screenH/32/2)+1)
		yBounds[1] = _f(fy / 32) + (_f(screenH/32/2)+3)
		if yBounds[0] < 0 then
			yBounds[0] = 0
			yBounds[1] = _f(screenH / 32) + 2
		end
		if yBounds[1] > mapHeight/32 then
			yBounds[0] = (mapHeight/32) - (_f(screenH/32) + 2)
			yBounds[1] = (mapHeight/32)
		end
	end
end

function calculateMapOffset() --Handle map scrolling. Make sure map stays in bounds.
	local x, y
	if camera.locked == 0 and camera.movingX == false and camera.movingY == false then x, y = player.x, player.y else x, y = camera.x, camera.y end
	mapOffsetX = (screenW/2) - (_f(x) + camera.shakeX)
	mapOffsetY = (screenH/2) - (_f(y) + camera.shakeY)
	if mapOffsetX > 0 then mapOffsetX = 0 end
	if mapOffsetY > 0 then mapOffsetY = 0 end
	if mapOffsetX < -(mapWidth - screenW) then mapOffsetX = -(mapWidth - screenW) end
	if mapOffsetY < -(mapHeight - screenH) then mapOffsetY = -(mapHeight - screenH) end
end

function shakeScreen()
	if camera.shaking == true then
		camera.shakeX, camera.shakeY = _r(-1,1) * 4, _r(-1,1) * 2
	else
		if menu.opened == false then
			camera.shakeX, camera.shakeY = 0, 0
		end
	end
end