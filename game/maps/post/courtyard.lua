if gameFlag[1] == 0 then															--If the Flag has not been set
	addHotZone(384+52+(32*7),512,32,32,"story/convo")			--Activate the Conversation
end
addHotZone(1304,384,8,96,"warps/to_map2")			--Path to woods

createEnemy(math.random(1,5), 30*32, 20*32, "", true)

addPushable(1, 16*32, 15*32, 14, true, "Barrel", "switches/barrel")

addPushable(2, 26*32, 12*32, 80, false, "Door Closed 1", "warps/door_inn_in")
addPushable(3, 13*32, 15*32, 80, false, "Door Closed 1", "warps/door_shed_in")

if gameFlag[600] == 1 then
	table.insert(scenery, { x = 800, y = 320+8, id = "Fire", z = 2,
													sx = 1, sy = 1, ox = 16, oy = 32+8, sp = 10, fra = 1, active = true} )
end

table.insert(scenery, 10000, { x = 900, y = 600, id = "Clock Face", z = 2, sx = 1, sy = 1, elev = 0} )
table.insert(scenery, 10001, { x = 900, y = 600.01, id = "Clock Hand Hour", z = 2, sx = 1, sy = 1, r = 0, elev = 0} )
table.insert(scenery, 10002, { x = 900, y = 600.02, id = "Clock Hand Minute", z = 2, sx = 1, sy = 1, r = 0, elev = 0} )
table.insert(scenery, 10003, { x = 900, y = 600.03, id = "Clock Hand Second", z = 2, sx = 1, sy = 1, r = 0, elev = 0} )


weather.sky = 0
weather.skyRoll = 0
changeMusic = 3
mapName = "Forest Inn Courtyard"

mapUpdate = function()
	scenery[10001].r = math.rad(((gameTime.h*(360/12))+180))
	scenery[10002].r = math.rad(((gameTime.m*(360/60))+180))
	scenery[10003].r = math.rad(((gameTime.s)+180))
  gr.setFont(dialogFont)
  gr.print(formatTime(gameTime.t), 900+mapOffsetX, 500+mapOffsetY)
end

mapDraw = function()
  gr.setFont(dialogFont)
  gr.print("Me!", player.x+mapOffsetX-16, player.y+mapOffsetY-64)
end

mapUnload = function()
	print(">>This is a sample Map Unload callback.\n>>It is called when you leave the map,\n>>i.e. when the next map is loaded.")
end
