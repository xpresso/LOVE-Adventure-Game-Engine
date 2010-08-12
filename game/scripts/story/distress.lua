--THE CUTSCENE CONVERSATION SCRIPT (RUNS ONLY ONCE)
if gameFlag[54] ~= 1 then --If the conversation has not taken place...
  playSound(1000)
  table.insert(script, {c = "SETMUSIC", p1 = "danger_1"})
  table.insert(script, {c = "WAIT", p1 = .5})
	table.insert(script, {c = "CUTSCENE", p1 = "IN", d = false})
	table.insert(script, {c = "SCROLLLOCK", p1 = "COORDS", p2 = npc[2].x, p3 = npc[2].y, p4 = 1024, d = false})
	table.insert(script, {c = "MOVENPC", p1 = 2, p2 = "L", p3 = 4, d = false})
	table.insert(script, {c = "DIALOG", p1 = 2, p2 = "HELLLLLLLLLLP!!!!!", p3 = 1, p4 = nil, d = false})
--	table.insert(script, {c = "SETWEATHER", p1 = 160, p2 = 10, p3 = true, p4 = nil, d = false})
	table.insert(script, {c = "SCROLLLOCK", p1 = "PLAYER", p4 = 1024, d = false})
	table.insert(script, {c = "WAITFORCAMERA", d = false})
	table.insert(script, {c = "CUTSCENE", p1 = "OUT", d = false})

	for i=1,10 do
		local xx, yy = math.random(3,(mapWidth/32)-4) * 32, math.random(10,(mapHeight/32)-3) * 32
		if mapHit[xx/32][yy/32] ~= "." then yy = yy - 32 end
		createEnemy(math.random(1,5), xx, yy, "enemies/e1", true)
	end
end
