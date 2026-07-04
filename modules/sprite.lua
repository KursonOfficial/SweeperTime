sprite = { numbers  = { image       = nil,
                        scaleFactor = nil,
                        quad        = {} },

           bombs    = { image       = nil,
                        scaleFactor = nil,
                        quad        = {} },

           flag     = { image       = nil,
                        scaleFactor = nil,
                        quad        = {} },

           hearts   = { image       = nil,
                        scaleFactor = nil,
                        quad        = {} }}

local lg = love.graphics

function sprite.init()
	sprite.numbers.image = love.graphics.newImage("assets/images/numbers.png")
	sprite.bombs.image   = love.graphics.newImage("assets/images/bombs.png"  )
	sprite.flag.image    = love.graphics.newImage("assets/images/flag.png"   )
	sprite.hearts.image  = love.graphics.newImage("assets/images/hearts.png" )

	sprite.quads()
end

function sprite.quads()
	sprite.numbers.scaleFactor = GM.height/(10 * 100)
	sprite.bombs.scaleFactor   = GM.height/(10 * 200)
	sprite.flag.scaleFactor    = GM.height/(10 * 200)
	sprite.hearts.scaleFactor  = GM.height/(5  * 512)

	--quads for numbers
	for y = 0 , 1 do
		for x = 0, 6 do
			sprite.numbers.quad[x + 1 + y * 7] = lg.newQuad(100 * x, 100 * y, 100, 100, sprite.numbers.image)
		end
	end
	--quads for bombs
	for y = 0 , 1 do
		for x = 0, 4 do
			sprite.bombs.quad[x + y * 5] = lg.newQuad(200 * x, 200 * y, 200, 200, sprite.bombs.image)
		end
	end
	--quads for hearts
	sprite.hearts.quad["full"  ] = lg.newQuad(  0, 0, 512, 512, sprite.hearts.image)
	sprite.hearts.quad["hollow"] = lg.newQuad(512, 0, 512, 512, sprite.hearts.image)
end

