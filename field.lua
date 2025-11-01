Field = {}
Field.firstCell = true
Cell = {}
Cells = {}

local bombChance = 15/100 -- 15% default

function Field.init()
	Field.firstCell = true
	Field.speed = GM.Height
	Field.selected  = {}
	Field.zoom = 1
	Cell.cellSize = GM.Height/10
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

function Field.reset()
	Cells = {}
	Field.firstCell = true
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
	if Cells[x][y].bomb then
		--Field.reset()
		--GM.state = "MainMenu"
		--return
	end
	if not Cells[x][y].revealed then
		Cells[x][y].revealed = true
		local BombsAround = 0
		for dx = -1, 1 do
			for dy = -1, 1 do
				if not Cell.isNotNill(x + dx, y + dy) then
					if dx ~= 0 or dy ~= 0 then
						isBomb = math.random() < bombChance
						if not Field.firstCell then
							Cell.new(x + dx, y + dy, isBomb)
							BombsAround = BombsAround + (isBomb and 1 or 0)
						else
							Cell.new(x + dx , y + dy, false)
						end
					end
				else
					if Cells[x + dx][y + dy].bomb then
						BombsAround = BombsAround + 1
					end
				end
			end
		end
		Field.firstCell = false
		print(BombsAround)
		Cells[x][y].mines = BombsAround
		if BombsAround == 0 then
			Cell.revealAround(x,y)
		end
	end
end

function Cell.revealAround(x, y)
	Cell.reveal(x - 1, y - 1)
	Cell.reveal(x - 1, y    )
	Cell.reveal(x - 1, y + 1)
	Cell.reveal(x    , y + 1)
	Cell.reveal(x    , y - 1)
	Cell.reveal(x + 1, y - 1)
	Cell.reveal(x + 1, y    )
	Cell.reveal(x + 1, y + 1)
	-- Unroll of:
	--[[
	for dx = -1, 1 do
		for dy = -1, 1 do
			if dx ~= 0 or dy ~= 0 then
				Cell.reveal(x + dx, y + dy)
			end
		end
	end
	]]
end

