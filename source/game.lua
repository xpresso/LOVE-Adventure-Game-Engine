--Fonts
function loadFonts()
	--local abc = " abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	--mono = gr.newImageFont("game/images/fonts/mono.png", abc .. ".,!?-+/():;%&`'*#=[]\"")
	--dialogFont = gr.newImageFont("game/images/fonts/dialog.png", abc .. ".,!?-+/():;%&`'*#=[]\"_")
	mono = gr.newFont(love._vera_ttf, 10)
	menuFont = gr.newFont("game/images/fonts/Vollkorn.ttf", 36)
	editorFont = gr.newFont("game/images/fonts/Vollkorn.ttf", 22)
	editorFontMono = gr.newFont("game/images/fonts/Andale Mono.ttf", 14)
	editorFontMono:setLineHeight(1)

	creditFontA = gr.newFont("game/images/fonts/Vollkorn.ttf", 48)
	creditFontB = gr.newFont("game/images/fonts/Vollkorn.ttf", 72)

  statusSmallFont = gr.newFont("game/images/fonts/Vollkorn.ttf", 14)

	dialogFont = gr.newFont("game/images/fonts/Vollkorn.ttf", 28)
	dialogFont:setLineHeight(2)
	statusFont = gr.newFont("game/images/fonts/Vollkorn.ttf", 32)
	floaterFont = gr.newFont("game/images/fonts/AltDefault.ttf", 26)

	--gr.newImageFont("game/images/fonts/numbers.png", " 0123456789.,$KAB")
end

--Images, Characters and Tile Sets
function loadImages()
	menuTitle = gr.newImage("game/images/ui/titles.png")

	imgScenery = gr.newImage("game/images/stage/scenery.png")
	--imgTiles = gr.newImage("game/images/stage/tiles.png")
	projectiles = gr.newImage("game/images/stage/projectile.png")
	explosions = gr.newImage("game/images/stage/puff.png")
	dropItem = gr.newImage("game/images/stage/dropped.png")
	rain = gr.newImage("game/images/stage/rain.png")

	playerImg = gr.newImage("game/images/actors/playerb.png")
	npcs = gr.newImage("game/images/actors/npcs.png")
	enemies = gr.newImage("game/images/actors/enemies.png")
	enemies2 = gr.newImage("game/images/actors/enemies2.png")

	tileGrid = {}
	for x=0,imgScenery:getWidth()/32-1 do
		tileGrid[x] = {}
		for y=0,imgScenery:getHeight()/32-1 do
			tileGrid[x][y] = gr.newQuad(x * 32, y * 32, 32, 32, imgScenery:getWidth(), imgScenery:getHeight())
		end
	end

	playerGrid = {}
	for x=0,3 do
		playerGrid[x] = {}
		for y=0,7 do
  		playerGrid[x][y] = gr.newQuad(x * 32, y * 64, 32, 64, playerImg:getWidth(), playerImg:getHeight())
    end
	end
	actorShadow = gr.newQuad(0, 496, 32, 16, playerImg:getWidth(), playerImg:getHeight())
	weaponYoyo = gr.newQuad(0, 480, 16, 16, playerImg:getWidth(), playerImg:getHeight())
	weaponYoyoString = gr.newQuad(16, 480, 16, 16, playerImg:getWidth(), playerImg:getHeight())

	enemyGrid = {}
	for x=0,enemies:getWidth()/32-1 do
		enemyGrid[x] = {}
		for y=0,enemies:getHeight()/32-1 do
			enemyGrid[x][y] = gr.newQuad(x * 32, y * 32, 32, 32, enemies:getWidth(), enemies:getHeight())
		end
	end

	enemy2Grid = {}
	for x=0,enemies2:getWidth()/32-1 do
		enemy2Grid[x] = gr.newQuad(x * 32, 0, 32, 32, enemies2:getWidth(), enemies2:getHeight())
	end

	npcGrid = {}
	for x=0,npcs:getWidth()/32-1 do
		npcGrid[x] = {}
		for y=0,npcs:getHeight()/48-1 do
			npcGrid[x][y] = gr.newQuad(x * 32, y * 48, 32, 48, npcs:getWidth(), npcs:getHeight())
		end
	end

	imgLogoJasoco = gr.newQuad(0,240,512,110,menuTitle:getWidth(),menuTitle:getHeight())
	imgLogoTitle = gr.newQuad(0,0,512,240,menuTitle:getWidth(),menuTitle:getHeight())
	imgLogoPresents = gr.newQuad(0,350,512,54,menuTitle:getWidth(),menuTitle:getHeight())
	imgLogoBackground = gr.newQuad(0,404,800,500,menuTitle:getWidth(),menuTitle:getHeight())
  imgHealthBack = gr.newQuad(512,96,201,22,menuTitle:getWidth(),menuTitle:getHeight())
  imgHealthHeart = gr.newQuad(512,128,40,40,menuTitle:getWidth(),menuTitle:getHeight())


	projectileGrid = {}
	for x=0,projectiles:getWidth()/32-1 do
		projectileGrid[x] = {}
		for y=0,projectiles:getHeight()/32-1 do
			projectileGrid[x][y] = gr.newQuad(x * 32, y * 32, 32, 32, projectiles:getWidth(), projectiles:getHeight())
		end
	end

	explosionGrid = {}
	for x=0,explosions:getWidth()/32-1 do
		explosionGrid[x] = {}
		for y=0,explosions:getHeight()/32-1 do
			explosionGrid[x][y] = gr.newQuad(x * 32, y * 32, 32, 32, explosions:getWidth(), explosions:getHeight())
		end
	end

	itemGrid = {}
	for x=0,dropItem:getWidth() / 32-1 do
	  itemGrid[x] = {}
  	for y=0,dropItem:getHeight() / 32-1 do
  		itemGrid[x][y] = gr.newQuad(x * 32, y * 32, 32, 32, dropItem:getWidth(), dropItem:getHeight())
  	end
	end

	heartGrid = {}
	for x=1,2 do
		heartGrid[x] = gr.newQuad(512 + (x-1) * 32, 64, 32, 32, menuTitle:getWidth(), menuTitle:getHeight())
	end
	for x=1,3 do
		heartGrid[x+2] = gr.newQuad(512 + 32, 64, 32/x, 32, menuTitle:getWidth(), menuTitle:getHeight())
	end

	notifGrid = {}
	for x=1,3 do
		notifGrid[x] = gr.newQuad(512 + (x+4) * 32, 64, 32, 32, menuTitle:getWidth(), menuTitle:getHeight())
	end

	dialogGrid = {}
	for x=0,7 do
		dialogGrid[x] = {}
		for y=0,1 do
			dialogGrid[x][y] = gr.newQuad(512 + x * 32, y * 32, 32, 32, menuTitle:getWidth(), menuTitle:getHeight())
		end
	end
