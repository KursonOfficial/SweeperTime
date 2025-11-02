--слыш UI подойтика сюда!
require "ui"
--Field! да ты! идём поговорим.
require "field"
-- Йоу, радуга, палитра
require "palette"

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

function GM.init()
	lw.setFullscreen(true)
	GM.state = "MainMenu"
	GM.Widht, GM.Height = lg.getDimensions()
	GM.weelY = 0
	GM.weelVel = .2
	UI.init()

	sprite = {numbers = {}, bombs = {}, flag = {}}
	sprite.flag.image = love.graphics.newImage("assets/images/flag.png")
	sprite.numbers.image = love.graphics.newImage("assets/images/numbers.png")
	sprite.bombs.image = love.graphics.newImage("assets/images/bombs.png")

	sprite.numbers.scaleFactor = GM.Height/(10 * 100)
	sprite.numbers.quad ={}
	for y = 0 , 1 do
		for x = 0, 6 do
			sprite.numbers.quad[x + 1 + y * 7] = lg.newQuad(100 * x, 100 * y, 100, 100, sprite.numbers.image)
		end
	end

	sprite.bombs.scaleFactor = GM.Height/(10 * 200)
	sprite.bombs.quad ={}
	for y = 0 , 1 do
		for x = 0, 4 do
			sprite.bombs.quad[x + y * 5] = lg.newQuad(200 * x, 200 * y, 200, 200, sprite.bombs.image)
		end
	end
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
	if GM.state == "MainGame" and button == 1 then
		Field.mousepressed()
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
