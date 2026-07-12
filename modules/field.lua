local Field = {}

local Cells = {}
local Cell = {}
local needReturn
local cellSize
local rCorner

local lastClickedCell = { x = nil, y = nil }

local lg = love.graphics

function Field.init(self, GM)
	self:resize(GM.width, GM.height)
	self.firstCell = true
	self.selected  = {}
	self.zoom      = 1
	self.pos       = { x = 0, y = 0 }
end

function Field.update(self, GM, dt)
	if needReturn == true then
		if math.abs(self.pos.x) > 10 or math.abs(self.pos.y) > 10 then
			self.pos.x = self.pos.x - self.pos.x / 2 * dt * 10
			self.pos.y = self.pos.y - self.pos.y / 2 * dt * 10
		else
			needReturn = false
		end
	else
		if GM.state == "MainGame" then
			if love.keyboard.isDown("w", "up") then
				self.pos.y = self.pos.y + dt * self.speed
			end
			if love.keyboard.isDown("s", "down") then
				self.pos.y = self.pos.y - dt * self.speed
			end
			if love.keyboard.isDown("a", "left") then
				self.pos.x = self.pos.x + dt * self.speed
			end
			if love.keyboard.isDown("d", "right") then
				self.pos.x = self.pos.x - dt * self.speed
			end
			if love.keyboard.isDown("space") then needReturn = true end
		end
	end

	lg.push()
	lg.translate(GM.width/2, GM.height/2)
	lg.scale(self.zoom, self.zoom)
	lg.translate(self.pos.x, self.pos.y)
	local MousePosX, MousePosY = love.graphics.inverseTransformPoint(love.mouse.getPosition())
	self.selected.x = math.floor(MousePosX / cellSize)
	self.selected.y = math.floor(MousePosY / cellSize)
	lg.pop()
end

function Field.reset(self)
	Cells = {}
	self.firstCell = true
end

function Field.resize(self, w, h)
	self.speed = math.min(w, h)
	cellSize   = math.min(w, h)/10
	rCorner    = cellSize/8
end