end

function filterImages()
  imgScenery:setFilter("nearest","nearest")
  explosions:setFilter("nearest","nearest")
end

function updateGameTime(dt)
  --if actionPaused == false then gameTime.t = gameTime.t + (dt * 600) end
  gameTime.t = os.time()-(60*60*5)
  gameTime.h = gameTime.t/60/60
  gameTime.m = gameTime.t/60
  gameTime.s = gameTime.t
end

function newGame()
	loadedGame = -1
	setupGame(true)
	menu.blockTo = 0
end

--SETUPGAME
function setupGame(n)
	print("Setup Game")
	resetGameVars()
	buildInventory()
	lockCamera(0, 1, 0, 0)
	gameMode = inGame
	if n == true then
		menu.opened = false
		menu.fadeTo = 0
		menu.page = mpMain
		menu.selection = 1
	else
		menu.opened = true
		menu.slideTo = 250
		menu.slide = screenW
		menu.fadeTo = 255
	end
end

function resetGameVars(testing)
	print("	Reset Game Variables")
	fade.val = 255
	fade.to = 255

	xBounds = {0,0}
	yBounds = {0,0}

	dropped = {}
	dTable = {}
	bounce = {}
	setupItemTable()

	hotzone = {}
	switch = {}
	projectile = {}
	floater = {}
	pBoom = 3
	pBomb = 2
	pArrow = 1
	pRock = 0

	healthNuggets = {}

	onScreenTutorialTime = 0
	onScreenTutorialMsg = ""

	gameTime = { t = (17*60*60), h = 0, m = 0, s = 0 }

	weather = {
		rain = 0, rainRoll = 0,
		clouds = 0, fog = 0, fogRoll = 0,
		sky = 0, skyRoll = 0,
		lightning = false, lightningTime = 0, lightningNext = 0
	}

	loadNPCs()
	loadSwitches()

	camera = {
		locked = 0,
		speed = 0,
		scrollFromX = 0,
		scrollFromY = 0,
		scrollToX = 0,
		scrollToY = 0,
		x = 0,
		y = 0,
		movingX = false,
		movingY = false,
		time = 0,
		speedX = 0,
		speedY = 0,
		shaking = false,
		shakeX = 0,
		shakeY = 0,
	}

	floaterTime = {
	  money = -1,
	  moneyTotal = 0,
	  health = -1,
	  healthTotal = 0
	}

	actorMoveDirection = 0
	actorMoveSteps = 0
	actorIsMoving = -1

	objMoveDirection = 0
	objMoveSteps = 0
	objIsMoving = 0

	boomerangPoints = {}

	gameFlag = {}
	for i=1,1000 do gameFlag[i] = 0 end

	pushables = {}

	changeMap = true
  mapNumber = "courtyard"
	mapOffsetX, mapOffsetY = 0, 0
	mapWidth = 0
	mapHeight = 0
	mapName = ""

	dialog.text = ""
	dialog.cursor = 0
	dialog.opened = false
	dialog.location = 1
	dialog.queryChoice = 1
	dialog.nextToo = false
	queryChoices = nil

	--The Variable to hold the amount of time in seconds you've been playing total
	gameStartTime = time
	gameSessionPrevious = 0

	currentScript = ""
	scriptRunning = false
	scriptLine = 0
	scriptLength = 0
	scriptPaused = false
	scriptCommandRunning = false
	scriptWaiting = false
	scriptWaitTime = 0
	scriptWaitSeconds = 0
	scriptWaitingForCamera = false
	chainScript = ""

	currentMusic = 0
	mapMusic = 0

	tmpName = ""

	player = {
		name = tmpName,
		x = 8.5*32,
		y = 38*32,
		cx = 0,
		cy = 0,
		oldXY = 0,
		attacking = 0,
		attackDone = false,
		facing = 4,
		walking = 0,
		walkframe = 0,
		moving = false,
		yoyo = 0,
		yoyodist = 8,
		yoyopow = 1,
		yoyospeed = 64,
		yyx = 0,
		yyy = 0,
		hasMeleeWeapon = false,
		meleePower = 1,
		targeting = 0,
		targetDist = 0,
		targetAng = 0,
		targetFaceAng = 0,
		money = 0,
		wallet = 9999999999,
		health = 3,
		maxHealth = 8,
		XP = 0,
		level = 0,
		nextLevelAt = 0,
		invincible = 0,
		invincibleTime = .5,
		invAnim = 0,
		weapon = 0,
		keys = 0,
		arrows = 0,
		bombs = 30,
		arrows = 30,
		boomerangActive = false,
		boomX = 0,
		boomY = 0,
		boomTargetX = 0,
		boomTargetY = 0,
		boomDist = 0,
		boomMaxDist = 512,
		boomAngle = 0,
		boomSpeed = 512,
		boomReturn = false,
		boomSpin = 0,
		speed = 192,
		arrowPower = 2,
		boomerangPower = 1,
		hasShield = true,
		rollHP = 0,
		rollSpeed = .1,
		rollMoney = 0,
		pushX = -1,
		pushY = -1,
		pushTime = 0,
		knockTime = 0,
		knockDir = 0,
		idle = 0
	}

	playerLevel = {}
	local m = 1
	for i=0,100 do
	  playerLevel[i] = { XPneeded = _f((i * m) * 3) }
	  m = m * 1.1
	  --print(i, playerLevel[i].XPneeded)
	end

  if testing then
    testMode = true
    mapNumber = testMapName
    player.x = 500
    player.y = 500
  else
    testMode = false
  end

	if loadedGame == 1 then
		if love.filesystem.exists("savefile.lua") then
			love.filesystem.load("savefile.lua")()
			player.rollMoney = player.money
			gameSessionPrevious = gameSession
		end
	end

  checkLevel(-1)
