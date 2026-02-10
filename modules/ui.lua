UI = {}

UI.refreshFonts = function()
	versionFont       = lg.newFont(GM.Height * 1/72)
	logoFont          = lg.newFont(GM.Height * 4/45)
	MMButtonsFont     = lg.newFont(GM.Height * 2/80)
	anyButtonHintFont = lg.newFont(GM.Height * 1/36)
	debugInfoFont     = lg.newFont(GM.Height * 1/60)
end
local versionDisplayText = ""
local MMButtons = {}
local BUTTON_AMMOUNT = -1
local GMHUnit = -1
--[[ NOTE:
	SEGMENTS and NSEGMENT are needed to define paddings of
	title and buttons from top and bottom of the screen accordingly.
	SEGMENTS is the ammount of rows for GM.Height division and
	NSEGMENT is the index of row you pick from top or bottom
	(I am aware that this is a wierd solution)
	.                                           - Cadragonit
--]]
local SEGMENTS = 12
local NSEGMENT = 4
function UI.init()
	UI.refreshFonts()
	bgShader = lg.newShader("assets/background.glsl")
	versionDisplayText = string.format("SweeperTime %s", GM.version)
	MMButtons = {
		{
			text = "New Game",
			isHover = false,
			action = function()
				-- Starting game at this point
				Field.init()
				GM.state = "MainGame"
			end,
		},
		{
			text = "Options",
			isHover = false,
			action = function()
				print("[SweeperTime UI]: ERROR: Nope, `Options` button is not yet implemented")
			end,
		},
	}
	BUTTON_AMMOUNT = #MMButtons
	assert(BUTTON_AMMOUNT >= 1)
end
local buttons_Y = {}
local UIButton = {}
function UI.update()
	local mice = Vector2.new(love.mouse.getPosition())
	GMHUnit = math.ceil(GM.Height/60) -- GM.Height Unit
	if     GM.state == "MainMenu" then
		-- Background
		bgShader:send("time", love.timer.getTime())
		bgShader:send("speed", 0.1)
		bgShader:send("size", 3)
		-- Buttons
		local UIButtonPad = GMHUnit
		UIButton = {
			w = logoFont:getWidth("SWEEPER TIME")*3/4,
			h = GMHUnit*3,
		}
		UIButton.x = (GM.Widht-UIButton.w)/2
		local BUTTON_BLOCK_HEIGHT = UIButton.h*BUTTON_AMMOUNT + UIButtonPad*(BUTTON_AMMOUNT-1)
		buttons_Y[1] = GM.Height*((SEGMENTS-NSEGMENT)/SEGMENTS)-BUTTON_BLOCK_HEIGHT/2
		assert(BUTTON_AMMOUNT >= 1)
		for i = 2, BUTTON_AMMOUNT do
			buttons_Y[i] = buttons_Y[i-1] + UIButton.h + UIButtonPad
		end
		for i = 1, BUTTON_AMMOUNT do
			local thisButton = MMButtons[i]
			local cbuttbbox = Rec.new(UIButton.x, buttons_Y[i], UIButton.w, UIButton.h)
			if checkCollisionPointRec(mice, cbuttbbox) then
				thisButton.isHover = true
			else
				thisButton.isHover = false
			end
		end
	elseif GM.state == "MainGame" then
	end
end

function UI.mousepressed(x, y, button)
	for i = 1, BUTTON_AMMOUNT do
		local thisButton = MMButtons[i]
		if button == 1 and thisButton.isHover then
			thisButton.action()
		end
	end
end

function UI.printLogo(x, y, speed, amplitude)
	local time = love.timer.getTime()
	lg.setFont(logoFont)
	lg.setColor(
		0.2 * math.cos((time-2)*speed) - 0.05,
		0.2 * math.cos((time  )*speed) - 0.05,
		0.2 * math.cos((time+2)*speed) - 0.05,
		0.8)
	lg.printf("SWEEPER TIME",
		math.cos(time*speed)*(amplitude+0.2) + x,
		math.sin(time*speed)*amplitude + y,
		GM.Widht, "center",
		0, 1, 1, 0, 0, 0.2 * math.cos(time*speed))
	lg.setColor(cup(palette.logoFront))
	lg.printf("SWEEPER TIME",
		x, y,
		GM.Widht, "center",
		0, 1, 1, 0, 0, 0.2 * math.cos(time*speed))
end

function UI.draw()
	if GM.state == "MainMenu" then
		-- Background
		lg.setShader(bgShader)
		lg.setColor(1, 1, 1, 1)
		lg.rectangle("fill", 0, 0, GM.Widht, GM.Height)
		lg.setShader()
		-- Verson
		local VERSION_TEXT_PADDING = {w = 10, h = 5}
		lg.setFont(versionFont)
		lg.setColor(cup(palette.versionText))
		lg.printf(versionDisplayText,
			VERSION_TEXT_PADDING.w,
			GM.Height - versionFont:getHeight() - VERSION_TEXT_PADDING.h,
			GM.Widht, "left")
		-- Logo (Which is Title)
		local logoPosY =
			(GM.Height - logoFont:getHeight())*(NSEGMENT/SEGMENTS)
		UI.printLogo(0, logoPosY, 2, GMHUnit*3/4)
		-- Buttons
		-- TODO: Add cool effects
		for i = 1, BUTTON_AMMOUNT do
			assert(buttons_Y[i])
			local butrec = Rec.new(UIButton.x, buttons_Y[i], UIButton.w, UIButton.h)
			if not MMButtons[i].isHover then
				lg.setColor(palette.logoFront.r, palette.logoFront.g, palette.logoFront.b, 0x20/0xFF)
			else
				lg.setColor(palette.logoFront.r, palette.logoFront.g, palette.logoFront.b, 0x40/0xFF)
			end
			drawRec("fill", butrec)
			love.graphics.setLineWidth(GMHUnit/12)
			lg.setColor(palette.logoFront.r, palette.logoFront.g, palette.logoFront.b, 1)
			drawRec("line", butrec)
			lg.setFont(MMButtonsFont)
			lg.printf(MMButtons[i].text,
				butrec.x,
				butrec.y + (butrec.h - MMButtonsFont:getHeight())/2,
				butrec.w, "center")
		end
	elseif GM.state == "MainGame" then
		lg.setFont(debugInfoFont)
		lg.setColor(cup(palette.debugInfo))
		lg.printf(
			string.format("FPS: %d", round(1/love.timer.getDelta())),
			0, 0, GM.Widht, "right")
	end
end
