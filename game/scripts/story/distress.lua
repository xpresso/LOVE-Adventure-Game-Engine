--THE CUTSCENE CONVERSATION SCRIPT (RUNS ONLY ONCE)
if gameFlag[54] ~= 1 then --If the conversation has not taken place...
	table.insert(script, {c = "SCROLLLOCK", p1 = "COORDS", p2 = 27*32, p3 = 16*32, p4 = 1, d = false})
	table.insert(script, {c = "CUTSCENE", p1 = "IN", p2 = nil, p3 = nil, p4 = nil, d = false})
	table.insert(script, {c = "SETWEATHER", p1 = 160, p2 = 10, p3 = true, p4 = nil, d = false})
	table.insert(script, {c = "MOVENPC", p1 = 2, p2 = "L", p3 = 4, p4 = nil, d = false})
	table.insert(script, {c = "DIALOG", p1 = 2, p2 = "HELLLLLLLLLLP!!!!!", p3 = 1, p4 = nil, d = false})
	table.insert(script, {c = "SCROLLLOCK", p1 = "PLAYER", p2 = nil, p3 = nil, p4 = 1, d = false})
	table.insert(script, {c = "WAIT", p1 = 1, p2 = nil, p3 = nil, p4 = nil, d = false})
	table.insert(script, {c = "CUTSCENE", p1 = "OUT", p2 = nil, p3 = nil, p4 = nil, d = false})

	for i=1,10 do
		local xx, yy = math.random(3,(mapWidth/32)-4) * 32, math.random(10,(mapHeight/32)-3) * 32
		if mapHit[xx/32][yy/32] ~= "." then yy = yy - 32 end
		createEnemy(math.random(1,5), xx, yy, "enemies/e1", true)
	end
end
