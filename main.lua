-- Чё, самый умный?
require "modules.algebra"
-- Чё, самый пёстрый?
require "modules.color"
-- А НУКА СПРАЙТ СЮДА БЫСТРО, Я ПИТЬ ХОЧУ!
require "modules.sprite"

-- game manager типо
_G.GM = {}
GM.version = "v0.3.0-dev"
-- Ну и кем ты будешь? Бугалтером? Будешь вести учёты? Пффф... А мы-то думали...
GM.UD = require "modules.user-data"
-- слыш UI подойтика сюда!
GM.UI = require "modules.ui"
-- Field! да ты! идём поговорим.
GM.Field = require "modules.field"
-- Йоу, радуга, палитра
_G.palette = require "modules.palette"

local lg = love.graphics

local function flipFullscreen()
	local target_mode = not love.window.getFullscreen()
	GM.UD.settings.fullscreen = target_mode
	GM.UD:apply()
end

function love.resize(w, h)
	GM.width, GM.height = w, h

	GM.Field:resize(w, h)

	sprite.quads()

	GM.UI.refreshFonts(w, h)
end

function GM.init(self)
	self.UD:apply()
	self.state = "MainMenu"
	self.width, GM.height = lg.getDimensions()
	self.weelY = 0
	self.weelVel = .2
	self.UI:init(self)
	self.Field:init(self)
	sprite.init()
end

function GM.update(self, dt)
	self.UI.update(self, dt)
	self.Field:update(self, dt)
end

function GM.draw(self)
	if self.state == "MainGame" then
		self.Field:draw(self)
	end
	self.UI.draw(self)
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
		GM.Field.pos.x = GM.Field.pos.x + dx / GM.Field.zoom
		GM.Field.pos.y = GM.Field.pos.y + dy / GM.Field.zoom
	end
end

function love.mousepressed(x, y, button, istouch)
	if GM.state == "MainGame" then
		GM.Field.mousepressed(button)
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
		GM.Field.zoom = 2 ^ (GM.weelY)
		GM.Field.inverseZoom = 2 ^ (-GM.weelY)
		GM.Field.speed = GM.height * (1/2 ^ (GM.weelY/2))
	end
end

function love.load() GM:init() end
function love.update(dt) GM:update(dt) end
function love.draw() GM:draw() end
