local sprites = { numbers  = { image       = nil,
                               scaleFactor = nil,
                               quad        = {} },

                  bombs    = { image       = nil,
                               scaleFactor = nil,
                               quad        = {} },

                  flag     = { image       = nil,
                               scaleFactor = nil },

                  hearts   = { image       = nil,
                               scaleFactor = nil,
                               quad        = {} }}

local lg = love.graphics

function sprites.init(self, GM)
	self.numbers.image = lg.newImage("assets/images/numbers.png")
	self.bombs.image   = lg.newImage("assets/images/bombs.png"  )
	self.flag.image    = lg.newImage("assets/images/flag.png"   )
	self.hearts.image  = lg.newImage("assets/images/hearts.png" )

	self:refresh(GM.width, GM.height)
end

function sprites.refresh(self, w, h)
	self.numbers.scaleFactor = math.min(w, h)/(10 * 100)
	self.bombs.scaleFactor   = math.min(w, h)/(10 * 200)
	self.flag.scaleFactor    = math.min(w, h)/(10 * 200)
	self.hearts.scaleFactor  = math.min(w, h)/(5  * 512)

	-- Quads for numbers
	for y = 0, 1 do
		for x = 0, 6 do
			self.numbers.quad[x + 1 + y * 7] = lg.newQuad(100 * x, 100 * y, 100, 100, self.numbers.image)
		end
	end
	-- Quads for bombs
	for y = 0, 1 do
		for x = 0, 4 do
			self.bombs.quad[x + y * 5] = lg.newQuad(200 * x, 200 * y, 200, 200, self.bombs.image)
		end
	end
	-- Quads for hearts
	self.hearts.quad["full"  ] = lg.newQuad(  0, 0, 512, 512, self.hearts.image)
	self.hearts.quad["hollow"] = lg.newQuad(512, 0, 512, 512, self.hearts.image)
end

return sprites
