--GUARD'S SCRIPT
gameFlag[2] = gameFlag[2] + 1
if gameFlag[2] < 3 then
	table.insert(script, {c = "DIALOG", p1 = 3, p2 = "Go away.", p3 = nil, p4 = nil, d = false})
elseif gameFlag[2] == 3 then
	table.insert(script, {c = "DIALOG", p1 = 3, p2 = "I said go away!", p3 = nil, p4 = nil, d = false})
elseif gameFlag[2] == 4 then
	table.insert(script, {c = "DIALOG", p1 = 3, p2 = "Can't you see I'm busy standing around\nguarding this house for no reason?", p3 = nil, p4 = nil, d = false})
elseif gameFlag[2] == 18 then
	table.insert(script, {c = "QUAKEBEGIN", p1 = nil, p2 = nil, p3 = nil, p4 = nil, d = false})
	table.insert(script, {c = "DIALOG", p1 = 3, p2 = "CAN YOU NOT TAKE A HINT?!", p3 = nil, p4 = nil, d = false})
	table.insert(script, {c = "DIALOG", p1 = 3, p2 = "I SAID I'M BUSY!!", p3 = nil, p4 = nil, d = false})
	table.insert(script, {c = "QUAKEEND", p1 = nil, p2 = nil, p3 = nil, p4 = nil, d = false})
elseif gameFlag[2] == 20 then
	table.insert(script, {c = "DIALOG", p1 = 3, p2 = "TAKE THIS MONEY AND LEAVE ME ALONE!", p3 = nil, p4 = nil, d = false})
	table.insert(script, {c = "GIVEMONEY", p1 = "1000", p2 = "", p3 = "", p4 = "", d = false})
elseif gameFlag[2] > 4 then
	table.insert(script, {c = "DIALOG", p1 = 3, p2 = "...", p3 = nil, p4 = nil, d = false})
end
table.insert(script, {c = "FACENPC", p1 = 3, p2 = "D", p3 = nil, p4 = nil, d = false})
