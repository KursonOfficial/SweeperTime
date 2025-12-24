local lg = love.graphics
Vector2 = {
	new = function(_x, _y)
		return setmetatable({x = _x, y = _y}, self)
	end,
	__index = {
		x = 0,
		y = 0,
	},
}
Rec = {
	new = function(_x, _y, _w, _h)
		return setmetatable({x = _x, y = _y, w = _w, h = _h}, self)
	end,
	__index = {
		x = 0,
		y = 0,
		w = 0,
		h = 0,
	},
}
function drawRec(mode, rec)
	lg.rectangle(mode, rec.x, rec.y, rec.w, rec.h)
end
function checkCollisionPointRec(point, rec)
	local collision = false
	if (point.x >= rec.x)          and
	   (point.x < (rec.x + rec.w)) and
	   (point.y >= rec.y)          and
	   (point.y < (rec.y + rec.h)) then
	   collision = true
	end
	return collision
end
function clamp(t, min, max) return math.max(min, math.min(max, t)) end
function trunk(x, n) return x - (x % 10^(-n)) end
function round(number) return number >= 0 and math.floor(number + 0.5) or math.ceil(number - 0.5) end
function lerp(a, b, t) return a + (b - a)*t end