end

function loadNPCs()
	npc = {}
	addNPC(1, "courtyard", 39*32, 38*32, "Kristen", 2, 4, false, "npcs/npc_kristen")
	addNPC(2, "courtyard", 34*32, 41*32, "Zooey", 3, 4, false, "npcs/npc_zooey")
	addNPC(3, "courtyard", 25*32, 37*32, "Guard", 4, 4, false, "npcs/npc_guard")
	addNPC(4, "inn_firstfloor", 6*32, 4*32, "Inn Keeper", 5, 4, false, "npcs/npc_innkeeper")
	addNPC(5, "inn_firstfloor", 17*32, 6*32, "Bar Keeper", 1, 4, false, "npcs/npc_barkeeper")
	addNPC(6, "inn_secondfloor", 18*32, 4*32, "Julie", 6, 4, false, "npcs/npc_julie")
	addNPC(7, "inn_firstfloor", 5*32, 8*32, "Wife", 7, 3, false, "npcs/npc_wife")
	addNPC(8, "inn_firstfloor", 7*32, 8*32, "Husband", 8, 1, false, "npcs/npc_husband")
end

function loadSwitches()
	switch = {}
	addSwitch(1, "courtyard", 24*32, 38*32, 1, "Sign", "Sign", 1, "switches/sign", 0, 32)
	addSwitch(2, "courtyard", 35*32, 35*32, 1, "Sign", "Sign", 1, "switches/sign2", 0, 32)
	addSwitch(3, "shed", 12*32, 6*32, 0, "Chest Opened", "Chest Closed", 1, "switches/chest", 0, 32)
end

function loadEnemyTypes()
	enemyType = {}
	addEnemyType(1, 32, 32, 128, 1, 1, 1, 1, "", false)
end

function addEnemyType(id, w, h, sp, d, hl, wp, spr, scr, smp)
	enemyType[id] = {
		width = w, height = h, speed = sp, damage = d, health = hl,
		weapon = wp, sprite = spr, script = scr, simple = smp
	}
end

function saveGame()
	print("Saved Game")
	local data = ""
	data = data .. "player.name = \"" .. player.name .. "\"\n"
	data = data .. "player.x = " .. player.x .. "\n"
	data = data .. "player.y = " .. player.y .. "\n"
	data = data .. "player.facing = " .. player.facing .. "\n"
	data = data .. "player.wallet = " .. player.wallet .. "\n"
	data = data .. "player.money = " .. player.money .. "\n"
	data = data .. "player.health = " .. player.health .. "\n"
	data = data .. "player.maxHealth = " .. player.maxHealth .. "\n"
	data = data .. "player.arrows = " .. player.arrows .. "\n"
	data = data .. "player.bombs = " .. player.bombs .. "\n"
	data = data .. "player.keys = " .. player.keys .. "\n"
	data = data .. "player.XP = " .. player.XP .. "\n"
	data = data .. "player.hasMeleeWeapon = " .. tostring(player.hasMeleeWeapon) .. "\n"

	data = data .. "gameFlag = {"
	for i=1,1000 do
		data = data .. tostring(gameFlag[i]) .. ","
	end
	data = data .. "}\n"

	for i, p in pairs(npc) do
		data = data .. "npc[" .. i .. "].x = " .. npc[i].x .. "\n"
		data = data .. "npc[" .. i .. "].y = " .. npc[i].y .. "\n"
		data = data .. "npc[" .. i .. "].map = \"" .. npc[i].map .. "\"\n"
		data = data .. "npc[" .. i .. "].facing = " .. npc[i].facing .. "\n"
	end

	for i, p in pairs(switch) do
		data = data .. "switch[" .. i .. "].map = \"" .. switch[i].map .. "\"\n"
		data = data .. "switch[" .. i .. "].x = " .. switch[i].x .. "\n"
		data = data .. "switch[" .. i .. "].y = " .. switch[i].y .. "\n"
		data = data .. "switch[" .. i .. "].state = " .. switch[i].state .. "\n"
	end

	data = data .. "gameSession = " .. gameSession + gameSessionPrevious .. "\n"
	data = data .. "mapNumber = \"" .. mapNumber .. "\"\n\n"

  if testMode == false then
  	love.filesystem.write("savefile.lua", data, all)
  end
