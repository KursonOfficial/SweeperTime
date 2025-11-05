Field = {}
Field.firstCell = true
Cell = {}
Cells = {}

local bombChance = 15/100 -- 15% default, but little silly Kurson whants BIGGER. But suddenly, this is predestined by fate, and nobody can chaange it.

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

function Field.mousepressed(button)
	x, y = Field.selected.x, Field.selected.y
	if button == 1 then
		lastClickedCell = { x = Field.selected.x; y = Field.selected.y}
		if not Field.firstCell then
			if Cell.isNotNill(x, y) then
				if not Cells[x][y].flag then
					Cell.reveal(x, y)
				end
			end
		else
			Cell.new(x, y, false)
			Cell.reveal(x, y)
		end
	end
	if button == 2 and not Cell.isRevealed(x, y) then 
		if Cell.isNotNill(x, y) then
			Cells[x][y].flag = not Cells[x][y].flag
		end
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
		Cells[x][y].flag = nill
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
		local radius = 43 -- Was guessed by many tests. This value is optimal
		local inRadius = math.sqrt((x - lastClickedCell.x)^2 + (y - lastClickedCell.y)^2) <= radius
		if BombsAround == 0 and inRadius then
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
	self.flag = false
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
--[[-- FIXME: -------------------------------------------------------------------------------------
	Hay there! Try not to black out while whatching the rest of th code, this part is under
	reconstruction and will be hopefully fixed either by me or by @KursonOfficial.
	But for now... Down there, there is a really scarry code.

	G e t   r e a d y . . .

	-- @Cadragonit
]] ------------------------------------------------------------------------------------------------
				if Field.zoom > 0.2 then
---------------------------------------------------------------------------------------------------
-- DETAILED VERSION:
					for x = RTCorX, LBCorX do
						for y = RTCorY, LBCorY do
							love.graphics.setLineWidth(Cell.rCorner)
							drawRevealedCell = function(mode)
								lg.rectangle(mode,
									x * Cell.cellSize,
									y * Cell.cellSize,
									Cell.cellSize,
									Cell.cellSize,
									Cell.rCorner,
									Cell.rCorner,
									1)
							end
							lg.setColor(cup(palette.cellInner))
							if Field.selected.x ~= x or Field.selected.y ~= y  then
								drawRevealedCell("fill")
								lg.setColor(cup(palette.cellFrame))
								drawRevealedCell("line")
							else
								if Cell.isRevealed(x, y) then
									drawRevealedCell("fill")
									lg.setColor(cup(palette.cellFrame))
									drawRevealedCell("line")
									--lg.setColor(0, 0, 0, 0.4)
									--[[lg.rectangle("line",
										(x-1) * Cell.cellSize,
										(y-1) * Cell.cellSize,
										Cell.cellSize * 3,
										Cell.cellSize * 3,
										Cell.rCorner / 2)]]
								else
									lg.setColor(
										palette.cellSelectedInner.r,
										palette.cellSelectedInner.g,
										palette.cellSelectedInner.b,
										palette.cellSelectedInner.a + 0.05 * math.cos(love.timer.getTime()))
									lg.rectangle("fill",
										x * Cell.cellSize + Cell.rCorner/2,
										y * Cell.cellSize + Cell.rCorner/2,
										Cell.cellSize - Cell.rCorner,
										Cell.cellSize - Cell.rCorner,
										Cell.rCorner / 2)
									lg.setColor(cup(palette.cellSelectedFrame))
									lg.rectangle("line",
										x * Cell.cellSize,
										y * Cell.cellSize,
										Cell.cellSize,
										Cell.cellSize,
										Cell.rCorner,
										Cell.rCorner)
								end
							end
							if Cell.isNotNill(x, y) then
								if Cells[x][y].flag then
									lg.setColor(1, 1, 1)
									lg.draw(sprite.flag.image,
										x * Cell.cellSize,
										y * Cell.cellSize,
										0,
										sprite.flag.scaleFactor)
								end
							end
							if Cell.isRevealed(x, y) then
								lg.setColor(cup(palette.cellRevealed))
								lg.rectangle("fill",
									x * Cell.cellSize + Cell.rCorner/2,
									y * Cell.cellSize + Cell.rCorner/2,
									Cell.cellSize - Cell.rCorner,
									Cell.cellSize - Cell.rCorner,
									Cell.rCorner / 2)
								lg.setColor(1, 1, 1)
								if Cells[x][y].bomb then
									lg.draw(sprite.bombs.image,
										sprite.bombs.quad[Cells[x][y].bombImage],
										x * Cell.cellSize + Cell.rCorner/2,
										y * Cell.cellSize + Cell.rCorner/2,
										0,
										sprite.bombs.scaleFactor - Cell.rCorner/200)
								else
									if Cells[x][y].mines ~= 0 then
										lg.draw(sprite.numbers.image,
											sprite.numbers.quad[Cells[x][y].mines],
											x * Cell.cellSize + Cell.rCorner/2,
											y * Cell.cellSize + Cell.rCorner/2,
											0,
											sprite.numbers.scaleFactor - Cell.rCorner/100)
									end
								end
							end
						end -- FOR
					end -- FOR
