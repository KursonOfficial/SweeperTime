local UI = {}

local lg = love.graphics

local unit

local time = 0
local shaderBG

local fonts = {} -- { string : love.graphics.Font } (see function refreshFonts)

function UI.refreshFonts(screenWidth, screenHeight)
	local unit = math.min(screenWidth, screenHeight)
	fonts["Version"]           = lg.newFont("assets/fonts/ProstoOne-Regular.ttf", unit/72)
	fonts["Title"]             = lg.newFont("assets/fonts/ProstoOne-Regular.ttf", unit*4/45)
	fonts["Main menu buttons"] = lg.newFont("assets/fonts/ProstoOne-Regular.ttf", unit/40)
	fonts["Debug Info"]        = lg.newFont(unit/60)
end

function UI.init(self, GM)

	unit = math.min(GM.width, GM.height)
	shaderBG = lg.newShader "assets/background.glsl"
	shaderBG:send("speed", 0.1)
	shaderBG:send("size", 3)

	self.refreshFonts(GM.width, GM.height)
end

-- Things for buttons @ugly
local UIButton_Ys = {}
local UIButton = { x = nil, w = nil, h = nil }
local focused_on_options = false
local MMButtons = {
	{
		text = "New Game",
		isHover = false,
		action = function(self, GM)
			-- Starting game at this point
			GM.state = "MainGame"
		end,
	},
	{
		text = "Options",
		isHover = false,
		action = function(self, GM)
			-- TODO: It's really easy to implement an animation for opening
			--       of this menu using coroutines but I'm not doing that now
			--       because it requires a global queue of coroutines and a loop
			--       to drain all of them which is really off-topic.

			print("WARNING: Options are not implemented yet.")
			focused_on_options = true

			-- Don't really know how to do it better
			self.isHover = false
		end,
	},
}
local MMButtons_len = #MMButtons
local SEGMENTS = 12
local NSEGMENT = 4

function UI.update(GM, dt)

	time = time + dt
	unit = math.min(GM.width, GM.height)

	if GM.state == "MainMenu" then

		shaderBG:send("time", time)

		-- Buttons @ugly
		do
			local mouse = Vector2.new(love.mouse.getPosition())
			local font = fonts["Title"]
			local UIButtonPad = unit/60
			UIButton.w = unit*9/16
			UIButton.h = unit/20
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
					if checkCollisionPointRec(mouse, cbuttbbox) then
						thisButton.isHover = true
					else
						thisButton.isHover = false
					end
				end
			else
				-- options menu update
				-- nothing yet
			end
		end
	end
end

function UI.draw(GM)

	local screen = Rec.new(0, 0, GM.width, GM.height)

	if GM.state == "MainMenu" then

		-- Background
		lg.setShader(shaderBG)
		screen:draw("fill")
		lg.setShader()
		lg.setColor(0, 0, 0, 0.3)
		screen:draw("fill")

		-- Version
		do
			local font = fonts["Version"]
			local pad_left = 10
			local pad_bottom = 5
			lg.setFont(font)
			palette.versionText:apply()
			lg.printf("SweeperTime "..GM.version, pad_left, screen.h - font:getHeight() - pad_bottom, screen.w, "left")
		end

		-- Title
		do
			local text = "SWEEPER TIME"
			local font = fonts["Title"]
			local x = 0
			local y = screen.h/3 - font:getHeight()/2
			local w = screen.w
			local speed = math.pi*2/3
			local shadowOffset = unit/144

			lg.setFont(font)

			-- Shadow
			Color.newHSV(time*360/6, 1, 0.5, 1):apply()
			lg.printf(text, x + math.cos(time*speed)*shadowOffset, y + math.sin(time*speed)*shadowOffset, w, "center", 0, 1, 1, 0, 0, 0.2 * math.cos(time*speed))

			-- Title
			palette.logoFront:apply()
			lg.printf(text, x, y, w, "center", 0, 1, 1, 0, 0, 0.2 * math.cos(time*speed))
		end

		-- Buttons @ugly
		do
			local font = fonts["Main menu buttons"]
			local frameWidth = unit/60/12
			for i = 1, MMButtons_len do
				assert(UIButton_Ys[i])
				local butrec = Rec.new(UIButton.x, UIButton_Ys[i], UIButton.w, UIButton.h)
				if not MMButtons[i].isHover then
					palette.logoFront:where { a = 0x20/0xFF }:apply()
				else
					palette.logoFront:where { a = 0x40/0xFF }:apply()
				end
				butrec:draw("fill")
				love.graphics.setLineWidth(frameWidth)
				palette.logoFront:where { a = 1 }:apply()
				butrec:draw("line")
				lg.setFont(font)
				lg.printf(MMButtons[i].text,
					butrec.x,
					butrec.y + (butrec.h - font:getHeight())/2,
					butrec.w, "center")
			end
			if focused_on_options then
				local bg = palette.cellInner:where { a = 0.8 }
				local fg = palette.cellFrame:where { a = 1 }
				local fade = Color.newNV(0, 0, 0, 0.5)
				local button_pad = unit/60
				local menu_margin = unit/60/3
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
				lg.setLineWidth(frameWidth)
				menu_rec:draw("line")
			end
		end
	elseif GM.state == "MainGame" then
		-- FPS
		do
			font = fonts["Debug Info"]
			lg.setFont(font)
			palette.debugInfo:apply()
			lg.printf(
				string.format("FPS: %d", round(1/love.timer.getDelta())),
				0, 5, GM.width - 10, "right")
		end
	end
end

function UI.keypressed(key, scancode, isrepeat)
	-- For buttons @ugly
	if key == "escape" then focused_on_options = false end
end

function UI.keyreleased(key, scancode)
end

function UI.mousepressed(x, y, button)
end

function UI.mousereleased(x, y, button, GM)
	-- For buttons @ugly
	for i = 1, MMButtons_len do
		local thisButton = MMButtons[i]
		if button == 1 and thisButton.isHover then
			thisButton:action(GM)
		end
	end
end

return UI
