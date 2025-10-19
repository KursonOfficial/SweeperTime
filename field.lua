--[[короче рассказываю как тут всё устроенно
	Field посути наше поле, с методами для отрисовки клекток, установки значний при старте, обработки нажйтий по клеткам и тп
	Cell тоже имеет метооды но для взаимодействия с самим клетками, в Cell хранятся все клетки в 2х мерном массиве типо Cell[x][y]
	нужно быть с этим аккуратно тк если Cell[x] не существует то обратиться к Y не получится(выдаст ошибку), поэтому тут есть метод Cell.isNotNill(x, y)
	который сначало проверят есть ли Cell[x] а после этого и Cell[x][y]


	конечно в коде нет комметариев чтоб обяснить все тонкости,
	потомучто мне тупо лень их писать хех, довольствуйтесь этой писаниной сверху. а я буду сосать хуй когда мне чтото станет не понятно из того что я там насрал
--]]

Field = {}
Field.firstCell = true
Cell = {}

function Field.init()
	Field.firstCell = true
	Field.speed = GM.Height
	Field.selected  = {}
	Field.zoom = 1
	Cell.cellSize = GM.Height/10
	Cell.Font = lg.newFont(GM.Height/10)
	Cell.rCorner = Cell.cellSize/8
	math.randomseed(os.time())

end

function Field.update()
	lg.translate(GM.Widht/2, GM.Height/2)
	lg.scale(Field.zoom, Field.zoom)
	lg.translate(Field.pos.x, Field.pos.y)
	MousePosX, MousePosY = love.graphics.inverseTransformPoint(love.mouse.getPosition())
	Field.selected.x = math.floor(MousePosX / Cell.cellSize)
	Field.selected.y = math.floor(MousePosY / Cell.cellSize)
end

function Field.mousepressed()
	x, y = Field.selected.x, Field.selected.y
	if not Field.firstCell then
		if Cell.isNotNill(x, y) then
			Cell.reveal(x, y)
		end
	else
		Cell.new(x, y, false)
		Cell.reveal(x, y)
	end
end

function Cell.reveal(x, y)
	if Cell[x][y].bomb then
		GM.state = "MainMenu"
	end
	if not Cell[x][y].revealed then
		Cell[x][y].revealed = true
		local BombsAround = 0
		for dx = -1, 1 do
			for dy = -1, 1 do
				if not Cell.isNotNill(x + dx, y + dy) then
					if dx ~= 0 or dy ~= 0 then
						if math.random() < 0.15 then
							isBomb = true
						else
							isBomb = false
						end
						if not Field.firstCell then
							Cell.new(x + dx, y + dy, isBomb)
							if isBomb then
								BombsAround = BombsAround + 1
								print('bomb!!!!')
							end
						else
							Cell.new(x + dx , y + dy, false)
						end
					end
				else
					if Cell[x + dx][y + dy].bomb then
						print('bomb!!!!')
						BombsAround = BombsAround + 1
					end
				end
			end
		end
		Field.firstCell = false
		print(BombsAround)
		Cell[x][y].mines = BombsAround
		if BombsAround == 0 then
			print("open")
			Cell.revealAround(x,y)
		end
	end
end

function Cell.revealAround(x, y)
	for dx = -1, 1 do
		for dy = -1, 1 do
			if dx ~= 0 or dy ~= 0 then
				Cell.reveal(x + dx, y + dy)
			end
		end
	end
end

function Cell.new(x, y, isBomb)
	if Cell[x] == nill then
		Cell[x] = {}
	end
	self = {}
	self.mines = 0
	self.bomb = isBomb
	self.revealed = false
	Cell[x][y] = self
end

function Cell.isNotNill(x, y)
	if Cell[x] ~= nill then
		if Cell[x][y] ~= nill then
			return true
		end
	end
	return false
end

function Cell.isRevealed(x, y)
	if Cell.isNotNill(x, y) then
		return Cell[x][y].revealed
	end
	return false
end

