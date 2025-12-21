UI = {}

local Vector2 = {
	new = function(_x, _y)
		return setmetatable({x = _x, y = _y}, self)
	end,
	__index = {
		x = 0,
		y = 0,
	},
}
local Rec = {
	new = function(_x, _y, _w, _h)
		return setmetatable({x = _x, y = _y, w = _w, h = _h}, self)
	end,
	__index = {
		x = 0,
		y = 0,
		w = 0,
		h = 0,
	},
}

local lerp = function(a, b, t)
	return a + (b - a)*t
end

local checkCollisionPointRec = function(point, rec)
	local collision = false
	if (point.x >= rec.x)          and
	   (point.x < (rec.x + rec.w)) and
	   (point.y >= rec.y)          and
	   (point.y < (rec.y + rec.h)) then
	   collision = true
	end
	return collision
end

UI.refreshFonts = function()
	versionFont       = lg.newFont(GM.Height * 1/72)
	logoFont          = lg.newFont(GM.Height * 4/45)
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
	if GM.state == "MainMenu" then
		local BUTTON_AMMOUNT = 3
		local SEGMENTS = 12
		local NSEGMENT = 4
		-- Background
		local sw, sh = lg.getDimensions()
		lg.setShader(bgShader)
		lg.setColor(1, 1, 1, 1)
		lg.rectangle("fill", 0, 0, sw, sh)
		lg.setShader()
		-- Verson
		lg.setFont(versionFont)
		lg.setColor(cup(palette.versionText))
		local versionTextPadding = {w = 10, h = 5}
		lg.printf(versionDisplayText,
			versionTextPadding.w,
			GM.Height - versionFont:getHeight() - versionTextPadding.h,
			GM.Widht, "left")
		-- Logo (Which is Title)
		local logoPosY =
			(GM.Height - logoFont:getHeight())*(NSEGMENT/SEGMENTS)
		UI.printLogo(0, logoPosY, 2, GM.Height/80)
		-- Buttons
		-- TODO: clean up this mess
		local GMHUnit = GM.Height/60
		local buttonUIPad = GMHUnit
		local buttonUIW = logoFont:getWidth("Sweeper Time")*3/4
		local buttonUIH = GMHUnit*3
		local allButtonsHeight = buttonUIH*BUTTON_AMMOUNT + buttonUIPad*(BUTTON_AMMOUNT-1)
		local buttonUIFirstButtonY = GM.Height*((SEGMENTS-NSEGMENT)/SEGMENTS)-allButtonsHeight/2
		buttons = {}
		assert(BUTTON_AMMOUNT >= 1)
		-- TODO: aling first button not by logo, but all buttons to center
		buttons[1] = Rec.new(
			(GM.Widht-buttonUIW)/2,
			buttonUIFirstButtonY,
			buttonUIW,
			buttonUIH)
		for i = 1, BUTTON_AMMOUNT-1 do
			buttons[#buttons+1] = Rec.new(
				(GM.Widht-buttonUIW)/2,
				buttons[#buttons].y + buttons[#buttons].h + buttonUIPad,
				buttonUIW,
				buttonUIH)
		end
		local drawButton = function(mode, button)
			lg.rectangle(mode, button.x, button.y, button.w, button.h)
		end
		for i = 1, #buttons do
			-- TODO: add text to buttons
			-- TODO: add cool effects
			-- lg.setColor(palette.logoFront.r, palette.logoFront.g, palette.logoFront.b, 0.8)
			-- drawButton("fill", buttons[i])
			love.graphics.setLineWidth(GMHUnit/12)
			lg.setColor(palette.logoFront.r, palette.logoFront.g, palette.logoFront.b, 1)
			drawButton("line", buttons[i])
		end
		-- Press any button hint
		--[[
		local hintTilt = lerp(0.4, 0.8, (math.cos(love.timer.getTime()*2 + math.pi/2)+1)/2)
		lg.setColor(
			1,
			1,
			1,
			hintTilt)
		lg.setFont(anyButtonHintFont)
		lg.printf("Press any button to play...",
			0, GM.Height*(1 - 1/8),
			GM.Widht, "center")
		--]]
	elseif GM.state == "MainGame" then
		lg.setFont(debugInfoFont)
		lg.setColor(cup(palette.debugInfo))
		local trunk = function(x, n)
			return x - (x % 10^(-n))
		end
		function round(number)
			 return number >= 0 and math.floor(number + 0.5) or math.ceil(number - 0.5)
		end
		lg.printf(
			string.format("FPS: %d", round(1/love.timer.getDelta())),
			0, 0, GM.Widht, "right")
		if Field.firstCell then
			lg.setColor(cup(palette.hint))
			lg.printf("ВЫ СМОЖЕТЕ ДВАГАТЬ КАМЕРОЙ НА W,S,A,D ИЛИ НА СТРЕЛОЧКИ ПОСЛЕ ТОГО КАК ОТКРОЕТЕ ПЕВРУЮ КЛКТКУ!!!!! ЙОУ!!!111!!!", 0 , GM.Height - 20, GM.Widht , "right")
		end
	end
end

function UI.starGame()
end
