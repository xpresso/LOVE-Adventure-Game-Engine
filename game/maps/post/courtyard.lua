if gameFlag[1] == 0 then															--If the Flag has not been set
	addHotZone(17*32,39*32,32,32,"story/convo")			--Activate the Conversation
end
addHotZone(mapWidth-8,384+64+704,8,96,"warps/to_map2")			--Path to woods

createEnemy(_r(1,5), 30*32, 40*32, "", true)

addPushable(1, 13*32, 38*32, 14, true, "Barrel", "switches/barrel")

addPushable(2, 26*32, 35*32+.01, 80, false, "Door Closed 1", "warps/door_inn_in")
addPushable(3, 8*32, 38*32+.01, 80, false, "Door Closed 1", "warps/door_shed_in")

if gameFlag[600] == 1 then
	table.insert(scenery, { x = 800, y = 320+8, id = "Fire", z = 2,
			sx = 1, sy = 1, ox = 16, oy = 32+8, sp = 10, fra = 1, active = true} )
end

table.insert(scenery, 10000, { x = 656, y = 1190.01, id = "Clock Face", z = 2,
    sx = 1, sy = 1, elev = -160} )
table.insert(scenery, 10001, { x = 656, y = 1190.02, id = "Clock Hand Hour", z = 2,
    sx = .75, sy = .75, r = 0, elev = -160} )
table.insert(scenery, 10002, { x = 656, y = 1190.03, id = "Clock Hand Minute", z = 2,
    sx = .75, sy = .75, r = 0, elev = -160} )

table.insert(scenery, 10100, { x = 656, y = 0, id = "Sun", z = 2, sx = 1, sy = 1, elev = 250, s = 2} )

table.insert(scenery, 10101, { x = 700, y = 352, id = "Cloud 2", z = 2, sx = 1, sy = 1, elev = 0, s = 40} )
table.insert(scenery, 10102, { x = 0, y = 353, id = "Cloud 1", z = 2, sx = 1, sy = 1, elev = -1, s = 32} )
table.insert(scenery, 10103, { x = 900, y = 352, id = "Cloud 2", z = 2, sx = 1, sy = 1, elev = 0, s = 24} )

if gameFlag[97] ~= 1 then
  currentScript = "story/intro"
else
  mapName = "Forest Inn Courtyard"
end

weather.sky = 0
weather.skyRoll = 0

tempText={ to=0, val=0, t = "", f = creditFontA }

mapUpdate = function()
  local dt = love.timer.getDelta()
	scenery[10001].r = math.rad(((gameTime.h*(360/12))+180))
	scenery[10002].r = math.rad(((gameTime.m*(360/60))+180))

	if camera.y < 1000 then
    scenery[10100].y = scenery[10100].y - scenery[10100].s * dt

    scenery[10101].x = scenery[10101].x - scenery[10101].s * dt
    scenery[10102].x = scenery[10102].x - scenery[10102].s * dt
    scenery[10103].x = scenery[10103].x - scenery[10103].s * dt
	end
end

mapDraw = function()
  if gameFlag[97] ~= 1 then
    local dt = love.timer.getDelta()
    if tempText.val < tempText.to then
      tempText.val = tempText.val + 500 * dt
      if tempText.val > tempText.to then tempText.val = tempText.to end
    elseif tempText.val > tempText.to then
      tempText.val = tempText.val - 500 * dt
      if tempText.val < tempText.to then tempText.val = tempText.to end
    end

    if _f(gameSession) == 3 then
      tempText.to = 255
      tempText.t = "Jasoco Presents"
      tempText.f = creditFontB
    end
    if _f(gameSession) == 7 then tempText.to = 0 end

    if _f(gameSession) == 8 then
      tempText.to = 255
      tempText.t = "A Game Many Years\nIn the Making"
      tempText.f = creditFontA
    end
    if _f(gameSession) == 12 then tempText.to = 0 end

    if _f(gameSession) == 13 then
      tempText.to = 255
      tempText.t = "Thousands of Man Hours"
      tempText.f = creditFontA
    end
    if _f(gameSession) == 17 then tempText.to = 0 end

    if _f(gameSession) == 18 then
      tempText.to = 255
      tempText.t = "Many Lines of Code"
      tempText.f = creditFontA
    end
    if _f(gameSession) == 22 then tempText.to = 0 end

    if _f(gameSession) == 23 then
      tempText.to = 255
      tempText.t = "Adventure Game!"
      tempText.f = creditFontB
    end
    if _f(gameSession) == 30 then tempText.to = 0 end

    if tempText.val > 0 then
      gr.setBlendMode("alpha")
      gr.setColorMode("modulate")
      gr.setFont(tempText.f)
      gr.setColor(0,0,0,tempText.val/2)
      gr.printf(tempText.t, 1, 212, screenW, "center")
      gr.setColor(255,255,255,tempText.val)
      gr.printf(tempText.t, 0, 210, screenW, "center")
    end
  end
end

mapUnload = function()
  tempText = nil
	print(">>This is a sample Map Unload callback.\n>>It is called when you leave the map,\n>>i.e. when the next map is loaded.")
end

changeMusic = "town_1"
