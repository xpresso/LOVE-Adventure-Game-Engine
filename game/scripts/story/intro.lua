cut.statTo = 0
cut.stat = 0
table.insert(script, {c = "SETMUSIC", p1 = "intro"})
table.insert(script, {c = "MOVECAMERA", p1 = 400, p2 = 0})
table.insert(script, {c = "WAIT", p1 = 4})
table.insert(script, {c = "SCROLLLOCK", p1 = "COORDS", p2 = 256, p3 = 1280, p4 = 32})
table.insert(script, {c = "WAITFORCAMERA"})
table.insert(script, {c = "CHANGEPUSHABLEIMG", p1 = 3, p2 = "Door Opened 1", p3 = 80, p4 = nil, d = false})
table.insert(script, {c = "MOVEPLAYER", p1 = "D", p2 = 2})
table.insert(script, {c = "SCROLLLOCK", p1 = "PLAYER", p4 = 10000})
table.insert(script, {c = "CHANGEPUSHABLEIMG", p1 = 3, p2 = "Door Closed 1", p3 = 80, p4 = nil, d = false})
table.insert(script, {c = "DIALOG", p1 = -1, p2 = "Welcome to the demo.\nThis is a demo. And you are welcome to it.", p3 = 1})
table.insert(script, {c = "SETMUSIC", p1 = "town_1"})
table.insert(script, {c = "SETFLAG", p1 = 97, p2 = 1})
