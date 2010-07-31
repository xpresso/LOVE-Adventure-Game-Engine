--BAR KEEPER'S SCRIPT
queryChoices = {"Yeah, sure", "No thanks"}
table.insert(script, {c = "CUTSCENE", p1 = "IN", p2 = nil, p3 = nil, p4 = nil, d = false})
table.insert(script, {c = "DIALOG", p1 = 5, p2 = "Hello, I am the bar keeper.\nCan I get you a drink?", p3 = nil, p4 = nil, d = false})
table.insert(script, {c = "WAIT", p1 = .25, p2 = nil, p3 = nil, p4 = nil, d = false})
chainScript = "npcs/buy_drink"
