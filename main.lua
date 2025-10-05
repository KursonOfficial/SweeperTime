--слыш UI подойтика сюда!
require "ui"
--Field! да ты! идём поговорим.
require "field"
--game manager типо
GM    = {}

GM.version = "v0.1"

lg = love.graphics

function GM.init()
    love.window.setFullscreen( true )
    GM.state = "MainMenu"
    GM.Widht, GM.Height = lg.getDimensions()
    GM.weelY = 0
	GM.weelVel = .2
end

function GM.reset()
    Field.firstCell = true
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
    if key == "escape" then
        love.event.quit()
    end
    if key == "space" then
        if GM.state == "MainMenu" then
            Field.init()  
            UI.starGame()
            GM.state = "MainGame"
        end
        needReturn = true        
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
