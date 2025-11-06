
sprite = {numbers = {},
		  bombs   = {},
		  flag    = {},
		  hearts  = {}}

function sprite.init()
	sprite.flag.image    = love.graphics.newImage("assets/images/flag.png"   )
	sprite.numbers.image = love.graphics.newImage("assets/images/numbers.png")
	sprite.bombs.image   = love.graphics.newImage("assets/images/bombs.png"  )
	sprite.hearts.image  = love.graphics.newImage("assets/images/hearts.png" )

	sprite.quads()
end

function sprite.quads()
	sprite.flag.scaleFactor    = GM.Height/(10 * 200)
	sprite.numbers.scaleFactor = GM.Height/(10 * 100)
	sprite.bombs.scaleFactor   = GM.Height/(10 * 200)
	sprite.hearts.scaleFactor  = GM.Height/(5  * 512)

	sprite.numbers.quad = {}
	sprite.bombs.quad   = {}
	sprite.hearts.quad  = {}

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
