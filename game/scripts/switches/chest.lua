if player.facing == 2 and switch[3].state == 0 then
	playSound(57)
	switch[3].state = 1
	table.insert(script, {c = "WAIT", p1 = .2, p2 = nil, p3 = nil, p4 = nil, d = false})
	table.insert(script, {c = "DIALOG", p1 = 0, p2 = "You found the YOYO!", p3 = nil, p4 = nil, d = false})
	player.hasMeleeWeapon = true
	setTutorMsg("Press SPACE to ATTACK!")
end