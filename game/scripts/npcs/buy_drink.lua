--BUY A DRINK
if dialog.queryChoice == 1 then
	if player.money < 5 then
		table.insert(script, {c = "DIALOG", p1 = 5, p2 = "I'm sorry, you don't have enough money.", p3 = nil, p4 = nil, d = false})
	else
		player.money = player.money - 5
		table.insert(script, {c = "DIALOG", p1 = 5, p2 = "Here you go!", p3 = nil, p4 = nil, d = false})
	end
else
	table.insert(script, {c = "DIALOG", p1 = 5, p2 = "Maybe next time then.", p3 = nil, p4 = nil, d = false})
end
table.insert(script, {c = "CUTSCENE", p1 = "OUT", p2 = nil, p3 = nil, p4 = nil, d = false})
