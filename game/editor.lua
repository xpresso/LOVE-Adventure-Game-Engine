function loadEditor()
	editorMakeMapWidth = 25
	editorMakeMapHeight = 16
	editorMode = 0

	editorToolBox = {
		x = 800-120,
		y = 10,
		w = 110,
		h = 300,
		cxo = 0,
		cyo = 0
	}

	editorGrid = true
	editorMouseTouch = 0

	editorLibraryList = {}
	for i,s in pairs(sceneryLibrary) do
		editorLibraryList[#editorLibraryList+1] = i
	end
	editorLibraryListSelection = 1
	editorLibraryListScroll = 1
	editorLibraryListHeight = 16
	editorLibraryListTextHeight = 28
	editorCurrentScenery = "Tree Fat"
	editorCurrentElev = 0
	editorBGColorSelection = 1
	editorSubMode = 0
	editorHoverScenery = -1
	mapBGColor = { 0, 0, 0 }

	editorHitTileType = "x"

	table.sort(editorLibraryList, function(a, b) return a < b end )

	local _ = love.filesystem.mkdir("game/maps/data")
	local _ = love.filesystem.mkdir("game/maps/scenery")

	editorMapList = {}
	local files = love.filesystem.enumerate("game/maps/data/")
	for i, f in pairs(files) do
		if string.match(f:upper(), ".MAP") and f ~= "undo.map" then
			editorMapList[#editorMapList+1] = string.sub(f,0,string.len(f)-4)
		end
	end
	editorMapList[#editorMapList+1] = "Create New"
	editorMapListSelection = 1
	editorMapSetupSelection = 1

	tmpMapName = ""

	scenery = {}
	editorSnap = false
end

function editorUpdate(dt)
	local kShift = kb.isDown("lshift")
	local kLeft = kb.isDown("left")
	local kRight = kb.isDown("right")
	local kUp = kb.isDown("up")
	local kDown = kb.isDown("down")
	editorSnap = kb.isDown("capslock")

	if editorMode == 0 then

	elseif editorMode == 2 then

	elseif editorMode == 1 then
		sprites = {}

		if editorModeScreen == 1 then
			mx = _f(love.mouse.getX() + editorScrollX)
			my = _f(love.mouse.getY() + editorScrollY)
			if editorSnap and editorSubMode == 0 then
				mx = _f((mx+4)/8)*8
				my = _f((my+4)/8)*8
			end
		elseif editorModeScreen == 2 then
			mx = love.mouse.getX()
			my = love.mouse.getY()
		end

		editorMouseTileX = _f(mx / 32)
		editorMouseTileY = _f(my / 32)

		if editorMouseTileX < 0 then editorMouseTileX = 0 end
		if editorMouseTileY < 0 then editorMouseTileY = 0 end
		if editorMouseTileX > editorTilesX then editorMouseTileX = editorTilesX end
		if editorMouseTileY > editorTilesY then editorMouseTileY = editorTilesY end

		local ms = 512*dt
		if love.mouse.isDown("r") then ms = 512*dt end
		local rmd = love.mouse.isDown("r")

		if editorModeScreen == 1 then
		  if editorSubMode == 1 then
		    local found = -1
        for i, s in pairs(scenery) do
          local x, y, w, h = sceneryLibrary[s.id].q:getViewport()
          if mx > s.x-editorScrollX-sceneryLibrary[s.id].ox and mx < s.x-editorScrollX-sceneryLibrary[s.id].ox+w and my > s.y-editorScrollY-sceneryLibrary[s.id].oy and my < s.y-editorScrollY-sceneryLibrary[s.id].oy+h then
            found = i
          end
        end
        if found > -1 then
          print(scenery[found].id .. " ID: " .. found)
        end
        editorHoverScenery = found
		  end
			if kb.isDown("lshift") == false and kb.isDown("lalt") == false and kb.isDown("lctrl") == false then
				if kLeft or (rmd and love.mouse.getX() < 150) then
					editorScrollX = editorScrollX - ms
				elseif kRight or (rmd and love.mouse.getX() > 800-150) then
					editorScrollX = editorScrollX + ms
				end
				if kUp or (rmd and love.mouse.getY() < 150) then
					editorScrollY = editorScrollY - ms
				elseif kDown or (rmd and love.mouse.getY() > 500-150) then
					editorScrollY = editorScrollY + ms
				end
			end

			if editorScrollX < -(screenW/2) then editorScrollX = -(screenW/2) end
			if editorScrollY < -(screenH/2) then editorScrollY = -(screenH/2) end

			if editorMouseTouch == 1 then
				if editorCurrentLayer >= 1 and editorCurrentLayer <= 3 then
					editorPlaceTile()
				elseif editorCurrentLayer == 5 then
					editorPlaceHit()
				end
			elseif editorMouseTouch == 2 then
				editorToolBox.x = love.mouse.getX() - editorToolBox.cxo
				editorToolBox.y = love.mouse.getY() - editorToolBox.cyo
				if editorToolBox.x > 800-editorToolBox.w then editorToolBox.x = 800-editorToolBox.w end
				if editorToolBox.x < 0 then editorToolBox.x = 0 end
				if editorToolBox.y > 500-editorToolBox.h then editorToolBox.y = 500-editorToolBox.h end
				if editorToolBox.y < 0 then editorToolBox.y = 0 end
			elseif editorMouseTouch == 3 then
				if editorMouseReleased == true then
				end
			end



			for _,s in pairs(scenery) do
				local i = #sprites+1
				sprites[i] = s
				sprites[i].n = "Scenery"
				sprites[i].isCursor = false
			end


			if editorCurrentLayer == 4 then
				local i = #sprites+1
				sprites[i] = {}
				sprites[i].ox = sceneryLibrary[editorCurrentScenery].ox
				sprites[i].oy = sceneryLibrary[editorCurrentScenery].oy
				sprites[i].id = editorCurrentScenery
				sprites[i].x = mx
				sprites[i].y = my
				sprites[i].elev = editorCurrentElev
				sprites[i].n = "Scenery"
				sprites[i].isCursor = true
				if sceneryLibrary[editorCurrentScenery].ani then
					sprites[i].fra = 1
					sprites[i].sp = 1
					sprites[i].active = true
				end
			end

			sort(sprites)

			editorCalculateMapOffset()
			editorCalculateMapBounds()
		end
	end
end

function editorDrawTile(tmp, x, y, l)
	if tmp ~= "0000" and tmp ~= nil and editorLayerActive[l] == 1 then
		local xx = tonumber(string.sub(tmp, 1, 2))
		local yy = tonumber(string.sub(tmp, 3, 4))
		gr.drawq(imgScenery, tileGrid[xx][yy], (x*32)-_f(editorScrollX), (y*32)-_f(editorScrollY))
	end
end

function editorDraw(dt)
	if editorMode == 0 then
		gr.setBackgroundColor(255,255,255)
		gr.setBlendMode("alpha")
		gr.setColorMode("modulate")
		gr.setColor(255,255,255)
		gr.drawq(menuTitle, imgLogoBackground, 0, 0)
		gr.setFont(editorFont)
		for i, f in pairs(editorMapList) do
			if i == editorMapListSelection then
				gr.setColor(255,255,255)
			else
				gr.setColor(70,70,70)
			end
			gr.print(f, 200, 50+(26*i))
		end

		gr.setColor(255,255,255)
		gr.print("Press Enter to Edit " .. editorMapList[editorMapListSelection] .. ".", 40, screenH - 50)
	elseif editorMode == 2 then
		gr.setBackgroundColor(255,255,255)
		gr.setBlendMode("alpha")
		gr.setColorMode("modulate")
		gr.setColor(255,255,255,255)
		gr.drawq(menuTitle, imgLogoBackground, 0, 0)
		gr.setFont(editorFont)
		gr.setColor(0,0,0,255)
		gr.print("Create New Map:", 100, 50)
		local cur
		if _f(time*8 % 2) == 1 then
			cur = "_"
		else
			cur = ""
		end
		local setupOptions = {"Width:	" .. editorMakeMapWidth, "Height: " .. editorMakeMapHeight, "Name: " .. tmpMapName .. cur}
		for i, f in pairs(setupOptions) do
			if i == editorMapSetupSelection then
				gr.setColor(255,255,255)
			else
				gr.setColor(70,70,70)
			end
			gr.print(f, 120, 50+(30*i))
		end
	else
		if editorModeScreen == 1 then
			gr.setBackgroundColor(mapBGColor[1], mapBGColor[2], mapBGColor[3])
			local tmp
			for x=xBounds[0],xBounds[1]-1 do
				for y=yBounds[0],yBounds[1]-1 do
					gr.setColor(255,255,255,255)
          if x < 0 then x = 0 end
          if y < 0 then y = 0 end
					editorDrawTile(mapTiles[x][y], x, y, 1)
					editorDrawTile(mapDeco1[x][y], x, y, 2)
				end
			end

			if editorLayerActive[4] == 1 then
				for _,s in pairs(sprites) do
					if s.x > xBounds[0]*32-128 and s.x < xBounds[1]*32+128 and s.y > yBounds[0]*32-128 and s.y < yBounds[1]*32+128 then
						local sl = sceneryLibrary[s.id]
						if s.n == "Scenery" then
							i = sl.i
							q = sl.q

							local x, y = s.x-_f(editorScrollX), s.y-_f(editorScrollY)
							if editorGrid and editorCurrentLayer == 4 then
								if sl.ani then
									x1, y1, w, h = sl.q[1]:getViewport()
								else
									x1, y1, w, h = sl.q:getViewport()
								end
								if s.isCursor == false then
									gr.setColor(255,255,0,40)
									gr.rectangle("fill", x-sl.ox, y-sl.oy+s.elev, w, h-s.elev)
								  if _ == editorHoverScenery then
  									gr.setColor(0,255,255,100)
                  else
  									gr.setColor(255,255,0,100)
  							  end
									gr.rectangle("line", x-sl.ox-.5, y-sl.oy+s.elev-.5, w+2, h+2-s.elev)
								end

								if s.elev ~= 0 then
									gr.setColor(0,0,0,150)
									gr.rectangle("fill", x-.5, y+s.elev-.5, 30, 15)
									gr.setColor(255,255,255)
									gr.print(s.elev, x-.5, y+s.elev-.5+10)
								end
							end

							if s.isCursor == true then
								gr.setColor(255,0,0,100)
								--gr.rectangle("line", x-sl.ox-.5, y-sl.oy-.5, w+2, h+2)
							end

							gr.setColor(255,0,0)
							if sceneryLibrary[s.id].ani == true then
								if s.fra == nil then s.fra = math.random(1, sl.fra) end
								if s.sp == nil then s.sp = 1 end
								if s.active then s.fra = s.fra + dt * s.sp end
								if s.fra >= sl.fra+1 then s.fra = 1 end
								gr.drawq(sl.i, sl.q[_f(s.fra)], x, y, 0, s.sx, s.sy, sl.ox, sl.oy-s.elev)
							else
								gr.drawq(sl.i, sl.q, x, y, 0, s.sx, s.sy, sl.ox, sl.oy-s.elev)
							end
							if editorGrid and editorCurrentLayer == 4 then
								gr.setColor(255,255,255)
								gr.line(x+.5,y+s.elev-.5, x+.5,y-.5)
								gr.line(x-5+.5,y-.5, x+5+.5,y-.5)
							end
							debugSceneryDrawn = debugSceneryDrawn + 1
						else
							gr.setColor(0,0,255)
							gr.rectangle("fill", s.x+editorScrollX, s.y+editorScrollY-32, 32, 32)
							gr.setColor(0,0,0)
							gr.rectangle("line", s.x+editorScrollX, s.y+editorScrollY-32, 32, 32)
						end
					end
				end
			end

			for x=xBounds[0],xBounds[1]-1 do
				for y=yBounds[0],yBounds[1]-1 do
          if x < 0 then x = 0 end
          if y < 0 then y = 0 end
					gr.setColor(255,255,255,255)
					editorDrawTile(mapDeco2[x][y], x, y, 3)

					tmp = mapHit[x][y]
					if tmp ~= "." and editorLayerActive[5] == 1 then
						if tmp == "x" then
							gr.setColor(255,0,0,80)
						elseif tmp == "w" then
							gr.setColor(0,0,255,80)
						end
						gr.rectangle("fill", (x*32)-editorScrollX, (y*32)-editorScrollY, 32, 32)
						gr.setColor(255,255,255,255)
						gr.setFont(editorFont)
						gr.print(tmp, (x*32)-editorScrollX, (y*32)-editorScrollY+10)
					end

					if editorGrid then
					  if (editorCurrentLayer >= 1 and editorCurrentLayer <= 3) and (mapTiles[x][y] ~= "0000" or mapDeco1[x][y] ~= "0000" or mapDeco2[x][y] ~= "0000") then
              if tmp == "x" then
                gr.setColor(255,0,0,100)
              elseif tmp == "w" then
                gr.setColor(0,0,255,100)
              else
                gr.setColor(255,255,255,100)
              end
              gr.rectangle("line", (x*32)-editorScrollX+.5, (y*32)-editorScrollY+.5, 32, 32)
            else
              gr.setColor(255,255,255,150)
              gr.rectangle("line", (x*32)-_f(editorScrollX)-.5, (y*32)-_f(editorScrollY)-.5, 2, 2)
            end
					end
				end
			end


			if editorCurrentLayer == 4 then

			elseif editorCurrentLayer == 5 then
				gr.setColor(255,255,255,200)
				gr.rectangle("fill", editorMouseTileX*32-4-editorScrollX, editorMouseTileY*32-4-editorScrollY, 40, 40)
				tmp = editorHitTileType
				if tmp == "x" then
					gr.setColor(255,0,0,80)
				elseif tmp == "w" then
					gr.setColor(0,0,255,80)
				else
					gr.setColor(255,255,255,80)
				end
				gr.rectangle("fill", editorMouseTileX*32-editorScrollX, editorMouseTileY*32-editorScrollY, 32, 32)
				gr.setColor(255,255,255,255)
			else
				gr.setBlendMode("alpha")
				gr.setColorMode("replace")
				gr.setColor(255,255,255,200)
				gr.rectangle("fill", editorMouseTileX*32-4-editorScrollX, editorMouseTileY*32-4-editorScrollY, 40, 40)
				gr.setColor(255,255,255,255)
				gr.drawq(imgScenery, tileGrid[curTileX][curTileY], editorMouseTileX*32-editorScrollX, editorMouseTileY*32-editorScrollY)
			end


			gr.setColor(255,255,255)
			gr.rectangle("line", -_f(editorScrollX)-.5, -_f(editorScrollY)-.5, mapWidth+2, mapHeight+2)


			--Draw the window
			gr.setColor(255,255,255,100)
			gr.rectangle("fill", editorToolBox.x-2, editorToolBox.y-2, editorToolBox.w+4, editorToolBox.h+4)
			gr.setColor(0,0,0,200)
			gr.rectangle("fill", editorToolBox.x, editorToolBox.y, editorToolBox.w, 140)
			gr.rectangle("fill", editorToolBox.x, editorToolBox.y+142, editorToolBox.w, editorToolBox.h-142)

			local data = ""
			data = data .. love.timer.getFPS() .. " FPS\n\n"
			data = data .. "MOUSE\n  " .. mx .. "," .. my .. "\n (" .. editorMouseTileX .. "," .. editorMouseTileY .. ")\n\n"
			data = data .. "MAP SIZE\n  " .. editorTilesX .. "," .. editorTilesY .. "\n\n"

			gr.setColor(255,255,255,100)
			gr.rectangle("fill", editorToolBox.x, editorToolBox.y + (164 + (editorCurrentLayer-1) * 16), 110, 16)

			data = data .. "LAYERS\n"
			data = data .. " Back    " .. editorOnOff[editorLayerActive[1]+1] .. "\n"
			data = data .. " Deco 1  " .. editorOnOff[editorLayerActive[2]+1] .. "\n"
			data = data .. " Deco 2  " .. editorOnOff[editorLayerActive[3]+1] .. "\n"
			data = data .. " Scenery " .. editorOnOff[editorLayerActive[4]+1] .. "\n"
			data = data .. " Hit     " .. editorOnOff[editorLayerActive[5]+1] .. "\n"

			if editorCurrentLayer == 1 or editorCurrentLayer == 2 or editorCurrentLayer == 3 then
				--Draw the current tile
				data = data .. "\n\n      TILE\n      " .. curTileX .. "," .. curTileY
				gr.setBlendMode("alpha")
				gr.setColorMode("replace")
				gr.setColor(255,255,255,100)
				gr.rectangle("fill", editorToolBox.x+8, editorToolBox.y+editorToolBox.h-44, 36, 36)
				gr.setColor(0,0,0,200)
				gr.rectangle("fill", editorToolBox.x+10, editorToolBox.y+editorToolBox.h-42, 32, 32)
				gr.setColor(255,255,255,255)
				gr.drawq(imgScenery, tileGrid[curTileX][curTileY], editorToolBox.x + 10, editorToolBox.y + editorToolBox.h - 42)
			elseif editorCurrentLayer == 4 then
				data = data .. "\n\n      SCENERY\n"
			elseif editorCurrentLayer == 5 then
				data = data .. "\n      HIT\n      TYPE\n"
				gr.setColor(255,255,255,100)
				gr.rectangle("fill", editorToolBox.x+8, editorToolBox.y+editorToolBox.h-44, 36, 36)
				if editorHitTileType == "x" then
					gr.setColor(255,0,0,255)
					gr.rectangle("fill", editorToolBox.x+10, editorToolBox.y+editorToolBox.h-42, 32, 32)
				elseif editorHitTileType == "w" then
					gr.setColor(0,0,255,255)
					gr.rectangle("fill", editorToolBox.x+10, editorToolBox.y+editorToolBox.h-42, 32, 32)
				else
					gr.setColor(0,0,0,255)
					gr.rectangle("fill", editorToolBox.x+10, editorToolBox.y+editorToolBox.h-42, 32, 32)
				end
			end

			--Draw the Toolbox Text
			gr.setFont(editorFontMono)
			gr.setColor(255,255,255,255)
			gr.print(data, editorToolBox.x+6, editorToolBox.y+18)


			data = ""
			data = data .. "Map Name: " .. editorMapName .. "\n"
			data = data .. "Sub Mode: " .. editorSubMode .. "\n"
			if editorSnap then data = data .. "Snap To Tile" end
			gr.print(data, 20,460)

		elseif editorModeScreen == 2 then
			gr.setBackgroundColor(255,255,255)
			gr.setColor(150,0,100,255)
			gr.rectangle("fill", 0,0,800,500)
			for x=0,25 do
				for y=0,16 do
					gr.setColor(100,0,120,255)
					gr.rectangle("fill", x*32,y*32,16,16)
					gr.rectangle("fill", x*32+16,y*32+16,16,16)
				end
			end
			gr.setColor(255,255,255,255)
			gr.draw(imgScenery, 0, 0)
		elseif editorModeScreen == 3 then
			gr.setBackgroundColor(100,100,100)
			gr.setBlendMode("alpha")
			gr.setColorMode("modulate")
			gr.setColor(255,255,255)
			gr.drawq(menuTitle, imgLogoBackground, 0, 0)

			gr.setFont(editorFont)
			local m = editorLibraryListScroll + editorLibraryListHeight
			if m > #editorLibraryList then
				m = #editorLibraryList
				editorLibraryListScroll = m - editorLibraryListHeight
			end
			for i=editorLibraryListScroll,m do
				if i == editorLibraryListSelection then
					gr.setColor(255,255,255)
				else
					gr.setColor(120,120,120)
				end
				t = editorLibraryList[i]
				gr.print(t, 40, 26+(editorLibraryListTextHeight*(i-editorLibraryListScroll)))
			end

			local x, y, w, h, an
			gr.setColorMode("replace")
			local sl = editorLibraryList[editorLibraryListSelection]
			if sceneryLibrary[sl].ani == true then
				an = "\nIs Animated"
				x, y, w, h = sceneryLibrary[sl].q[1]:getViewport()
				gr.setColor(0,0,0,50)
				gr.rectangle("fill", (_f(screenW*.66)-(w/2+2)*2), (_f(screenH-screenH/3)-(h+2)*2), (w+4)*2, (h+4)*2)
				gr.drawq(sceneryLibrary[sl].i, sceneryLibrary[sl].q[1], _f(screenW*.66), _f(screenH-screenH/3), 0, 2, 2,w/2,h)
			else
				an = ""
				x, y, w, h = sceneryLibrary[sl].q:getViewport()
				gr.setColor(0,0,0,50)
				gr.rectangle("fill", (_f(screenW*.66)-(w/2+2)*2), (_f(screenH-screenH/3)-(h+2)*2), (w+4)*2, (h+4)*2)
				gr.drawq(sceneryLibrary[sl].i, sceneryLibrary[sl].q, _f(screenW*.66), _f(screenH-screenH/3), 0, 2, 2,w/2,h)
			end
			gr.setColor(255,255,255)
			gr.setColorMode("modulate")
			gr.printf("Scenery: " .. sl .. "\nWidth: " .. w .. "	 Height: " .. h .. "\nOffset X: " .. sceneryLibrary[sl].ox .. "	 Y: " .. sceneryLibrary[sl].oy .. an, screenW - 650, 26, 600, "right")

			local scrollBarHeight = (#editorLibraryList - editorLibraryListHeight) * 18
			local scrollBoxHeight = editorLibraryListHeight * 18
			gr.setColor(0,0,0)
			gr.rectangle("fill", 10,editorLibraryListScroll * ((scrollBoxHeight-scrollBarHeight)/(#editorLibraryList - editorLibraryListHeight-1)),20,scrollBarHeight)
		elseif editorModeScreen == 4 then
			gr.setBackgroundColor(100,100,100)
			gr.setFont(editorFont)
			gr.setBlendMode("alpha")
			gr.setColorMode("modulate")
			gr.setColor(255,255,255)
			gr.drawq(menuTitle, imgLogoBackground, 0, 0)
			gr.print("Set Background Color:",20,30)
			gr.print("Up/Down: Select		Left/Right: Change",20,480)

			gr.setColor(mapBGColor[1], mapBGColor[2], mapBGColor[3])
			gr.rectangle("fill", 200, 50, 400, 400)

			local rgb = {"Red: " .. mapBGColor[1], "Green: " .. mapBGColor[2], "Blue: " ..	mapBGColor[3]}

			for i,c in pairs(rgb) do
				if i == editorBGColorSelection then
					gr.setColor(255,255,255)
				else
					gr.setColor(70,70,70)
				end
				gr.print(c, 50, 100+(i*30))
			end
		end
	end
end

function editorPressKey(k)
	if editorMode == 0 then
		--MAP LIST
		if k == "d" then
			debugVar = debugVar + 1
			if debugVar > 2 then debugVar = 0 end
		end --DEBUG CODE

		if k == " " or k == "enter" or k == "return" then
			if editorMapListSelection == #editorMapList then
				editorMode = 2
			else
				editorSetupMap(editorMapList[editorMapListSelection])
			end
		end
		if k == "up" then
			editorMapListSelection = editorMapListSelection - 1
			if editorMapListSelection < 1 then editorMapListSelection = 1 end
		end
		if k == "down" then
			editorMapListSelection = editorMapListSelection + 1
			if editorMapListSelection > #editorMapList then editorMapListSelection = #editorMapList end
		end
	elseif editorMode == 2 then
		--CREATE NEW MAP
		if k == " " or k == "enter" or k == "return" and tmpMapName ~= "" then editorSetupMap(tmpMapName) end
		if k == "up" then
			if editorMapSetupSelection > 1 then editorMapSetupSelection = editorMapSetupSelection - 1 end
		end
		if k == "down" then
			if editorMapSetupSelection < 3 then editorMapSetupSelection = editorMapSetupSelection + 1 end
		end

		if editorMapSetupSelection == 1 then
			if k == "left" then
				if editorMakeMapWidth > 25 then editorMakeMapWidth = editorMakeMapWidth - 1 end
			end
			if k == "right" then
				if editorMakeMapWidth < 250 then editorMakeMapWidth = editorMakeMapWidth + 1 end
			end
		elseif editorMapSetupSelection == 2 then
			if k == "left" then
				if editorMakeMapHeight > 16 then editorMakeMapHeight = editorMakeMapHeight - 1 end
			end
			if k == "right" then
				if editorMakeMapHeight < 250 then editorMakeMapHeight = editorMakeMapHeight + 1 end
			end
		elseif editorMapSetupSelection == 3 then
			if k == " " and tmpMapName == "" then k = "" end

			if k == "backspace" then
				tmpMapName = string.sub(tmpMapName,0,string.len(tmpMapName)-1)
			else
				if string.len(k) == 1 then
					tmpMapName = string.sub(tmpMapName .. k,0,29)
				end
			end
		else

		end
	else
		--MAP EDITOR MODE
		if k == "q" then
			gameMode = inStartup
			logoLoad()
			startupTimer = time
		end

		if k == "m" then
		  if editorSubMode == 0 then editorSubMode = 1 else editorSubMode = 0 end
		end

		if kb.isDown("lshift") then
			if k == "up" then
				editorCurrentElev = editorCurrentElev - 1
			elseif k == "down" then
				editorCurrentElev = editorCurrentElev + 1
			end
		end

		if kb.isDown("lalt") then
			if k == "down" then
				editorTilesY = editorTilesY + 1
				mapWidth, mapHeight = editorTilesX * 32, editorTilesY * 32
			elseif k == "up" then
				editorTilesY = editorTilesY - 1
				mapWidth, mapHeight = editorTilesX * 32, editorTilesY * 32
			end

			if k == "right" then
				editorTilesX = editorTilesX + 1
				mapWidth, mapHeight = editorTilesX * 32, editorTilesY * 32
			elseif k == "left" then
				editorTilesX = editorTilesX - 1
				mapWidth, mapHeight = editorTilesX * 32, editorTilesY * 32
			end
		end

		if kb.isDown("lctrl") then
			if k == "down" then
				for i, s in pairs(scenery) do
					s.y = s.y + 32
				end
				for x=0,mapWidth/32-1 do
					for y=mapHeight/32-1,0,-1 do
						if y == 0 then
							clearTile(x,y)
						else
							shiftTile(x,y,0,-1)
						end
					end
				end
			elseif k == "up" then
				for i, s in pairs(scenery) do
					s.y = s.y - 32
				end
				for x=0,mapWidth/32-1 do
					for y=0,mapHeight/32-1 do
						if y == mapHeight/32-1 then
							clearTile(x,y)
						else
							shiftTile(x,y,0,1)
						end
					end
				end
			end

			if k == "right" then
				for i, s in pairs(scenery) do
					s.x = s.x + 32
				end
				for x=mapWidth/32-1,0,-1 do
					for y=0,mapHeight/32-1 do
						if x == 0 then
							clearTile(x,y)
						else
							shiftTile(x,y,-1,0)
						end
					end
				end
			elseif k == "left" then
				for i, s in pairs(scenery) do
					s.x = s.x - 32
				end
				for x=0,mapWidth/32-1 do
					for y=0,mapHeight/32-1 do
						if y == mapHeight/32-1 then
							clearTile(x,y)
						else
							shiftTile(x,y,1,0)
						end
					end
				end
			end
		end

		if k == "s" then editorSave(editorMapName) end

		if k == "l" then
			if editorModeScreen == 3 then
				editorModeScreen = 1
			else
				editorModeScreen = 3
			end
		end

		if editorModeScreen == 1 then
			if k == "a" then editorToggleLayer() end
			if k == "b" then
				editorModeScreen = 4
			end
			if k == "g" then
				if editorGrid == true then editorGrid = false else editorGrid = true end
			end

			if k == " " or k == "enter" or k == "return" then editorModeScreen = 2 end

			if k == "f" then editorFill(1) end
			if k == "t" then editorTestLevel() end

			if k == "u" then editorLoadMap("undo") end

			if k == "1" then editorSwitchLayer(1) end
			if k == "2" then editorSwitchLayer(2) end
			if k == "3" then editorSwitchLayer(3) end
			if k == "4" then editorSwitchLayer(4) end
			if k == "5" then editorSwitchLayer(5) end
			if k == "6" then editorSwitchLayer(6) end
		elseif editorModeScreen == 2 then
			if k == " " or k == "enter" or k == "return" then editorModeScreen = 1 end
		elseif editorModeScreen == 3 then
			if k == " " or k == "enter" or k == "return" then editorModeScreen = 1 end
			if k == "up" then
				if editorLibraryListSelection > 1 then editorLibraryListSelection = editorLibraryListSelection - 1 end
				if editorLibraryListSelection < editorLibraryListScroll then editorLibraryListScroll = editorLibraryListScroll - 1 end
			end
			if k == "down" then
				if editorLibraryListSelection < #editorLibraryList then editorLibraryListSelection = editorLibraryListSelection + 1 end
				if editorLibraryListSelection > editorLibraryListScroll + editorLibraryListHeight then editorLibraryListScroll = editorLibraryListScroll + 1 end
			end
			if k == "home" then
				editorLibraryListSelection = 1
				editorLibraryListScroll = 1
			end
			if k == "end" then
				editorLibraryListSelection = #editorLibraryList
				editorLibraryListScroll = #editorLibraryList - editorLibraryListHeight
			end
			editorCurrentScenery = editorLibraryList[editorLibraryListSelection]
		elseif editorModeScreen == 4 then
			if k == " " or k == "enter" or k == "return" then editorModeScreen = 1 end
			if k == "up" then
				editorBGColorSelection = editorBGColorSelection - 1
				if editorBGColorSelection < 1 then editorBGColorSelection = 3 end
			end
			if k == "down" then
				editorBGColorSelection = editorBGColorSelection + 1
				if editorBGColorSelection > 3 then editorBGColorSelection = 1 end
			end
			if k == "right" then
				mapBGColor[editorBGColorSelection] = mapBGColor[editorBGColorSelection] + 1
				if mapBGColor[editorBGColorSelection] > 255 then mapBGColor[editorBGColorSelection] = 255 end
			end
			if k == "left" then
				mapBGColor[editorBGColorSelection] = mapBGColor[editorBGColorSelection] - 1
				if mapBGColor[editorBGColorSelection] < 0 then mapBGColor[editorBGColorSelection] = 0 end
			end
		end
	end
end

function clearTile(x,y)
	mapTiles[x][y] = "0000"
	mapDeco1[x][y] = "0000"
	mapDeco2[x][y] = "0000"
	mapHit[x][y] = "."
end

function shiftTile(x,y,xd,yd)
	mapTiles[x][y] = mapTiles[x+xd][y+yd]
	mapDeco1[x][y] = mapDeco1[x+xd][y+yd]
	mapDeco2[x][y] = mapDeco2[x+xd][y+yd]
	mapHit[x][y] = mapHit[x+xd][y+yd]
end

function editorMouseUp(x,y,button)
	editorMouseTouch = 0
	if editorModeScreen == 1 then editorCanUndo = true end
end

function editorMouseDown(x,y,button)
	if x > editorToolBox.x and x < editorToolBox.x + editorToolBox.w and y > editorToolBox.y and y < editorToolBox.y + editorToolBox.h then
		editorToolBox.cxo = x - editorToolBox.x
		editorToolBox.cyo = y - editorToolBox.y
		if editorToolBox.cyo < 159 then
			editorMouseTouch = 2
		else
			editorMouseTouch = 3
		end

		if editorToolBox.cyo >= 164 and editorToolBox.cyo < 164+(16*5) then
			if editorToolBox.cxo < 66 then
				editorCurrentLayer = _f((editorToolBox.cyo - 164) / 16) + 1
				print(editorToolBox.cyo)
			else
				local cl = _f((editorToolBox.cyo - 164) / 16) + 1
				print(cl)
				if editorLayerActive[cl] == 1 then
					editorLayerActive[cl] = 0
				else
					editorLayerActive[cl] = 1
				end
			end
		elseif editorToolBox.cxo > 8 and editorToolBox.cxo < 41 and editorToolBox.cyo > 258 and editorToolBox.cyo < 291 then
			if editorCurrentLayer >= 1 and editorCurrentLayer <= 3 then
				editorModeScreen = 2
			elseif	editorCurrentLayer == 5 then
				if editorHitTileType == "x" then
					editorHitTileType = "w"
				elseif editorHitTileType == "w" then
					editorHitTileType = "."
				else
					editorHitTileType = "x"
				end
			end
		end

	else
		if editorModeScreen == 1 and button == "l" then
			if editorCanUndo then editorSave("undo") end
			if editorCurrentLayer >= 1 and editorCurrentLayer <= 3 then
				editorPlaceTile()
			elseif editorCurrentLayer == 4 then
				if editorMouseReleased == true then editorPlaceScenery() end
			elseif editorCurrentLayer == 5 then
				editorPlaceHit()
			end
			editorMouseTouch = 1
		elseif editorModeScreen == 2 then
			curTileX = editorMouseTileX
			curTileY = editorMouseTileY
			editorMouseTouch = 0
		elseif editorModeScreen == 3 then
			if button == "wu" then
				if editorLibraryListScroll > 1 then editorLibraryListScroll = editorLibraryListScroll - 1 end
			elseif button == "wd" then
				if editorLibraryListScroll < #editorLibraryList - editorLibraryListHeight then editorLibraryListScroll = editorLibraryListScroll + 1 end
			elseif button == "wl" then
				print("Left")
			elseif button == "wr" then
				print("Right")
			else
				local selected = _f((y-5)/editorLibraryListTextHeight)+editorLibraryListScroll
				if selected >= 1 and selected <= #editorLibraryList then
					editorLibraryListSelection = selected
					print("You have selected the " .. editorLibraryList[editorLibraryListSelection])
					editorCurrentScenery = editorLibraryList[editorLibraryListSelection]
				end
			end
			editorMouseTouch = 0
		end
	end
end

function editorFill(editorFillMode)
	editorSave("undo")
	local tile = string.sub("0" .. curTileX, -2) .. string.sub("0" .. curTileY, -2)
	for x=0,250-1 do
		for y=0,250-1 do
			if editorFillMode == 1 then
				if editorCurrentLayer == 1 then
					mapTiles[x][y] = tile
				elseif editorCurrentLayer == 2 then
					mapDeco1[x][y] = tile
				elseif editorCurrentLayer == 3 then
					mapDeco2[x][y] = tile
				end
			else

			end
		end
	end
end

function editorSetupMap(l)
	editorTilesX, editorTilesY = editorMakeMapWidth, editorMakeMapHeight
	mapWidth, mapHeight = editorTilesX * 32, editorTilesY * 32
	mx, my = 0, 0
	editorMouseTileX, editorMouseTileY = 0, 0
	editorScrollX, editorScrollY = 0, 0

	curTileX, curTileY = 0, 0

	mapTiles = {}
	mapDeco1 = {}
	mapDeco2 = {}
	mapHit = {}
	for i=0,250-1 do
		mapTiles[i] = {}
		mapDeco1[i] = {}
		mapDeco2[i] = {}
		mapHit[i] = {}
		for j=0,250-1 do
			mapTiles[i][j] = "0000"
			mapDeco1[i][j] = "0000"
			mapDeco2[i][j] = "0000"
			mapHit[i][j] = "."
		end
	end

	xBounds = {}
	yBounds = {}

	editorOnOff = {"Off"," On"}

	editorLayerActive = {1,1,1,1,0}
	editorCurrentLayer = 1

	editorModeScreen = 1

	maploaded = true
	changeMap = false

	editorMapName = l

	if l then
		editorLoadMap(l)
	end

	editorMouseReleased = true

	editorMode = 1
end

function editorSwitchLayer(l)
	editorCurrentLayer = l
	editorLayerActive[l] = 1
	editorSubMode = 0
end

function editorToggleLayer()
	if editorLayerActive[editorCurrentLayer] == 1 then
		editorLayerActive[editorCurrentLayer] = 0
	else
		editorLayerActive[editorCurrentLayer] = 1
	end
end

function editorSave(m)
	local t1 = ti.getTime()
	local data = ""
	for y=0,editorTilesY-1 do
		for x=0,editorTilesX-1 do
			data = data .. mapTiles[x][y]
			data = data .. mapDeco1[x][y]
			data = data .. mapDeco2[x][y]
			data = data .. mapHit[x][y]
		end
		data = data .. "\n"
	end
	love.filesystem.write("game/maps/data/" .. m .. ".map", data, all)

	data = ""
	for i, s in pairs(scenery) do
		if sceneryLibrary[s.id].ani then
			animStuff = ", sp = " .. s.sp .. ", fra = " .. _f(s.fra) .. ", active = " .. tostring(s.active)
		else
			animStuff = ""
		end
		data = data .. "table.insert(scenery, { id = \"" .. s.id .. "\",  x = ".. s.x ..", y = ".. s.y ..", z = " .. s.z .. ", sx = " .. s.sx .. ", sy = " .. s.sy .. ", elev = " .. s.elev .. animStuff .. "} )\n"
	end
	data = data .. "gr.setBackgroundColor(" .. mapBGColor[1] .. "," .. mapBGColor[2] .. "," .. mapBGColor[3] .. ")"
	love.filesystem.write("game/maps/scenery/" .. m .. ".lua", data, all)
	print("Saved in " .. (ti.getTime()-t1) .. " seconds.")
end

function editorLoadMap(m)
	scenery = {}
	local mFile = "game/maps/data/" .. tostring(m) .. ".map"
	if love.filesystem.exists(mFile) then
		maploaded = false
		local i = 0
		local mD = {}
		for line in love.filesystem.lines(mFile) do
			mD[i] = line
			i = i + 1
		end

		mapHeight = i * 32
		mapWidth = _f((tonumber(string.len(mD[1]))+1) / 13) * 32

		for x=0,mapWidth/32-1 do
			for y=0,mapHeight/32-1 do
				mapTiles[x][y] = string.sub(mD[y], (x * 13) + 1, (x * 13) + 4)
				mapDeco1[x][y] = string.sub(mD[y], (x * 13) + 5, (x * 13) + 8)
				mapDeco2[x][y] = string.sub(mD[y], (x * 13) + 9, (x * 13) + 12)
				mapHit[x][y] = string.sub(mD[y], (x * 13) + 13, (x * 13) + 13)
			end
		end
		maploaded = true
		changeMap = false

		editorTilesX = mapWidth / 32
		editorTilesY = mapHeight / 32
		if m ~= "undo" then editorSave("undo") end

		local mFile = "game/maps/scenery/" .. tostring(m) .. ".lua"
		if love.filesystem.exists(mFile) then love.filesystem.load(mFile)() end
		mapBGColor[1], mapBGColor[2], mapBGColor[3] = gr.getBackgroundColor()
	else --If no file exists...
		maploaded = false
		mapWidth = editorMakeMapWidth * 32
		mapHeight = editorMakeMapHeight * 32

		for x=0,mapWidth/32-1 do
			for y=0,mapHeight/32-1 do
				mapTiles[x][y] = "0000"
				mapDeco1[x][y] = "0000"
				mapDeco2[x][y] = "0000"
				mapHit[x][y] = "."
			end
		end
		maploaded = true
		changeMap = false

		editorTilesX = mapWidth / 32
		editorTilesY = mapHeight / 32
		editorSave("undo")
		mapBGColor[1], mapBGColor[2], mapBGColor[3] = 0, 0, 0
	end
end

function editorPlaceTile()
  local tile
  if editorSubMode == 1 then
    tile = "0000"
  else
  	tile = string.sub("0" .. curTileX, -2) .. string.sub("0" .. curTileY, -2)
  end
  print(tile, curTileX, curTileY)
	if editorCurrentLayer == 1 then
		mapTiles[editorMouseTileX][editorMouseTileY] = tile
	elseif editorCurrentLayer == 2 then
		mapDeco1[editorMouseTileX][editorMouseTileY] = tile
	elseif editorCurrentLayer == 3 then
		mapDeco2[editorMouseTileX][editorMouseTileY] = tile
	end
end

function editorPlaceScenery()
	local s = editorCurrentScenery
	if sceneryLibrary[editorCurrentScenery].ani then
		table.insert(scenery, { x = mx, y = my, id = s, z = 2, sx = 1, sy = 1, elev = editorCurrentElev, fra = 1, sp = sceneryLibrary[s].sp, active = true} )
	else
		table.insert(scenery, { x = mx, y = my, id = s, z = 2, sx = 1, sy = 1, elev = editorCurrentElev} )
	end
	editorCurrentElev = 0
end

function editorPlaceHit()
  if editorSubMode == 1 then
    mapHit[editorMouseTileX][editorMouseTileY] = "."
  else
    mapHit[editorMouseTileX][editorMouseTileY] = editorHitTileType
  end
end

function editorCalculateMapBounds()
	--Calculate the bounds of the map to speed up rendering by not looping through offscreen tiles.
	if mapWidth / 32 <= _f(screenW / 32) then
		xBounds[0] = 0
		xBounds[1] = (mapWidth / 32)
	else
		xBounds[0] = _f(mapOffsetX / 32) - (_f(screenW/32/2)+1)
		xBounds[1] = _f(mapOffsetX / 32) + (_f(screenW/32/2)+3)
		if xBounds[0] < 0 then
			xBounds[0] = 0
			xBounds[1] = _f(screenW / 32) + 2
		end
		if xBounds[1] > mapWidth/32 then
			xBounds[0] = (mapWidth/32) - (_f(screenW/32) + 2)
			xBounds[1] = (mapWidth/32)
		end
	end

	if mapHeight / 32 <= _f(screenH / 32)+1 then
		yBounds[0] = 0
		yBounds[1] = (mapHeight / 32)
	else
		yBounds[0] = _f(mapOffsetY / 32) - (_f(screenH/32/2)+1)
		yBounds[1] = _f(mapOffsetY / 32) + (_f(screenH/32/2)+3)
		if yBounds[0] < 0 then
			yBounds[0] = 0
			yBounds[1] = _f(screenH / 32) + 2
		end
		if yBounds[1] > mapHeight/32 then
			yBounds[0] = (mapHeight/32) - (_f(screenH/32) + 2)
			yBounds[1] = (mapHeight/32)
		end
	end
end

function editorCalculateMapOffset()
	--Handle map scrolling. Make sure map stays in bounds.
	mapOffsetX = (screenW/2)+_f(editorScrollX)
	mapOffsetY = (screenH/2)+_f(editorScrollY)
end

function editorTestLevel()
	local mFile = "game/maps/data/" .. editorMapName .. ".map"
	if love.filesystem.exists(mFile) then
    testMapName = editorMapName
    resetGameVars(true)
    buildInventory()
    menu.opened = false
    menu.fadeTo = 0
    menu.page = mpMain
    menu.selection = 1
    gameMode = inGame
  else
    print("Please save first!")
  end
end
