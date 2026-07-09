-- Чё, самый умный?
require "modules.algebra"
-- Чё, самый пёстрый?
require "modules.color"
-- Йоу, радуга, палитра
_G.palette = require "modules.palette"
-- Field! да ты! идём поговорим.
require "modules.field"
-- А НУКА СПРАЙТ СЮДА БЫСТРО, Я ПИТЬ ХОЧУ!
require "modules.sprite"

-- game manager типо
_G.GM = {}
GM.version = "v0.3.0-dev"
-- Ну и кем ты будешь? Бугалтером? Будешь вести учёты? Пффф... А мы-то думали...
GM.UD = require "modules.user-data"
-- слыш UI подойтика сюда!
GM.UI = require "modules.ui"

local lg = love.graphics

local function flipFullscreen()
	local target_mode = not love.window.getFullscreen()
	GM.UD.settings.fullscreen = target_mode
	GM.UD:apply()
end

function love.resize(w, h)
	GM.width, GM.height = w, h

	Field.resize(w, h)

	sprite.quads()

	GM.UI.refreshFonts(w, h)
end

function GM.init(self)
	GM.UD:apply()
	GM.state = "MainMenu"
	GM.width, GM.height = lg.getDimensions()
	GM.weelY = 0
	GM.weelVel = .2
	GM.UI:init(self)
	Field.init()
	sprite.init()
end

function GM.update(self, dt)
	GM.UI.update(self, dt)
	if needReturn == true then
		if math.abs(Field.pos.x) > 10 or math.abs(Field.pos.y) > 10 then
			Field.pos.x = Field.pos.x - Field.pos.x / 2 * dt * 10
			Field.pos.y = Field.pos.y - Field.pos.y / 2 * dt * 10
		else
			needReturn = false
		end
	else
		if GM.state == "MainGame" then
			if love.keyboard.isDown("w", "up") then
				Field.pos.y = Field.pos.y + dt * Field.speed
			end
			if love.keyboard.isDown("s", "down") then
				Field.pos.y = Field.pos.y - dt * Field.speed
			end
			if love.keyboard.isDown("a", "left") then
				Field.pos.x = Field.pos.x + dt * Field.speed
			end
			if love.keyboard.isDown("d", "right") then
				Field.pos.x = Field.pos.x - dt * Field.speed
			end
			Field.update()
		end
	end
end

function GM.draw(self)
	if GM.state == "MainGame" then
		Field.draw()
	end
	GM.UI.draw(self)
end

function love.keyreleased(key, scancode)
	GM.UI.keyreleased(key, scancode)
end

function love.keypressed(key, scancode, isrepeat)
	GM.UI.keypressed(key, scancode, isrepeat)
	if GM.state == "MainMenu" then
	elseif GM.state == "MainGame" then
		if key == "space" then needReturn = true end
	end
	if key == "f11" then flipFullscreen() end
end

function love.mousemoved(x, y, dx, dy, istouch)
	if love.mouse.isDown(3) and GM.state == "MainGame" then
		Field.pos.x = Field.pos.x + dx / Field.zoom
		Field.pos.y = Field.pos.y + dy / Field.zoom
	end
end

function love.mousepressed(x, y, button, istouch)
	if GM.state == "MainGame" then
		Field.mousepressed(button)
	elseif GM.state == "MainMenu" then
		GM.UI.mousepressed(x, y, button)
	end
end
function love.mousereleased(x, y, button, istouch)
	if GM.state == "MainGame" then
	elseif GM.state == "MainMenu" then
		GM.UI.mousereleased(x, y, button)
	end
end

function love.wheelmoved(x, y)
	if GM.state == "MainGame" then
		GM.weelY = clamp(GM.weelY + y*GM.weelVel, -2.6, 2)
		Field.zoom = 2 ^ (GM.weelY)
		Field.inverseZoom = 2 ^ (-GM.weelY)
		Field.speed = GM.height * (1/2 ^ (GM.weelY/2))
	end
end

function love.load() GM:init() end
function love.update(dt) GM:update(dt) end
function love.draw() GM:draw() end
