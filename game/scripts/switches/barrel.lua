if gameFlag[600] == 0 then
	table.insert(script, {c = "PLAYSOUND", p1 = 53, p2 = nil, p3 = nil, p4 = nil, d = false})
	table.insert(script, {c = "DIALOG", p1 = 0, p2 = "You found the KEY to the SHED!", p3 = 1, p4 = nil, d = false})

	spawnExplosion(800-16,320-16)
	table.insert(scenery, { x = 800, y = 320+8, id = "Fire", z = 2, sx = 1, sy = 1, ox = 16, oy = 32+8, sp = 10, fra = 1, active = true} )
	gameFlag[600] = 1
end