Field.zoom = 1
Field.pos = {x = 0 , y = 0}
function Field.draw()
	if GM.state == "MainGame" then
		lg.push ()
			lg.translate(GM.Widht/2, GM.Height/2)
			lg.scale(Field.zoom, Field.zoom)
			lg.push()
				lg.translate(Field.pos.x, Field.pos.y)

				RTCorX, RTCorY = love.graphics.inverseTransformPoint( 0, 0 )
				LBCorX, LBCorY = love.graphics.inverseTransformPoint( GM.Widht, GM.Height )
				RTCorX, RTCorY = math.floor( RTCorX / Cell.cellSize) , math.floor( RTCorY / Cell.cellSize)
				LBCorX, LBCorY = math.floor( LBCorX / Cell.cellSize) , math.floor( LBCorY / Cell.cellSize)
				for x  = RTCorX, LBCorX do
					for y = RTCorY, LBCorY do
						love.graphics.setLineWidth( Cell.rCorner)
						if y == LBCorY  or y == RTCorY  or x == LBCorX  or x == RTCorX  then
							lg.setColor(H2C(palette.Mystic_1))
						else
							lg.setColor(H2C(palette.Mystic_2))
						end

						if Field.selected.x ~= x or Field.selected.y ~= y or Cell.isRevealed(x, y) then
							lg.rectangle("fill", x * Cell.cellSize, y * Cell.cellSize, Cell.cellSize, Cell.cellSize, Cell.rCorner, Cell.rCorner, 1)
							lg.setColor(H2C(palette.CellFrame2))
							lg.rectangle("line", x * Cell.cellSize, y * Cell.cellSize, Cell.cellSize, Cell.cellSize, Cell.rCorner, Cell.rCorner, 1)
						else
							lg.setColor(H2C(palette.Mystic_3))
							lg.rectangle("fill", x * Cell.cellSize + Cell.rCorner/2, y * Cell.cellSize + Cell.rCorner/2, Cell.cellSize - Cell.rCorner , Cell.cellSize - Cell.rCorner, Cell.rCorner / 2)
							lg.setColor(H2C(palette.Mystic_4))
							lg.rectangle("line", x * Cell.cellSize, y * Cell.cellSize, Cell.cellSize, Cell.cellSize, Cell.rCorner, Cell.rCorner)
							--lg.rectangle("line", x * Cell.cellSize + Cell.rCorner/2, y * Cell.cellSize + Cell.rCorner/2, Cell.cellSize - Cell.rCorner , Cell.cellSize - Cell.rCorner, Cell.rCorner, Cell.rCorner, 1)
						end
						--if Cell.isNotNill(x, y) then
							--if Cell[x][y].bomb then
							--	lg.setColor(1, 0, 0)
							--	lg.rectangle("fill", x * Cell.cellSize + Cell.rCorner/2, y * Cell.cellSize + Cell.rCorner/2, Cell.cellSize - Cell.rCorner , Cell.cellSize - Cell.rCorner, Cell.rCorner / 2)
							--else
								--lg.setColor(0, 1, 0)
								--lg.rectangle("fill", x * Cell.cellSize + Cell.rCorner/2, y * Cell.cellSize + Cell.rCorner/2, Cell.cellSize - Cell.rCorner , Cell.cellSize - Cell.rCorner, Cell.rCorner / 2)
								if Cell.isRevealed(x, y ) then
									lg.setColor(H2C(palette.CellRevealed))
									lg.rectangle("fill", x * Cell.cellSize + Cell.rCorner/2, y * Cell.cellSize + Cell.rCorner/2, Cell.cellSize - Cell.rCorner , Cell.cellSize - Cell.rCorner, Cell.rCorner / 2)
									lg.setColor(1, 1, 1)
									if Cell[x][y].mines ~= 0 then
										lg.setFont(Cell.Font)
										lg.print(Cell[x][y].mines, x * Cell.cellSize, y * Cell.cellSize)
									end
								end
							--end
						--end
					end
				end
			lg.pop()
		lg.pop()
	end
end