end

function loadSceneryLibrary()
	local tw1 = imgScenery:getWidth()
	local th1 = imgScenery:getHeight()
	sceneryLibrary = {}
	sceneryLibrary["Tree Fat"] = { i = imgScenery, q = gr.newQuad(64, 272, 64, 80, tw1, th1), ox = 32, oy = 80, ani = false }
	sceneryLibrary["Tree Fat Apple"] = { i = imgScenery, q = gr.newQuad(128, 272, 64, 80, tw1, th1), ox = 32, oy = 80, ani = false }
	sceneryLibrary["Tree Thin"] = { i = imgScenery, q = gr.newQuad(192, 256, 32, 64, tw1, th1), ox = 16, oy = 64, ani = false }

	sceneryLibrary["Fire"] = { i = explosions, q = {
		gr.newQuad(0, 32, 32, 32, explosions:getWidth(), explosions:getHeight()),
		gr.newQuad(32, 32, 32, 32, explosions:getWidth(), explosions:getHeight())
	}, ox = 16, oy = 32, ani = true, fra = 2, sp = 10 }
	sceneryLibrary["GrandfatherClock"] = { i = imgScenery, q = {
		gr.newQuad(64, 224, 21, 47, tw1, th1),
		gr.newQuad(88, 224, 21, 47, tw1, th1),
		gr.newQuad(64, 224, 21, 47, tw1, th1),
		gr.newQuad(112, 224, 21, 47, tw1, th1)
	}, ox = 0, oy = 47, ani = true, fra = 4, sp = 2 }

	sceneryLibrary["Flower 1"] = { i = imgScenery, q = gr.newQuad(0, 128, 16, 16, tw1, th1), ox = 8, oy = 16, ani = false }
	sceneryLibrary["Flower 2"] = { i = imgScenery, q = gr.newQuad(16, 128, 16, 16, tw1, th1), ox = 8, oy = 16, ani = false }
	sceneryLibrary["Flower 3"] = { i = imgScenery, q = gr.newQuad(0, 128+16, 16, 16, tw1, th1), ox = 8, oy = 16, ani = false }
	sceneryLibrary["Flower 4"] = { i = imgScenery, q = gr.newQuad(16, 128+16, 16, 16, tw1, th1), ox = 8, oy = 16, ani = false }
	sceneryLibrary["Grass 1"] = { i = imgScenery, q = gr.newQuad(32, 128, 16, 16, tw1, th1), ox = 8, oy = 16, ani = false}

	sceneryLibrary["Chimney"] = { i = imgScenery, q = gr.newQuad(352, 512, 32, 64, tw1, th1), ox = 16, oy = 48, ani = false }

	sceneryLibrary["Window"] = { i = imgScenery, q = gr.newQuad(0, 384, 34, 34, tw1, th1), ox = 1, oy = 34, ani = false }
	sceneryLibrary["Window Wide"] = { i = imgScenery, q = gr.newQuad(48, 384, 64, 34, tw1, th1), ox = 1, oy = 34, ani = false }

	sceneryLibrary["Sign Inn"] = { i = imgScenery, q = gr.newQuad(320, 0, 32, 24, tw1, th1), ox = 0, oy = 24, ani = false }
	sceneryLibrary["Sign Bar"] = { i = imgScenery, q = gr.newQuad(320, 24, 32, 24, tw1, th1), ox = 0, oy = 24, ani = false }

	sceneryLibrary["Well"] = { i = imgScenery, q = gr.newQuad(11*32, 2*32, 32, 32, tw1, th1), ox = 0, oy = 32, ani = false }

	sceneryLibrary["Bed"] = { i = imgScenery, q = gr.newQuad(512, 0, 64, 112, tw1, th1), ox = 0, oy = 32, ani = false }
	sceneryLibrary["Bed Cover"] = { i = imgScenery, q = gr.newQuad(512+64, 0, 64, 112, tw1, th1), ox = 0, oy = 96, ani = false }

	sceneryLibrary["Beer"] = { i = imgScenery, q = gr.newQuad(384, 192, 8, 16, tw1, th1), ox = 4, oy = 16, ani = false }

	sceneryLibrary["Table"] = { i = imgScenery, q = gr.newQuad(384, 152, 32, 40, tw1, th1), ox = 16, oy = 34, ani = false }
	sceneryLibrary["Stool"] = { i = imgScenery, q = gr.newQuad(392, 192, 24, 24, tw1, th1), ox = 12, oy = 24, ani = false }

	sceneryLibrary["Counter L"] = { i = imgScenery, q = gr.newQuad(416, 128, 32, 32, tw1, th1), ox = 0, oy = 32, ani = false }
	sceneryLibrary["Counter BL"] = { i = imgScenery, q = gr.newQuad(416, 128+32, 32, 40, tw1, th1), ox = 0, oy = 40, ani = false }
	sceneryLibrary["Counter B"] = { i = imgScenery, q = gr.newQuad(416+32, 128+32, 32, 40, tw1, th1), ox = 0, oy = 40, ani = false }
	sceneryLibrary["Counter BR"] = { i = imgScenery, q = gr.newQuad(416+64, 128+32, 32, 40, tw1, th1), ox = 0, oy = 40, ani = false }
	sceneryLibrary["Counter R"] = { i = imgScenery, q = gr.newQuad(416+64, 128, 32, 32, tw1, th1), ox = 0, oy = 32, ani = false }
	sceneryLibrary["Counter E"] = { i = imgScenery, q = gr.newQuad(384, 128, 32, 24, tw1, th1), ox = 0, oy = 24, ani = false }

	sceneryLibrary["Door Opened 1"] = { i = imgScenery, q = gr.newQuad(0, 456, 40, 56, tw1, th1), ox = 4, oy = 56, ani = false }
	sceneryLibrary["Door Opened 1B"] = { i = imgScenery, q = gr.newQuad(40, 456, 40, 56, tw1, th1), ox = 4, oy = 56, ani = false }
	sceneryLibrary["Door Closed 1"] = { i = imgScenery, q = gr.newQuad(80, 456, 40, 56, tw1, th1), ox = 4, oy = 56, ani = false }

	sceneryLibrary["Sign"] = { i = imgScenery, q = gr.newQuad(256, 32, 32, 32, tw1, th1), ox = 16, oy = 32, ani = false }

	sceneryLibrary["Barrel"] = { i = imgScenery, q = gr.newQuad(128, 408, 32, 40, tw1, th1), ox = 0, oy = 40, ani = false }

	sceneryLibrary["Crate"] = { i = imgScenery, q = gr.newQuad(160, 400-8, 32, 56, tw1, th1), ox = 0, oy = 56, ani = false }

	sceneryLibrary["Bridge Railing Long"] = { i = imgScenery, q = gr.newQuad(9*32, 96, 96, 16, tw1, th1), ox = 0, oy = 16, ani = false }
	sceneryLibrary["Bridge Shadow Long"] = { i = imgScenery, q = gr.newQuad(9*32, 112, 96, 16, tw1, th1), ox = 0, oy = 0, ani = false }

	sceneryLibrary["Chest Opened"] = { i = imgScenery, q = gr.newQuad(416, 64, 32, 32, tw1, th1), ox = 0, oy = 32, ani = false }
	sceneryLibrary["Chest Closed"] = { i = imgScenery, q = gr.newQuad(384, 64, 32, 32, tw1, th1), ox = 0, oy = 32, ani = false }

	sceneryLibrary["Wall Bricks 1"] = { i = imgScenery, q = gr.newQuad(0, 512, 32, 64, tw1, th1), ox = 0, oy = 64, ani = false }
	sceneryLibrary["Wall Bricks 2"] = { i = imgScenery, q = gr.newQuad(0, 512, 64, 64, tw1, th1), ox = 0, oy = 64, ani = false }
	sceneryLibrary["Wall Bricks 3"] = { i = imgScenery, q = gr.newQuad(0, 512, 96, 64, tw1, th1), ox = 0, oy = 64, ani = false }
	sceneryLibrary["Wall Bricks 4"] = { i = imgScenery, q = gr.newQuad(0, 512, 128, 64, tw1, th1), ox = 0, oy = 64, ani = false }
	sceneryLibrary["Wall Bricks L"] = { i = imgScenery, q = gr.newQuad(128, 512, 16, 64, tw1, th1), ox = 0, oy = 64, ani = false }
	sceneryLibrary["Wall Bricks R"] = { i = imgScenery, q = gr.newQuad(128+16, 512, 16, 64, tw1, th1), ox = 0, oy = 64, ani = false }
	sceneryLibrary["Wall Bricks OD"] = { i = imgScenery, q = gr.newQuad(4, 512, 32, 12, tw1, th1), ox = 0, oy = 64, ani = false }

	sceneryLibrary["Wall Siding 1"] = { i = imgScenery, q = gr.newQuad(0, 512+64, 32, 64, tw1, th1), ox = 0, oy = 64, ani = false }
	sceneryLibrary["Wall Siding 2"] = { i = imgScenery, q = gr.newQuad(0, 512+64, 64, 64, tw1, th1), ox = 0, oy = 64, ani = false }
	sceneryLibrary["Wall Siding 3"] = { i = imgScenery, q = gr.newQuad(0, 512+64, 96, 64, tw1, th1), ox = 0, oy = 64, ani = false }
	sceneryLibrary["Wall Siding 4"] = { i = imgScenery, q = gr.newQuad(0, 512+64, 128, 64, tw1, th1), ox = 0, oy = 64, ani = false }
	sceneryLibrary["Wall Siding L"] = { i = imgScenery, q = gr.newQuad(128, 512+64, 16, 64, tw1, th1), ox = 0, oy = 64, ani = false }
	sceneryLibrary["Wall Siding R"] = { i = imgScenery, q = gr.newQuad(128+16, 512+64, 16, 64, tw1, th1), ox = 0, oy = 64, ani = false }
	sceneryLibrary["Wall Siding OD"] = { i = imgScenery, q = gr.newQuad(4, 512+64, 32, 12, tw1, th1), ox = 0, oy = 64, ani = false }

	sceneryLibrary["Wall Beige 1"] = { i = imgScenery, q = gr.newQuad(0, 512+128, 32, 64, tw1, th1), ox = 0, oy = 64, ani = false }
	sceneryLibrary["Wall Beige 2"] = { i = imgScenery, q = gr.newQuad(0, 512+128, 64, 64, tw1, th1), ox = 0, oy = 64, ani = false }
	sceneryLibrary["Wall Beige 3"] = { i = imgScenery, q = gr.newQuad(0, 512+128, 96, 64, tw1, th1), ox = 0, oy = 64, ani = false }
	sceneryLibrary["Wall Beige 4"] = { i = imgScenery, q = gr.newQuad(0, 512+128, 128, 64, tw1, th1), ox = 0, oy = 64, ani = false }
	sceneryLibrary["Wall Beige L"] = { i = imgScenery, q = gr.newQuad(128, 512+128, 16, 64, tw1, th1), ox = 0, oy = 64, ani = false }
	sceneryLibrary["Wall Beige R"] = { i = imgScenery, q = gr.newQuad(128+16, 512+128, 16, 64, tw1, th1), ox = 0, oy = 64, ani = false }
	sceneryLibrary["Wall Beige OD"] = { i = imgScenery, q = gr.newQuad(4, 512+128, 32, 12, tw1, th1), ox = 0, oy = 64, ani = false }

	sceneryLibrary["Roof H5 T"] = { i = imgScenery, q = gr.newQuad(160, 512, 176, 96, tw1, th1), ox = 0, oy = 96, ani = false }
	sceneryLibrary["Roof H5 M"] = { i = imgScenery, q = gr.newQuad(160, 512+96, 176, 32, tw1, th1), ox = 0, oy = 32, ani = false }
	sceneryLibrary["Roof H5 B"] = { i = imgScenery, q = gr.newQuad(160, 512+96+32, 176, 112, tw1, th1), ox = 0, oy = 112, ani = false }

	sceneryLibrary["Roof V4 L"] = { i = imgScenery, q = gr.newQuad(408, 592, 8, 160, tw1, th1), ox = 0, oy = 160, ani = false }
	sceneryLibrary["Roof V4 M"] = { i = imgScenery, q = gr.newQuad(480, 592, 32, 160, tw1, th1), ox = 0, oy = 160, ani = false }
	sceneryLibrary["Roof V4 R"] = { i = imgScenery, q = gr.newQuad(400, 592, 8, 160, tw1, th1), ox = 0, oy = 160, ani = false }

	sceneryLibrary["Roof V4 RA"] = { i = imgScenery, q = gr.newQuad(344, 592, 56, 160, tw1, th1), ox = 0, oy = 160, ani = false }
	sceneryLibrary["Roof V4 LA"] = { i = imgScenery, q = gr.newQuad(416, 592, 56, 160, tw1, th1), ox = 0, oy = 160, ani = false }


	sceneryLibrary["Roof V3 L"] = { i = imgScenery, q = gr.newQuad(464, 464, 8, 128, tw1, th1), ox = 0, oy = 128, ani = false }
	sceneryLibrary["Roof V3 M"] = { i = imgScenery, q = gr.newQuad(472, 464, 32, 128, tw1, th1), ox = 0, oy = 128, ani = false }
	sceneryLibrary["Roof V3 R"] = { i = imgScenery, q = gr.newQuad(472+32, 464, 8, 128, tw1, th1), ox = 0, oy = 128, ani = false }


	sceneryLibrary["Clock Face"] = { i = imgScenery, q = gr.newQuad(224-32, 352, 48, 50, tw1, th1), ox = 24, oy = 24, ani = false }
	sceneryLibrary["Clock Hand Minute"] = { i = imgScenery, q = gr.newQuad(224+64-48, 352, 2, 32, tw1, th1), ox = 1, oy = 4, ani = false }
	sceneryLibrary["Clock Hand Hour"] = { i = imgScenery, q = gr.newQuad(224+64+2-48, 352+8, 2, 24, tw1, th1), ox = 1, oy = 4, ani = false }
	sceneryLibrary["Clock Hand Second"] = { i = imgScenery, q = gr.newQuad(224+64+4-48, 352, 2, 32, tw1, th1), ox = 1, oy = 4, ani = false }

	sceneryLibrary["Clock Hand Minute Tiny"] = { i = imgScenery, q = gr.newQuad(224+64-48, 352, 1, 6, tw1, th1), ox = 0, oy = 0, ani = false }
	sceneryLibrary["Clock Hand Hour Tiny"] = { i = imgScenery, q = gr.newQuad(224+64+2-48, 352+8, 1, 4, tw1, th1), ox = 0, oy = 0, ani = false }

	sceneryLibrary["Cloud 1"] = { i = imgScenery, q = gr.newQuad(0, 896, 672, 128, tw1, th1), ox = 0, oy = 128, ani = false }
	sceneryLibrary["Cloud 2"] = { i = imgScenery, q = gr.newQuad(672, 896, 352, 128, tw1, th1), ox = 0, oy = 128, ani = false }
	sceneryLibrary["Sun"] = { i = imgScenery, q = gr.newQuad(944, 816, 80, 80, tw1, th1), ox = 40, oy = 40, ani = false }


	for i, l in pairs(sceneryLibrary) do
		print("Created Scenery Object: \"" .. i .. "\"")
	end

