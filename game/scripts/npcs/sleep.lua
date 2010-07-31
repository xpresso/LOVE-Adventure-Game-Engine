--BUY A DRINK
if dialog.queryChoice == 1 then
	if player.money < 5 then
		insertDialog("I'm sorry, you don't have enough money.\nThe price is 5 per night.", 4)
	else
		player.money = player.money - 5
		table.insert(script, {c = "FILLHEALTH", p1 = nil, p2 = nil, p3 = nil, p4 = nil, d = false})
		insertDialog("[Insert cool \"Sleeping at the Inn\" music here!]", 0)
		insertWait(1)
		insertWarp("inn_secondfloor", 14, 3.6, "D")
		fade.to = 255
	end
else
	table.insert(script, {c = "DIALOG", p1 = 4, p2 = "Maybe next time then.", p3 = nil, p4 = nil, d = false})
end
table.insert(script, {c = "CUTSCENE", p1 = "OUT", p2 = nil, p3 = nil, p4 = nil, d = false})
