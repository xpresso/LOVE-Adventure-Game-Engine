--INN KEEPER'S SCRIPT
queryChoices = {"Yeah, sure", "No thanks"}
table.insert(script, {c = "CUTSCENE", p1 = "IN", p2 = nil, p3 = nil, p4 = nil, d = false})
table.insert(script, {c = "DIALOG", p1 = 4, p2 = "Welcome!\nWould you like a room for the night?", p3 = nil, p4 = nil, d = false})
chainScript = "npcs/sleep"
