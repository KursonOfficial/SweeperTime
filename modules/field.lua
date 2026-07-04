Field = {}

local Cell = {}
local Cells = {}
local lastClickedCell = { x = nil, y = nil }

local lg = love.graphics

function Field.init()
	Field.firstCell = true
	Field.speed = GM.height
	Field.selected  = {}
	Field.zoom = 1
	Field.pos = { x = 0 , y = 0 }
	Cell.cellSize = GM.height/10
	Cell.rCorner = Cell.cellSize/8
	math.randomseed(os.time())
end

function Field.update()
	lg.translate(GM.width/2, GM.height/2)
	lg.scale(Field.zoom, Field.zoom)
	lg.translate(Field.pos.x, Field.pos.y)
	local MousePosX, MousePosY = love.graphics.inverseTransformPoint(love.mouse.getPosition())
	Field.selected.x = math.floor(MousePosX / Cell.cellSize)
	Field.selected.y = math.floor(MousePosY / Cell.cellSize)
end

function Field.reset()
	Cells = {}
	Field.firstCell = true
end

function Field.resize(w, h)
	Field.speed = GM.height
	Cell.cellSize = GM.height/10
	Cell.rCorner = Cell.cellSize/8
end

function Field.mousepressed(button)
	local x, y = Field.selected.x, Field.selected.y
	if button == 1 then
		lastClickedCell.x = Field.selected.x
		lastClickedCell.y = Field.selected.y
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
		if Cell.isRevealed(x, y) then
			if Cells[x][y].mines == Cell.countAround(x, y, "flags") then
				if not Cells[x-1][y-1].flag then Cell.reveal(x-1, y-1) end
				if not Cells[x-1][y  ].flag then Cell.reveal(x-1, y  ) end
				if not Cells[x-1][y+1].flag then Cell.reveal(x-1, y+1) end
				if not Cells[x  ][y+1].flag then Cell.reveal(x  , y+1) end
				if not Cells[x  ][y-1].flag then Cell.reveal(x  , y-1) end
				if not Cells[x+1][y-1].flag then Cell.reveal(x+1, y-1) end
				if not Cells[x+1][y  ].flag then Cell.reveal(x+1, y  ) end
				if not Cells[x+1][y+1].flag then Cell.reveal(x+1, y+1) end
			end
		end
	end
	if button == 2 then
		if Cell.isNotNill(x, y) and not Cell.isRevealed(x, y)then
			Cells[x][y].flag = not Cells[x][y].flag
		end
		if Cell.isRevealed(x, y) then
			if Cells[x][y].mines == Cell.countAround(x, y, "hidden") then
				if not Cells[x-1][y-1].revealed then Cells[x-1][y-1].flag = true end
				if not Cells[x-1][y  ].revealed then Cells[x-1][y  ].flag = true end
				if not Cells[x-1][y+1].revealed then Cells[x-1][y+1].flag = true end
				if not Cells[x  ][y+1].revealed then Cells[x  ][y+1].flag = true end
				if not Cells[x  ][y-1].revealed then Cells[x  ][y-1].flag = true end
				if not Cells[x+1][y-1].revealed then Cells[x+1][y-1].flag = true end
				if not Cells[x+1][y  ].revealed then Cells[x+1][y  ].flag = true end
				if not Cells[x+1][y+1].revealed then Cells[x+1][y+1].flag = true end
			end
		end
	end
end

function Cell.reveal(x, y)
	if Cells[x][y].bomb then
		--Field.reset()
		--GM.state = "MainMenu"
		--return
		-- TODO: ultraMegaSuperScaryScreamer()
	end
	if not Cells[x][y].revealed then
		Cells[x][y].revealed = true
		Cells[x][y].flag = nil
		local BombsAround = 0
		for dx = -1, 1 do
			for dy = -1, 1 do
				if not Cell.isNotNill(x + dx, y + dy) then
					if dx ~= 0 or dy ~= 0 then
						local isBomb = math.random() < GM.UD.settings.bomb_chance
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

function Cell.countAround(x, y, type)
	if type == "flags" then
		local flags = 0
		if Cells[x-1][y-1].flag then flags = flags + 1 end
		if Cells[x-1][y  ].flag then flags = flags + 1 end
		if Cells[x-1][y+1].flag then flags = flags + 1 end
		if Cells[x  ][y+1].flag then flags = flags + 1 end
		if Cells[x  ][y-1].flag then flags = flags + 1 end
		if Cells[x+1][y-1].flag then flags = flags + 1 end
		if Cells[x+1][y  ].flag then flags = flags + 1 end
		if Cells[x+1][y+1].flag then flags = flags + 1 end
		return flags
	end
	if type == "hidden" then
		local hidden = 0
		if not Cells[x-1][y-1].revealed then hidden = hidden + 1 end
		if not Cells[x-1][y  ].revealed then hidden = hidden + 1 end
		if not Cells[x-1][y+1].revealed then hidden = hidden + 1 end
		if not Cells[x  ][y+1].revealed then hidden = hidden + 1 end
		if not Cells[x  ][y-1].revealed then hidden = hidden + 1 end
		if not Cells[x+1][y-1].revealed then hidden = hidden + 1 end
		if not Cells[x+1][y  ].revealed then hidden = hidden + 1 end
		if not Cells[x+1][y+1].revealed then hidden = hidden + 1 end
		return hidden
	end
	assert(false, "UNREACHABLE")
end

function Cell.new(x, y, isBomb)
	if Cells[x] == nil then
		Cells[x] = {}
	end
	local self = {}
	self.flag = false
	self.mines = 0
	self.bomb = isBomb
	if isBomb then self.bombImage = math.random(0 , #sprite.bombs.quad) end
	self.revealed = false
	Cells[x][y] = self
end

function Cell.isNotNill(x, y)
	return (Cells[x] ~= nil) and (Cells[x][y] ~= nil)
end

function Cell.isRevealed(x, y)
	return Cell.isNotNill(x, y) and Cells[x][y].revealed
end

function Field.draw()
	if GM.state == "MainGame" then
		lg.push()
			lg.translate(GM.width/2, GM.height/2)
			lg.scale(Field.zoom, Field.zoom)
			lg.push()
				lg.translate(Field.pos.x, Field.pos.y)
				local RTCorX, RTCorY = love.graphics.inverseTransformPoint(0, 0)
				local LBCorX, LBCorY = love.graphics.inverseTransformPoint(GM.width, GM.height)
				RTCorX, RTCorY = math.floor(RTCorX / Cell.cellSize) , math.floor(RTCorY / Cell.cellSize)
				LBCorX, LBCorY = math.floor(LBCorX / Cell.cellSize) , math.floor(LBCorY / Cell.cellSize)
				for x = RTCorX, LBCorX do
					for y = RTCorY, LBCorY do
						lg.setLineWidth(Cell.rCorner)
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
			lg.pop()
		lg.pop()
	end
end