end

function createScenery(n, i, x, y, w, h, ox, oy, ani)
	local tw1 = i:getWidth()
	local th1 = i:getHeight()
	if ox == nil then ox = w/2 end
	if oy == nil then oy = h end
	sceneryLibrary[n] = { i = i, q = gr.newQuad(x, y, w, h, tw1, th1), ani = ani, w = w, h = h, ox = ox, oy = oy }
end

--LOAD MUSIC AND SOUND EFFECTS
function loadAudio()
	muzac = {}
	muzac["intro"] = love.audio.newSource("game/audio/music/Arcadia.ogg", "stream")
	muzac["overworld_1"] = love.audio.newSource("game/audio/music/Porch Swing Days - faster.ogg", "stream")
	muzac["overworld_2"] = love.audio.newSource("game/audio/music/Porch Swing Days - slower.ogg", "stream")
	muzac["town_1"] = love.audio.newSource("game/audio/music/Thatched Villagers.ogg", "stream")
	muzac["house_1"] = love.audio.newSource("game/audio/music/Cattails.ogg", "stream")
	muzac["danger_1"] = love.audio.newSource("game/audio/music/Baltic Levity.ogg", "stream")

	sfx = {}
	sfx[1] = love.sound.newSoundData("game/audio/sfx/menu_cursor.ogg")
	sfx[2] = love.sound.newSoundData("game/audio/sfx/menu_select.ogg")
	sfx[10] = love.sound.newSoundData("game/audio/sfx/player_sword1.ogg")
	sfx[14] = love.sound.newSoundData("game/audio/sfx/player_push.ogg")
	sfx[15] = love.sound.newSoundData("game/audio/sfx/player_shield_reflect.ogg")
	sfx[17] = love.sound.newSoundData("game/audio/sfx/player_lowhealth.ogg")
	sfx[18] = love.sound.newSoundData("game/audio/sfx/player_hurt.ogg")
	sfx[19] = love.sound.newSoundData("game/audio/sfx/player_die.ogg")
	sfx[50] = love.sound.newSoundData("game/audio/sfx/get_money.ogg")
	sfx[51] = love.sound.newSoundData("game/audio/sfx/get_item.ogg")
	sfx[52] = love.sound.newSoundData("game/audio/sfx/get_health.ogg")
	sfx[53] = love.sound.newSoundData("game/audio/sfx/get_key.ogg")
	sfx[57] = love.sound.newSoundData("game/audio/sfx/get_chest.ogg")
	sfx[59] = love.sound.newSoundData("game/audio/sfx/get_money_fanfare.ogg")
	sfx[80] = love.sound.newSoundData("game/audio/sfx/door_open.ogg")
	sfx[81] = love.sound.newSoundData("game/audio/sfx/door_close.ogg")
	sfx[82] = love.sound.newSoundData("game/audio/sfx/stairs_up.ogg")
	sfx[83] = love.sound.newSoundData("game/audio/sfx/stairs_down.ogg")
	sfx[90] = love.sound.newSoundData("game/audio/sfx/bomb_drop.ogg")
	sfx[91] = love.sound.newSoundData("game/audio/sfx/bomb_blow.ogg")
	sfx[100] = love.sound.newSoundData("game/audio/sfx/enemy_hit.ogg")
	sfx[101] = love.sound.newSoundData("game/audio/sfx/enemy_die.ogg")
	sfx[500] = love.sound.newSoundData("game/audio/sfx/shatter.ogg")
	sfx[501] = love.sound.newSoundData("game/audio/sfx/arrow_shoot.ogg")
	sfx[502] = love.sound.newSoundData("game/audio/sfx/arrow_hit.ogg")
	sfx[700] = love.sound.newSoundData("game/audio/sfx/thunder.ogg")
	sfx[800] = love.sound.newSoundData("game/audio/sfx/rain_outside.ogg")
	sfx[997] = love.sound.newSoundData("game/audio/sfx/text_letter.ogg")
	sfx[998] = love.sound.newSoundData("game/audio/sfx/text_done.ogg")
	sfx[999] = love.sound.newSoundData("game/audio/sfx/exitgame.ogg")
	sfx[1000] = love.sound.newSoundData("game/audio/sfx/Der Kleber Sting.ogg")
	sfx[1001] = love.sound.newSoundData("game/audio/sfx/LTTP_Get_HeartPiece.ogg")
