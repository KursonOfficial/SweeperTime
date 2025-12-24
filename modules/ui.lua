UI = {}

UI.refreshFonts = function()
	versionFont       = lg.newFont(GM.Height * 1/72)
	logoFont          = lg.newFont(GM.Height * 4/45)
	mainMenuButtons   = lg.newFont(GM.Height * 2/60)
	anyButtonHintFont = lg.newFont(GM.Height * 1/36)
	debugInfoFont     = lg.newFont(GM.Height * 1/60)
end
local versionDisplayText = ""
function UI.init()
	UI.refreshFonts()
	bgShader = lg.newShader("assets/missing.glsl")
	bgShader:send("time",  0)
	bgShader:send("speed", GM.Height/28)
	bgShader:send("sqare_sz", GM.Height/28)
	bgShader:send("col1", {0, 0, 0, 0.25})
	bgShader:send("col2", {1, 0, 1, 0.25})
	versionDisplayText = string.format("SweeperTime %s", GM.version)
end

function UI.update()
	if     GM.state == "MainMenu" then
		bgShader:send("time", love.timer.getTime()*2)
		bgShader:send("speed", GM.Height/28)
		bgShader:send("sqare_sz", GM.Height/28)
	elseif GM.state == "MainGame" then
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
	local GMHUnit = math.ceil(GM.Height/60) -- GM.Height Unit
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

-- REFACTORING ZONE ---------------------------------------------------------------------
		-- Buttons
		-- TODO:
		--[[
			- [ ] Move calculatons to init and update
			- [ ] Make New Game button actually work
			- [ ] Add cool effects
		--]]
		-- CALCULATONS
		local buttons_as_text = {
			"New Game",
			"Options",
		}
		local BUTTON_AMMOUNT = #buttons_as_text
		assert(BUTTON_AMMOUNT >= 1)
		local UIButtonPad = GMHUnit
		local UIButton = {
			w = logoFont:getWidth("Sweeper Time")*3/4,
			h = GMHUnit*3,
		}
		buttons_as_recs = {}
		local BUTTON_BLOCK_HEIGHT = UIButton.h*BUTTON_AMMOUNT + UIButtonPad*(BUTTON_AMMOUNT-1)
		buttons_as_recs[1] = Rec.new(
			(GM.Widht-UIButton.w)/2,
			GM.Height*((SEGMENTS-NSEGMENT)/SEGMENTS)-BUTTON_BLOCK_HEIGHT/2,
			UIButton.w,
			UIButton.h)
		for i = 2, BUTTON_AMMOUNT do
			buttons_as_recs[i] = Rec.new(
				(GM.Widht-UIButton.w)/2,
				buttons_as_recs[i-1].y + UIButton.h + UIButtonPad,
				UIButton.w,
				UIButton.h)
		end
		-- DRAWING
		for i = 1, #buttons_as_recs do
			butrec = buttons_as_recs[i]
			lg.setColor(palette.logoFront.r, palette.logoFront.g, palette.logoFront.b, 0x20/0xFF)
			drawRec("fill", butrec)
			love.graphics.setLineWidth(GMHUnit/12)
			lg.setColor(palette.logoFront.r, palette.logoFront.g, palette.logoFront.b, 1)
			drawRec("line", butrec)
			lg.setFont(mainMenuButtons)
			lg.printf(buttons_as_text[i],
				butrec.x,
				butrec.y + (butrec.h - mainMenuButtons:getHeight())/2,
				butrec.w, "center")
		end
-- REFACTORING ZONE END -----------------------------------------------------------------

	elseif GM.state == "MainGame" then
		lg.setFont(debugInfoFont)
		lg.setColor(cup(palette.debugInfo))
		lg.printf(
			string.format("FPS: %d", round(1/love.timer.getDelta())),
			0, 0, GM.Widht, "right")
	end
end