function Cell.new(x, y, isBomb)
	if Cells[x] == nill then
		Cells[x] = {}
	end
	self = {}
	self.mines = 0
	self.bomb = isBomb
	if isBomb then self.bombImage = math.random(0 , #sprite.bombs.quad) end
	self.revealed = false
	Cells[x][y] = self
end

function Cell.isNotNill(x, y)
	if Cells[x] ~= nill then
		if Cells[x][y] ~= nill then
			return true
		end
	end
	return false
end

function Cell.isRevealed(x, y)
	if Cell.isNotNill(x, y) then
		return Cells[x][y].revealed
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
				if Field.zoom > 0.2 then
					for x = RTCorX, LBCorX do
						for y = RTCorY, LBCorY do	
							love.graphics.setLineWidth( Cell.rCorner)
							lg.setColor(cup(palette.cellInner))
							if Field.selected.x ~= x or Field.selected.y ~= y  then
								lg.rectangle("fill", x * Cell.cellSize, y * Cell.cellSize, Cell.cellSize, Cell.cellSize, Cell.rCorner, Cell.rCorner, 1)
								lg.setColor(cup(palette.cellFrame))
								lg.rectangle("line", x * Cell.cellSize, y * Cell.cellSize, Cell.cellSize, Cell.cellSize, Cell.rCorner, Cell.rCorner, 1)
							else
								if Cell.isRevealed(x, y) then
									lg.rectangle("fill", x * Cell.cellSize, y * Cell.cellSize, Cell.cellSize, Cell.cellSize, Cell.rCorner, Cell.rCorner, 1)
									lg.setColor(cup(palette.cellFrame))
									lg.rectangle("line", x * Cell.cellSize, y * Cell.cellSize, Cell.cellSize, Cell.cellSize, Cell.rCorner, Cell.rCorner, 1)
									--lg.setColor(0,0,0, 0.4)
									--lg.rectangle("line", (x-1) * Cell.cellSize, (y-1) * Cell.cellSize , Cell.cellSize * 3  , Cell.cellSize * 3 , Cell.rCorner / 2)
								else
									lg.setColor(1, 1, 0.8, 0.4 + 0.05 * math.cos(love.timer.getTime()))
									lg.rectangle("fill", x * Cell.cellSize + Cell.rCorner/2, y * Cell.cellSize + Cell.rCorner/2, Cell.cellSize - Cell.rCorner , Cell.cellSize - Cell.rCorner, Cell.rCorner / 2)
									lg.setColor(cup(palette.cellSelectedFrame))
									lg.rectangle("line", x * Cell.cellSize, y * Cell.cellSize, Cell.cellSize, Cell.cellSize, Cell.rCorner, Cell.rCorner)
								end
							end
							if Cell.isRevealed(x, y ) then
								lg.setColor(cup(palette.cellRevealed))
								lg.rectangle("fill", x * Cell.cellSize + Cell.rCorner/2, y * Cell.cellSize + Cell.rCorner/2, Cell.cellSize - Cell.rCorner , Cell.cellSize - Cell.rCorner, Cell.rCorner / 2)
								
								lg.setColor(1, 1, 1)
								if Cells[x][y].bomb then 
									lg.draw(sprite.bombs.image, sprite.bombs.quad[Cells[x][y].bombImage], x * Cell.cellSize + Cell.rCorner/2, y * Cell.cellSize + Cell.rCorner/2, 0, sprite.bombs.scaleFactor - Cell.rCorner/200)
								else
									if Cells[x][y].mines ~= 0 then
										lg.draw(sprite.numbers.image, sprite.numbers.quad[Cells[x][y].mines], x * Cell.cellSize + Cell.rCorner/2, y * Cell.cellSize + Cell.rCorner/2, 0, sprite.numbers.scaleFactor - Cell.rCorner/100)
									end
								end
							end
						--for end	
						end
					--for end	
					end
				else
					lg.setColor(cup(palette.cellInner))
					lg.rectangle("fill", -GM.Widht/2* Field.inverseZoom - Field.pos.x, -GM.Height/2* Field.inverseZoom - Field.pos.y, GM.Widht * Field.inverseZoom, GM.Height * Field.inverseZoom)
					lg.setColor(cup(palette.cellFrame))
					for x  = RTCorX, LBCorX do
						love.graphics.line( x * Cell.cellSize , -GM.Height/2* Field.inverseZoom - Field.pos.y, x * Cell.cellSize,  GM.Height/2* Field.inverseZoom - Field.pos.y)
					end
					for y  = RTCorY, LBCorY do
						love.graphics.line( -GM.Widht/2* Field.inverseZoom - Field.pos.x, y * Cell.cellSize, GM.Widht/2* Field.inverseZoom - Field.pos.x, y * Cell.cellSize)
					end
					for x  = RTCorX, LBCorX do
						for y = RTCorY, LBCorY do
							if Cell.isRevealed(x, y) then
								lg.setColor(cup(palette.cellRevealed))
								lg.rectangle("fill", x * Cell.cellSize + Cell.rCorner/2, y * Cell.cellSize + Cell.rCorner/2, Cell.cellSize - Cell.rCorner , Cell.cellSize - Cell.rCorner, Cell.rCorner / 2)

								lg.setColor(1, 1, 1)
								if Cells[x][y].bomb then 
									lg.draw(sprite.bombs.image, sprite.bombs.quad[Cells[x][y].bombImage], x * Cell.cellSize + Cell.rCorner/2, y * Cell.cellSize + Cell.rCorner/2, 0, sprite.bombs.scaleFactor - Cell.rCorner/200)
								else
									if Cells[x][y].mines ~= 0 then
										lg.draw(sprite.numbers.image, sprite.numbers.quad[Cells[x][y].mines], x * Cell.cellSize + Cell.rCorner/2, y * Cell.cellSize + Cell.rCorner/2, 0, sprite.numbers.scaleFactor - Cell.rCorner/100)
									end
								end
							end
							if Field.selected.x == x and Field.selected.y == y and not Cell.isRevealed(x, y) then
								lg.setColor(1, 1, 0.8, 0.4 + 0.05 * math.cos(love.timer.getTime()))
								lg.rectangle("fill", x * Cell.cellSize + Cell.rCorner/2, y * Cell.cellSize + Cell.rCorner/2, Cell.cellSize - Cell.rCorner , Cell.cellSize - Cell.rCorner, Cell.rCorner / 2)
								lg.setColor(cup(palette.cellSelectedFrame))
								lg.rectangle("line", x * Cell.cellSize, y * Cell.cellSize, Cell.cellSize, Cell.cellSize, Cell.rCorner, Cell.rCorner)
							end
						end
					end
				end
			lg.pop()
		lg.pop()
	end
end