end

function buildInventory()
  inventoryItems = {}
	inventoryItems["health_1"] = { name = "Health Pack 1", type = "use", give = function() addHealth(1) end, description = "Add 1HP to your health."}
	inventoryItems["health_2"] = { name = "Health Pack 2", type = "use", give = function() addHealth(5) end, description = "Add 5HP to your health."}
	inventoryItems["health_3"] = { name = "Health Pack 3", type = "use", give = function() addHealth(10) end, description = "Add 10HP to your health."}

	inventoryItems["defence_1"] = { name = "Defence 1", type = "use", give = function() addDefence(2) end, description = "Add defence."}
	inventoryItems["general_1"] = { name = "General", type = "use", give = function()  end, description = "Description here."}
	inventoryItems["general_2"] = { name = "General", type = "use", give = function()  end, description = "Description here."}
	inventoryItems["general_3"] = { name = "General", type = "use", give = function()  end, description = "Description here."}
	inventoryItems["general_4"] = { name = "General", type = "use", give = function()  end, description = "Description here."}
	inventoryItems["general_5"] = { name = "General", type = "use", give = function()  end, description = "Description here."}
	inventoryItems["general_6"] = { name = "General", type = "use", give = function()  end, description = "Description here."}
	inventoryItems["general_7"] = { name = "General", type = "use", give = function()  end, description = "Description here."}
	inventoryItems["general_8"] = { name = "General", type = "use", give = function()  end, description = "Description here."}
	inventoryItems["general_9"] = { name = "General", type = "use", give = function()  end, description = "Description here."}
	inventoryItems["general_10"] = { name = "General", type = "use", give = function()  end, description = "Description here."}
	inventoryItems["general_11"] = { name = "General", type = "use", give = function()  end, description = "Description here."}
	inventoryItems["general_12"] = { name = "General", type = "use", give = function()  end, description = "Description here."}
	inventoryItems["general_13"] = { name = "General", type = "use", give = function()  end, description = "Description here."}
	inventoryItems["general_14"] = { name = "General", type = "use", give = function()  end, description = "Description here."}
	inventoryItems["general_15"] = { name = "General", type = "use", give = function()  end, description = "Description here."}
	inventoryItems["general_16"] = { name = "General", type = "use", give = function()  end, description = "Description here."}
	inventoryItems["general_17"] = { name = "General", type = "use", give = function()  end, description = "Description here."}
	inventoryItems["general_18"] = { name = "General", type = "use", give = function()  end, description = "Description here."}
	inventoryItems["general_19"] = { name = "General", type = "use", give = function()  end, description = "Description here."}
	inventoryItems["general_20"] = { name = "General", type = "use", give = function()  end, description = "Description here."}

	print("Inventory:")
	for i, v in pairs(inventoryItems) do
	  v.count = _r(1,3)
	  v.equipped = false
		print("Added \"" .. v.name .. "\"")
	end
