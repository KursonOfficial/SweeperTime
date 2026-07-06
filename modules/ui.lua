UI = {}

local lg = love.graphics

UI.refreshFonts = function()
	versionFont       = lg.newFont("assets/fonts/ProstoOne-Regular.ttf",GM.height * 1/72)
	logoFont          = lg.newFont("assets/fonts/ProstoOne-Regular.ttf", GM.height * 4/45)
	MMButtonsFont     = lg.newFont("assets/fonts/ProstoOne-Regular.ttf", GM.height * 2/80)
	anyButtonHintFont = lg.newFont(GM.height * 1/36)
	debugInfoFont     = lg.newFont(GM.height * 1/60)
end

local bgShader
local versionDisplayText
local MMButtons -- array
local MMButtons_len -- (just to not recompute it)
local GMHUnit -- integer (unit dependent on GM.height)
local focused_on_options = false
--[[ NOTE:
	SEGMENTS and NSEGMENT are needed to define paddings of
	title and buttons from top and bottom of the screen accordingly.
	SEGMENTS is the ammount of rows for GM.height division and
	NSEGMENT is the index of row you pick from top or bottom
	(I am aware that this is a wierd solution)
	.                                           - Cadragonit
--]]
local SEGMENTS = 12
local NSEGMENT = 4

function UI.init()

	versionDisplayText = string.format("SweeperTime %s", GM.version)

	bgShader = lg.newShader "assets/background.glsl"

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

				print("WARNING: Options are not implemented yet.")
				focused_on_options = true

				-- Don't really know how to do it better
				MMButtons[2].isHover = false
			end,
		},
	}
	MMButtons_len = #MMButtons

	UI.refreshFonts()
end

local UIButton_Ys = {}
local UIButton = { x = nil, w = nil, h = nil }
function UI.update()
	local mice = Vector2.new(love.mouse.getPosition())
	GMHUnit = math.ceil(GM.height/60) -- GM.height Unit
	if     GM.state == "MainMenu" then
		-- Background
		bgShader:send("time", love.timer.getTime())
		bgShader:send("speed", 0.1)
		bgShader:send("size", 3)
		-- Buttons
		local UIButtonPad = GMHUnit
		UIButton.w = logoFont:getWidth("SWEEPER TIME")*3/4
		UIButton.h = GMHUnit*3
		UIButton.x = (GM.width-UIButton.w)/2
		local BUTTON_BLOCK_HEIGHT = UIButton.h*MMButtons_len + UIButtonPad*(MMButtons_len-1)
		UIButton_Ys[1] = GM.height*((SEGMENTS-NSEGMENT)/SEGMENTS)-BUTTON_BLOCK_HEIGHT/2
		assert(MMButtons_len >= 1)
		for i = 2, MMButtons_len do
			UIButton_Ys[i] = UIButton_Ys[i-1] + UIButton.h + UIButtonPad
		end
		if not focused_on_options then
			for i = 1, MMButtons_len do
				local thisButton = MMButtons[i]
				local cbuttbbox = Rec.new(UIButton.x, UIButton_Ys[i], UIButton.w, UIButton.h)
				if checkCollisionPointRec(mice, cbuttbbox) then
					thisButton.isHover = true
				else
					thisButton.isHover = false
				end
			end
		else
			-- options menu update
			-- nothing yet
		end
	elseif GM.state == "MainGame" then
	end
end

function UI.keypressed(key, scancode, isrepeat)
	if key == "escape" then focused_on_options = false end
end
function UI.keyreleased(key, scancode)
end
function UI.mousepressed(x, y, button)
end
function UI.mousereleased(x, y, button)
	for i = 1, MMButtons_len do
		local thisButton = MMButtons[i]
		if button == 1 and thisButton.isHover then
			thisButton.action()
		end
	end
end


function UI.draw()
	if GM.state == "MainMenu" then

		local time = love.timer.getTime()
		local screen = Rec.new(0, 0, GM.width, GM.height)

		-- Background
		lg.setShader(bgShader)
		lg.setColor(1, 1, 1, 1)
		screen:draw("fill")
		lg.setShader()

		-- Verson
		lg.setFont(versionFont)
		palette.versionText:apply()
		lg.printf(versionDisplayText, 10, screen.h - versionFont:getHeight() - 5, screen.w, "left")

		-- Logo (Which is Title)
		do
			local logoY = (screen.h - logoFont:getHeight())*(NSEGMENT/SEGMENTS)
			local logoSpeed = 2
			local logoAmplitude = GMHUnit*3/4

			-- Shadow
			lg.setFont(logoFont)
			lg.setColor(0.2 * math.cos((time-2)*logoSpeed) - 0.05,
			            0.2 * math.cos((time  )*logoSpeed) - 0.05,
			            0.2 * math.cos((time+2)*logoSpeed) - 0.05,
			            0.8)
			lg.printf("SWEEPER TIME",
			          math.cos(time*logoSpeed)*(logoAmplitude+0.2),
			          math.sin(time*logoSpeed)*logoAmplitude + logoY,
			          screen.w, "center",
			          0, 1, 1, 0, 0, 0.2 * math.cos(time*logoSpeed))

			-- Front
			palette.logoFront:apply()
			lg.printf("SWEEPER TIME",
			          0, logoY,
			          screen.w, "center",
			          0, 1, 1, 0, 0, 0.2 * math.cos(time*logoSpeed))
		end

		-- Buttons
		local button_frame_width = GMHUnit/12
		for i = 1, MMButtons_len do
			assert(UIButton_Ys[i])
			local butrec = Rec.new(UIButton.x, UIButton_Ys[i], UIButton.w, UIButton.h)
			if not MMButtons[i].isHover then
				palette.logoFront:where { a = 0x20/0xFF }:apply()
			else
				palette.logoFront:where { a = 0x40/0xFF }:apply()
			end
			butrec:draw("fill")
			love.graphics.setLineWidth(button_frame_width)
			palette.logoFront:where { a = 1 }:apply()
			butrec:draw("line")
			lg.setFont(MMButtonsFont)
			lg.printf(MMButtons[i].text,
				butrec.x,
				butrec.y + (butrec.h - MMButtonsFont:getHeight())/2,
				butrec.w, "center")
		end
		if focused_on_options then
			local bg = palette.cellInner:where { a = 0.8 }
			local fg = palette.cellFrame:where { a = 1 }
			local fade = Color.newNV(0, 0, 0, 0.5)
			local button_pad = GMHUnit
			local menu_margin = GMHUnit/3
			local N = 4
			local menu_height = UIButton.h*N + button_pad*(N - 1)
			local menu_rec = Rec.new(
				(screen.w - UIButton.w)/2  - menu_margin,
				(screen.h - menu_height)/2 - menu_margin,
				UIButton.w                 + menu_margin*2,
				menu_height                + menu_margin*2)
			fade:apply()
			screen:draw("fill")
			bg:apply()
			menu_rec:draw("fill")
			fg:apply()
			love.graphics.setLineWidth(button_frame_width)
			menu_rec:draw("line")
		end
	elseif GM.state == "MainGame" then
		lg.setFont(debugInfoFont)
		palette.debugInfo:apply()
		lg.printf(
			string.format("FPS: %d", round(1/love.timer.getDelta())),
			0, 0, GM.width, "right")
	end
end