function Field.mousepressed(self, button)
	local x, y = self.selected.x, self.selected.y
	if button == 1 then
		lastClickedCell.x = self.selected.x
		lastClickedCell.y = self.selected.y
		if not self.firstCell then
			if Cell.isNotNil(x, y) then
				if not Cells[x][y].flag then
					Cell.reveal(x, y)
				end
			end
		else
			Cell.new(x, y, false)
			Cell.reveal(x, y)
		end
		if Cell.isRevealed(x, y) then
			if Cells[x][y].bombsAround == Cell.countAround(x, y, "flags") then
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
		if Cell.isNotNil(x, y) and not Cell.isRevealed(x, y)then
			Cells[x][y].flag = not Cells[x][y].flag
		end
		if Cell.isRevealed(x, y) then
			if Cells[x][y].bombsAround == Cell.countAround(x, y, "hidden") then
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

	if Cells[x][y].revealed then return end

	if Cells[x][y].bomb then
		--Field.reset()
		--GM.state = "MainMenu"
		--return
		-- TODO: ultraMegaSuperScaryScreamer()
	end
	Cells[x][y].revealed = true
	Cells[x][y].flag = nil
	local BombsAround = 0
	for dx = -1, 1 do
		for dy = -1, 1 do
			if not Cell.isNotNil(x + dx, y + dy) then
				if dx ~= 0 or dy ~= 0 then
					local isBomb = math.random() < GM.UD.settings.bomb_chance
					if not Field.firstCell then
						Cell.new(x + dx, y + dy, isBomb)
						BombsAround = BombsAround + (isBomb and 1 or 0)
					else
						Cell.new(x + dx, y + dy, false)
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
	Cells[x][y].bombsAround = BombsAround
	local radius = 43 -- Was guessed by many tests. This value is optimal
	local inRadius = math.sqrt((x - lastClickedCell.x)^2 + (y - lastClickedCell.y)^2) <= radius
	if BombsAround == 0 and inRadius then
		Cell.reveal(x - 1, y - 1)
		Cell.reveal(x - 1, y    )
		Cell.reveal(x - 1, y + 1)
		Cell.reveal(x    , y + 1)
		Cell.reveal(x    , y - 1)
		Cell.reveal(x + 1, y - 1)
		Cell.reveal(x + 1, y    )
		Cell.reveal(x + 1, y + 1)
	end
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
	self.flag      = false
	self.mines     = 0
	self.bomb      = isBomb
	self.bombImage = isBomb and math.random(0, #sprites.bombs.quad) or nil
	self.revealed  = false
	Cells[x][y] = self
end

function Cell.isNotNil(x, y)
	return (Cells[x] ~= nil) and (Cells[x][y] ~= nil)
end

function Cell.isRevealed(x, y)
	return Cell.isNotNil(x, y) and Cells[x][y].revealed
end

function Field.draw(self, GM)
	lg.push()
	  lg.translate(GM.width/2, GM.height/2)
	  lg.scale(self.zoom, self.zoom)
	  lg.translate(self.pos.x, self.pos.y)

	local LTCorX, LTCorY = love.graphics.inverseTransformPoint(0, 0)
	local RBCorX, RBCorY = love.graphics.inverseTransformPoint(GM.width, GM.height)
	LTCorX, LTCorY = math.floor(LTCorX / cellSize), math.floor(LTCorY / cellSize)
	RBCorX, RBCorY = math.floor(RBCorX / cellSize), math.floor(RBCorY / cellSize)
	for x = LTCorX, RBCorX do for y = LTCorY, RBCorY do

		lg.setLineWidth(rCorner)

		-- Draw cell base
		palette.cellInner:apply()
		lg.rectangle("fill", x * cellSize, y * cellSize, cellSize, cellSize, rCorner, rCorner, 1)
		palette.cellFrame:apply()
		lg.rectangle("line", x * cellSize, y * cellSize, cellSize, cellSize, rCorner, rCorner, 1)

		if self.selected.x == x and self.selected.y == y and not Cell.isRevealed(x, y) then
			-- Draw selection
			palette.cellSelectedInner:where {
				a = palette.cellSelectedInner.a + 0.05 * math.cos(love.timer.getTime() * math.pi)
			}:apply()
			lg.rectangle("fill", x * cellSize + rCorner/2, y * cellSize + rCorner/2, cellSize - rCorner, cellSize - rCorner, rCorner / 2)
			palette.cellSelectedFrame:apply()
			lg.rectangle("line", x * cellSize, y * cellSize, cellSize, cellSize, rCorner, rCorner)
		end

		-- On these kind of cells we can't have flags, bomb images or numbers anyway
		if not Cell.isNotNil(x, y) then goto continue end

		if Cells[x][y].flag then
			lg.setColor(1, 1, 1)
			lg.draw(sprites.flag.image,
			        x * cellSize,
			        y * cellSize,
			        0, sprites.flag.scaleFactor)
			goto continue
		end

		if Cell.isRevealed(x, y) then
			palette.cellRevealed:apply()
			lg.rectangle("fill",
			             x * cellSize + rCorner/2,
			             y * cellSize + rCorner/2,
			             cellSize - rCorner,
			             cellSize - rCorner,
			             rCorner / 2)

			lg.setColor(1, 1, 1)
			if Cells[x][y].bomb then
				lg.draw(sprites.bombs.image, sprites.bombs.quad[Cells[x][y].bombImage],
				        x * cellSize + rCorner/2,
				        y * cellSize + rCorner/2,
				        0, sprites.bombs.scaleFactor - rCorner/200)
			elseif Cells[x][y].bombsAround > 0 then
				lg.draw(sprites.numbers.image, sprites.numbers.quad[Cells[x][y].bombsAround],
				        x * cellSize + rCorner/2,
				        y * cellSize + rCorner/2,
				        0, sprites.numbers.scaleFactor - rCorner/100)
			end
		end

		::continue::
	end end
	lg.pop()
end

return Field
