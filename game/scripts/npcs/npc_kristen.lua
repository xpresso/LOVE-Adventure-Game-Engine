--KRISTEN'S (BLUE DRESS GIRL) SCRIPT
if gameFlag[601] == 0 then
	table.insert(script, {c = "DIALOG", p1 = 1, p2 = "Sorry you had to see that, " .. player.name .. ".\nMy stupid sister is stupid.", p3 = 1, p4 = nil, d = false})
	table.insert(script, {c = "DIALOG", p1 = 1, p2 = "Stupid Zooey Deschanel.\nHow could she just run off?", p3 = 1, p4 = nil, d = false})
	table.insert(script, {c = "DIALOG", p1 = 1, p2 = "Could you save my sister for me? Please?\nI fear she might be in trouble!", p3 = 1, p4 = nil, d = false})
else
	table.insert(script, {c = "DIALOG", p1 = 1, p2 = "Thank you for saving my sister for me!", p3 = 1, p4 = nil, d = false})
end
table.insert(script, {c = "FACENPC", p1 = 1, p2 = "R", p3 = nil, p4 = nil, d = false})
