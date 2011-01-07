--DOOR TO SHED (LOCATION: MAP 1)
if gameFlag[600] == 1 then
	pushables[3].img = "Door Opened 1"
	table.insert(script, {c = "WARP", p1 = "shed", p2 = 12.5, p3 = 10, p4 = "U", d = false})
else
	table.insert(script, {c = "DIALOG", p1 = 0, p2 = "You need the SHED KEY.", p3 = 1, p4 = nil, d = false})
end