---------------------------------------------------------------------------------------------------
				else
---------------------------------------------------------------------------------------------------
-- OPTIMAZED VERSION:
					lg.setColor(cup(palette.cellInner))
					lg.rectangle("fill",
						-GM.Widht  /2 * Field.inverseZoom - Field.pos.x,
						-GM.Height /2 * Field.inverseZoom - Field.pos.y,
						GM.Widht  * Field.inverseZoom,
						GM.Height * Field.inverseZoom)
					lg.setColor(cup(palette.cellFrame))
					for x  = RTCorX, LBCorX do
						love.graphics.line(
							x * Cell.cellSize,
							-GM.Height /2 * Field.inverseZoom - Field.pos.y,
							x * Cell.cellSize,
							 GM.Height /2 * Field.inverseZoom - Field.pos.y)
					end
					for y  = RTCorY, LBCorY do
						love.graphics.line(
							-GM.Widht /2 * Field.inverseZoom - Field.pos.x,
							y * Cell.cellSize,
							 GM.Widht /2 * Field.inverseZoom - Field.pos.x,
							y * Cell.cellSize)
					end
					for x  = RTCorX, LBCorX do
						for y = RTCorY, LBCorY do
							if Cell.isRevealed(x, y) then
								lg.setColor(cup(palette.cellRevealed))
								lg.rectangle("fill",
									x * Cell.cellSize + Cell.rCorner/2,
									y * Cell.cellSize + Cell.rCorner/2,
									Cell.cellSize - Cell.rCorner,
									Cell.cellSize - Cell.rCorner,
									Cell.rCorner / 2)
								lg.setColor(1, 1, 1)
								if Cells[x][y].bomb then
									lg.draw(sprite.bombs.image,
										sprite.bombs.quad[Cells[x][y].bombImage],
										x * Cell.cellSize + Cell.rCorner/2,
										y * Cell.cellSize + Cell.rCorner/2,
										0,
										sprite.bombs.scaleFactor - Cell.rCorner/200)
								else
									if Cells[x][y].mines ~= 0 then
										lg.draw(sprite.numbers.image,
											sprite.numbers.quad[Cells[x][y].mines],
											x * Cell.cellSize + Cell.rCorner/2,
											y * Cell.cellSize + Cell.rCorner/2,
											0,
											sprite.numbers.scaleFactor - Cell.rCorner/100)
									end
								end
							end
							if Cell.isNotNill(x, y) then
								if Cells[x][y].flag then
									lg.setColor(1, 1, 1)
									lg.draw(sprite.flag.image,
										x * Cell.cellSize,
										y * Cell.cellSize,
										0,
										sprite.flag.scaleFactor)
								end
							end
							if Field.selected.x == x and Field.selected.y == y and not Cell.isRevealed(x, y) then
								lg.setColor(
									pallette.cellSelectedInner.r,
									pallette.cellSelectedInner.g,
									pallette.cellSelectedInner.b,
									pallette.cellSelectedInner.a + 0.05 * math.cos(love.timer.getTime()))
								lg.rectangle("fill",
									x * Cell.cellSize + Cell.rCorner/2,
									y * Cell.cellSize + Cell.rCorner/2,
									Cell.cellSize - Cell.rCorner,
									Cell.cellSize - Cell.rCorner,
									Cell.rCorner / 2)
								lg.setColor(cup(palette.cellSelectedFrame))
								lg.rectangle("line",
									x * Cell.cellSize,
									y * Cell.cellSize,
									Cell.cellSize,
									Cell.cellSize,
									Cell.rCorner,
									Cell.rCorner)
							end
						end -- FOR
					end -- FOR
---------------------------------------------------------------------------------------------------
				end
			lg.pop()
		lg.pop()
	end
end
