--ZOOEY'S (GREEN DRESS GIRL) SCRIPT
if gameFlag[54] ~= 1 then
	table.insert(script, {c = "CUTSCENE", p1 = "IN", p2 = nil, p3 = nil, p4 = nil, d = false})
	table.insert(script, {c = "DIALOG", p1 = 2, p2 = "PLEASE HELP ME!!!", p3 = nil, p4 = nil, d = false})
	table.insert(script, {c = "CUTSCENE", p1 = "OUT", p2 = nil, p3 = nil, p4 = nil, d = false})
elseif gameFlag[601] ~= 1 then
	table.insert(script, {c = "CUTSCENE", p1 = "IN", p2 = nil, p3 = nil, p4 = nil, d = false})
	table.insert(script, {c = "DIALOG", p1 = 2, p2 = "Hi, I'm Zooey. You know, from the film industry.\nI was in the movie Big Trouble.", p3 = nil, p4 = nil, d = false})
	table.insert(script, {c = "DIALOG", p1 = 2, p2 = "My sister Kristen Stewart and I were fighting\nabout something...", p3 = nil, p4 = nil, d = false})
	table.insert(script, {c = "DIALOG", p1 = 2, p2 = "I'd better go apologize.", p3 = nil, p4 = nil, d = false})
	table.insert(script, {c = "MOVENPC", p1 = 2, p2 = "U", p3 = 15, p4 = nil, d = false})
	table.insert(script, {c = "WARPNPC", p1 = 2, p2 = "inn_firstfloor", p3 = 13, p4 = 9, d = false})
	table.insert(script, {c = "FACENPC", p1 = 2, p2 = "L", p3 = nil, p4 = nil, d = false})
	table.insert(script, {c = "SCROLLLOCK", p1 = "PLAYER", p2 = nil, p3 = nil, p4 = 1, d = false})
	table.insert(script, {c = "CUTSCENE", p1 = "OUT", p2 = nil, p3 = nil, p4 = nil, d = false})
	gameFlag[601] = 1
else
	table.insert(script, {c = "FACEPLAYER", p1 = 2, p2 = nil, p3 = nil, p4 = nil, d = false})
	table.insert(script, {c = "DIALOG", p1 = 2, p2 = "Thank you for saving me!", p3 = nil, p4 = nil, d = false})
	table.insert(script, {c = "FACENPC", p1 = 2, p2 = "L", p3 = nil, p4 = nil, d = false})
end