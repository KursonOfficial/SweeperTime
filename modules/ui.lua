UI = {}

UI.refreshFonts = function()
	versionFont       = lg.newFont("assets/fonts/ProstoOne-Regular.ttf",GM.Height * 1/72)
	logoFont          = lg.newFont("assets/fonts/ProstoOne-Regular.ttf", GM.Height * 4/45)
	MMButtonsFont     = lg.newFont("assets/fonts/ProstoOne-Regular.ttf", GM.Height * 2/80)
	anyButtonHintFont = lg.newFont(GM.Height * 1/36)
	debugInfoFont     = lg.newFont(GM.Height * 1/60)
end
local versionDisplayText = ""
local MMButtons = {}
local OButtons  = {}
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
	UI.state = "MainMenu"
	UI.refreshFonts()
	isBgEnabled = false
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
				-- TODO: It's really easy to implement an animation for opening
				--       of this menu using coroutines but I'm not doing that now
				--       because it requires a global queue of coroutines and a loop
				--       to drain all of them which is really off-topic.
				UI.state = "Options"	
				-- Don't really know how to do it better
				MMButtons[2].isHover = false
			end,
		},
		count = nil,
	}
	MMButtons.count = #MMButtons
	assert(MMButtons.count >= 1)
	OButtons = {
		{
			text = "Settings",
			isHover = false,
			action = function()
				UI.state = "MainMenu"
			end
		},
		{
			text = "Stats",
			isHover = false,
			action = function()
				UI.state = "MainMenu"
			end
		},
		{
			text = "Credits",
			isHover = false,
			action = function()
				UI.state = "MainMenu"
			end
		},
		{
			text = "Back",
			isHover = false,
			action = function()
				UI.state = "MainMenu"
			end
		},
		count = nil,
	}
	OButtons.count = #OButtons
	assert(OButtons.count >= 1)
end
local buttons_Y = {}
local UIButton = {}
function UI.update()
	local mice = Vector2.new(love.mouse.getPosition())
	GMHUnit = math.ceil(GM.Height/60) -- GM.Height Unit
	if     GM.state == "MainMenu" then
		-- Background
		if isBgEnabled then
			bgShader:send("time", love.timer.getTime())
			bgShader:send("speed", 0.1)
			bgShader:send("size", 3)
		end
		-- Buttons
		local UIButtonPad = GMHUnit
		UIButton = {
			w = logoFont:getWidth("SWEEPER TIME")*3/4,
			h = GMHUnit*3,
		}
		UIButton.x = (GM.Widht-UIButton.w)/2
		local BUTTON_BLOCK_HEIGHT = UIButton.h*MMButtons.count + UIButtonPad*(MMButtons.count-1)
		buttons_Y[1] = GM.Height*((SEGMENTS-NSEGMENT)/SEGMENTS)-BUTTON_BLOCK_HEIGHT/2
		if UI.state == "MainMenu" then
			assert(MMButtons.count >= 1)
			for i = 2, MMButtons.count do
				buttons_Y[i] = buttons_Y[i-1] + UIButton.h + UIButtonPad
			end
			for i = 1, MMButtons.count do
				local thisButton = MMButtons[i]
				local cbuttbbox = Rec.new(UIButton.x, buttons_Y[i], UIButton.w, UIButton.h)
				if checkCollisionPointRec(mice, cbuttbbox) then
					thisButton.isHover = true
				else
					thisButton.isHover = false
				end
			end
		else
			-- options menu update
			assert(OButtons.count >= 1)
			local N = OButtons.count
			buttons_Y[1] = (GM.Height - UIButton.h*N - GMHUnit*(N - 1))/2 
			for i = 2, OButtons.count do
				buttons_Y[i] = buttons_Y[i-1] + UIButton.h + UIButtonPad
			end
		end
	elseif GM.state == "MainGame" then
	end
end

function UI.keypressed(key, scancode, isrepeat)
	if key == "escape" then UI.state = "MainMenu" end
end
function UI.keyreleased(key, scancode)
end
function UI.mousepressed(x, y, button)
end
function UI.mousereleased(x, y, button)
	for i = 1, MMButtons.count do
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
		local screen = Rec.new(0, 0, GM.Widht, GM.Height)
		if isBgEnabled then
			lg.setShader(bgShader)
			lg.setColor(1, 1, 1, 1)
			drawRec("fill", screen)
			lg.setShader()
		end
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
		local button_frame_width = GMHUnit/12
		for i = 1, MMButtons.count do
			assert(buttons_Y[i])
			local butrec = Rec.new(UIButton.x, buttons_Y[i], UIButton.w, UIButton.h)
			if not MMButtons[i].isHover then
				lg.setColor(palette.logoFront.r, palette.logoFront.g, palette.logoFront.b, 0x20/0xFF)
			else
				lg.setColor(palette.logoFront.r, palette.logoFront.g, palette.logoFront.b, 0x40/0xFF)
			end
			drawRec("fill", butrec)
			love.graphics.setLineWidth(button_frame_width)
			lg.setColor(palette.logoFront.r, palette.logoFront.g, palette.logoFront.b, 1)
			drawRec("line", butrec)
			lg.setFont(MMButtonsFont)
			lg.printf(MMButtons[i].text,
				butrec.x,
				butrec.y + (butrec.h - MMButtonsFont:getHeight())/2,
				butrec.w, "center")
		end
		if  UI.state == "Options" then
			local setucol = function(color) lg.setColor(cup(color)) end -- Set unpacked Color
			local set_col_opacity = function(color, opacity) return {r = color.r, g = color.g, b = color.b, a = opacity} end
			local bg = set_col_opacity(palette.cellInner, 0.8)
			local fg = set_col_opacity(palette.cellFrame, 1)
			local fade = {r = 0, g = 0, b = 0, a = 0.5}
			local button_pad = GMHUnit
			local menu_margin = GMHUnit/3
			local N = OButtons.count
			local menu_height = UIButton.h*N + button_pad*(N - 1)
			local menu_rec = Rec.new(
				(screen.w - UIButton.w)/2  - menu_margin,
				(screen.h - menu_height)/2 - menu_margin,
				UIButton.w                 + menu_margin*2,
				menu_height                + menu_margin*2)
			setucol(fade)
			drawRec("fill", screen)
			setucol(bg)
			drawRec("fill", menu_rec)
			setucol(fg)
			love.graphics.setLineWidth(button_frame_width)
			drawRec("line", menu_rec)

			for i = 1, OButtons.count do
				assert(buttons_Y[i])
				local butrec = Rec.new(UIButton.x, buttons_Y[i], UIButton.w, UIButton.h)
				if not OButtons[i].isHover then
					lg.setColor(palette.logoFront.r, palette.logoFront.g, palette.logoFront.b, 0x20/0xFF)
				else
					lg.setColor(palette.logoFront.r, palette.logoFront.g, palette.logoFront.b, 0x40/0xFF)
				end
				drawRec("fill", butrec)
				love.graphics.setLineWidth(button_frame_width)
				lg.setColor(palette.logoFront.r, palette.logoFront.g, palette.logoFront.b, 1)
				drawRec("line", butrec)
				lg.setFont(MMButtonsFont)
				lg.printf(OButtons[i].text,
					butrec.x,
					butrec.y + (butrec.h - MMButtonsFont:getHeight())/2,
					butrec.w, "center")
			end

		end
	elseif GM.state == "MainGame" then
		lg.setFont(debugInfoFont)
		lg.setColor(cup(palette.debugInfo))
		lg.printf(
			string.format("FPS: %d", round(1/love.timer.getDelta())),
			0, 0, GM.Widht, "right")
	end
end
