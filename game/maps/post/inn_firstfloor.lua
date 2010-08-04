changeMusic = 4
mapName = "Forest Inn (First Floor)"

addPushable(1, 5*32, 10*32, 14, true, "Barrel", "")
addPushable(2, 5*32, 11*32, 14, true, "Barrel", "")
addPushable(3, 6*32, 11*32, 14, true, "Barrel", "")
addPushable(4, 7*32, 11*32, 14, true, "Barrel", "")

addPushable(5, 15*32, 11*32, -1, false, "", "warps/door_inn_out")
addPushable(6, 9*32, 2*32, -1, false, "", "warps/stairs_inn_up")

table.insert(scenery, 10001, { x = 463, y = 135.01+35, id = "Clock Hand Hour Tiny", z = 2, sx = 1, sy = 1, r = 0, elev = -35} )
table.insert(scenery, 10002, { x = 463, y = 135.02+35, id = "Clock Hand Minute Tiny", z = 2, sx = 1, sy = 1, r = 0, elev = -35} )


mapUpdate = function()
	scenery[10001].r = math.rad(((gameTime.h*(360/12))+180))
	scenery[10002].r = math.rad(((gameTime.m*(360/60))+180))
	--scenery[10003].r = math.rad(((gameTime.s)+180))
end