end

function setupItemTable()
	dTable["exp1"] = {give = function() addExperience(1,true) end, name = "XP", spr = 0}
	dTable["exp5"] = {give = function() addExperience(5,true) end, name = "XP", spr = 0}
	dTable["exp10"] = {give = function() addExperience(10,true) end, name = "XP", spr = 0}
	dTable[1] = {give = function() addMoney(.01,true) end, name = "Money", spr = 1}
	dTable[2] = {give = function() addMoney(.10,true) end, name = "Money", spr = 2}
	dTable[3] = {give = function() addMoney(.25,true) end, name = "Money", spr = 3}
	dTable[4] = {give = function() addHealth(1,true) end, name = "Health", spr = 4}
	dTable[5] = {give = function() addArrows(10,true) end, name = "Arrow", spr = 5}
	dTable[6] = {give = function() addBombs(5,true) end, name = "Bomb", spr = 6}
end

function addExperience(xp, s)
	playSound(51)
  player.XP = player.XP + xp
  checkLevel()
  if s then
    local val = "+" .. xp .. "XP"
    createFloater(player.x, player.y+1, 64, val, {100,100,255})
  end
end

function addMoney(m, s)
  floaterTime.money = 0
	playSound(50)
  player.money = player.money + m
  if player.money > player.wallet then player.money = player.wallet end
  floaterTime.moneyTotal = floaterTime.moneyTotal + m
end

function addHealth(hp, s)
  floaterTime.health = 0
  playSound(52)
  player.health = player.health + hp
  if player.health > player.maxHealth then player.health = player.maxHealth end
  floaterTime.healthTotal = floaterTime.healthTotal + hp
end

function addArrows(a, s)
	playSound(51)
  player.arrows = player.arrows + a
end

function addBombs(b, s)
	playSound(51)
  player.bombs = player.bombs + b
end

function calculateFloaters(dt)
  if floaterTime.health > -1 then
    floaterTime.health = floaterTime.health + dt
  end
  if floaterTime.money > -1 then
    floaterTime.money = floaterTime.money + dt
  end

  if floaterTime.money > .5 then
    local val = "$" .. formatNumber(floaterTime.moneyTotal)
    createFloater(player.x, player.y+1, 72, val, {100,255,100})
    floaterTime.money = -1
    floaterTime.moneyTotal = 0
  end

  if floaterTime.health > .5 then
    local val = "+" .. floaterTime.healthTotal .. "HP"
    createFloater(player.x, player.y+1, 72, val, {100,100,255})
    floaterTime.health = -1
    floaterTime.healthTotal = 0
  end
end