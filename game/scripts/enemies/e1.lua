gameFlag[999] = gameFlag[999] + 1
if gameFlag[999] == 10 then
	gameFlag[54] = 1
	--table.insert(script, {c = "SETWEATHER", p1 = 0, p2 = 0, p3 = false, p4 = nil, d = false})
  table.insert(script, {c = "SETMUSIC", p1 = "overworld_1"})
end
