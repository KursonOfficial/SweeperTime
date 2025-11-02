UI = {}

function UI.printLogo()
	lg.setFont(lg.newFont(50))
	lg.setColor(0.2 * math.cos(love.timer.getTime()*2), 0.2, 0.2)
	lg.printf("SWEEPER TIME", math.cos(love.timer.getTime())*3, math.sin(love.timer.getTime())*3, GM.Widht, "center")
	lg.setFont(lg.newFont(50))
	lg.setColor(cup(palette.logoFront))
	lg.printf("SWEEPER TIME", 0, 0, GM.Widht, "center", 0, 1, 1, 0, 0, 0.2 * math.cos(love.timer.getTime()*0.2))
end

function UI.draw()
	if GM.state == "MainMenu" then
		lg.setFont(logoFont)
		lg.setColor(cup(palette.versionText))
		lg.printf(GM.version,0 ,0 , GM.Widht, "right")
		UI.printLogo()
	end if GM.state == "MainGame" then
		lg.setFont(debugInfoFont)
		lg.setColor(cup(palette.debugInfo))
		lg.printf(Field.zoom,0 ,0 , GM.Widht, "right")
		lg.printf(love.mouse.getX() - GM.Widht/2 ,0 ,20 , GM.Widht, "right")
		lg.printf(love.mouse.getY() - GM.Height/2 ,0 ,40 , GM.Widht, "right")
		lg.printf(Field.pos.x ,0 ,80 , GM.Widht, "right")
		lg.printf(Field.pos.y ,0 ,100 , GM.Widht, "right")
		if Field.firstCell then
			lg.setColor(cup(palette.hint))
			lg.printf("ВЫ СМОЖЕТЕ ДВАГАТЬ КАМЕРОЙ НА W,S,A,D ИЛИ НА СТРЕЛОЧКИ ПОСЛЕ ТОГО КАК ОТКРОЕТЕ ПЕВРУЮ КЛКТКУ!!!!! ЙОУ!!!111!!!", 0 , GM.Height - 20, GM.Widht , "right")
		end
	end
end
function UI.init()
	logoFont = lg.newFont(10)
	debugInfoFont = lg.newFont(20)
end
function UI.starGame()
end
