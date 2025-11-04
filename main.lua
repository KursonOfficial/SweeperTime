--слыш UI подойтика сюда!
require "modules.ui"
--Field! да ты! идём поговорим.
require "modules.field"
-- Йоу, радуга, палитра
require "modules.palette"
--А НУКА СПРАЙТ СЮДА БЫСТРО, Я ПИТЬ ХОЧУ!
require "modules.sprite"

--game manager типо
GM = {}

GM.version = "v0.1"

lg = love.graphics
lw = love.window

function flipFullscreen()
	local mode = lw.getFullscreen()
	lw.setFullscreen(not mode)
	GM.Widht, GM.Height = lg.getDimensions()
end

function love.resize(w , h)
	GM.Widht, GM.Height = w, h
	
	Field.speed = GM.Height
	Cell.cellSize = GM.Height/10
	Cell.rCorner = Cell.cellSize/8

	sprite.quads()
end

function GM.init()
	lw.setFullscreen(true)
	GM.state = "MainMenu"
	GM.Widht, GM.Height = lg.getDimensions()
	GM.weelY = 0
	GM.weelVel = .2
	UI.init()

	sprite.init()
end

function GM.draw()
	Field.draw()
	UI.draw()
end

function GM.update(dt)
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
		end
	end
end

function love.keypressed(key, scancode, isrepeat)
	if GM.state == "MainMenu" then
		if key ~= "escape" then
			Field.init()
			UI.starGame()
			GM.state = "MainGame"
		end
	end
	if GM.state == "MainGame" then
		if key == "space" then needReturn = true end
	end
	if key == "escape" then love.event.quit() end
	if key == "f11"    then flipFullscreen() end
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
	end
end

function love.wheelmoved(x, y)
	if GM.state == "MainGame" then
		GM.weelY = math.max(-3, math.min( 3, GM.weelY + y * GM.weelVel))
		Field.zoom = 2 ^ (GM.weelY)
		Field.inverseZoom = 2 ^ (-GM.weelY)
		Field.speed = GM.Height * (1/2 ^ (GM.weelY/2))
	end
end

function love.load()
	GM:init()
end

function love.update(dt)
	GM.update(dt)
	if GM.state == "MainGame" then
		Field.update()
	end
end

function love.draw()
	GM.draw()
end
