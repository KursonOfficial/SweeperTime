_G.Color = { r = 0, g = 0, b = 0, a = 0, }

Color.newHS = function(hexString)
	local color = {}

	-- Exluding '#' from the start of the string
	color.r = tonumber(string.sub(hexString, 2, 3), 16)/255
	color.g = tonumber(string.sub(hexString, 4, 5), 16)/255
	color.b = tonumber(string.sub(hexString, 6, 7), 16)/255
	color.a = tonumber(string.sub(hexString, 8, 9), 16)/255

	return setmetatable(color, { __index = Color })
end

Color.newNV = function(nVr, nVg, nVb, nVa)
	local color = {}

	color.r = nVr
	color.g = nVg
	color.b = nVb
	color.a = nVa

	return setmetatable(color, { __index = Color })
end

Color.newHL = function(hexLitteral)
	local color = {}

	color.r = bit.band(bit.rshift(hexLitteral, 24), 0xFF)/255
	color.g = bit.band(bit.rshift(hexLitteral, 16), 0xFF)/255
	color.b = bit.band(bit.rshift(hexLitteral,  8), 0xFF)/255
	color.a = bit.band(           hexLitteral     , 0xFF)/255

	return setmetatable(color, { __index = Color })
end

Color.newHSV = function(h, s, v, a)
	local color = Color.newNV(0, 0, 0, a)
	local k, t

	k = (5 + h/60) % 6
	t = 4 - k
	k = math.min(t, k)
	k = clamp(k, 0, 1)
	color.r = v - v*s*k

	k = (3 + h/60) % 6
	t = 4 - k
	k = math.min(t, k)
	k = clamp(k, 0, 1)
	color.g = v - v*s*k

	k = (1 + h/60) % 6
	t = 4 - k
	k = math.min(t, k)
	k = clamp(k, 0, 1)
	color.b = v - v*s*k

	return color
end

Color.spill = function(self)
	return self.r, self.g, self.b, self.a
end

Color.apply = function(self)
	love.graphics.setColor(self.r, self.g, self.b, self.a)
end

Color.where = function(self, opts)
	for k, _ in pairs(opts) do
		assert(self[k], string.format("Caught an attemp of using `where` method to reasign a non-existing field `%s` of class `Color`. Probably a just a typo.", k))
	end
	return setmetatable(opts, { __index = self })
end

Color.blend = function(self, color, t)
	return setmetatable({
		r = lerp(self.r, color.r, t),
		g = lerp(self.g, color.g, t),
		b = lerp(self.b, color.b, t),
		a = lerp(self.a, color.a, t)
	}, { __index = Color })
end

-- Theme list:
local themes = {
	["Theme Zero"] = {
		logoFront    = Color.newHS("#CCCCFFFF");
		versionText  = Color.newHS("#333333FF");
		debugInfo    = Color.newNV(0, 0, 0, 1);
		cellInner    = Color.newHS("#333333FF");
		cellRevealed = Color.newHS("#FFFFFF22");
		cellFrame    = Color.newHS("#FFFFFF33");
		cellSelectedInner = Color.newHS("#4C4C47FF");
		cellSelectedFrame = Color.newHS("#FFFFF233");
	},
	["Ocean"] = {
		logoFront    = Color.newHS("#CCCCFFFF");
		versionText  = Color.newHS("#333333FF");
		debugInfo    = Color.newHL(0x5DfDCDFF);
		cellInner    = Color.newHS("#04151FFF");
		cellRevealed = Color.newHS("#66999B44");
		cellFrame    = Color.newHS("#6E889488");
		cellSelectedInner = Color.newHS("#85BAA1CC");
		cellSelectedFrame = Color.newHS("#FFFFF233");
	},
	["Coffee"] = {
		logoFront    = Color.newHS("#CCCCFFFF");
		versionText  = Color.newHS("#333333FF");
		debugInfo    = Color.newHS("#8EC07CFF");
		cellInner    = Color.newHS("#282828FF");
		cellRevealed = Color.newHS("#92837444");
		cellFrame    = Color.newHS("#92837488");
		cellSelectedInner = Color.newHS("#85BAA1FF");
		cellSelectedFrame = Color.newHS("#FFFFF233");
	},
	--[[ Not Ready yet
	["EverForest"] = {
		logoFront    = Color.newHS("#CCCCFFFF");
		versionText  = Color.newHS("#333333FF");
		debugInfo    = Color.newNV(0, 0, 0, 1);
		cellInner    = Color.newHS("#1e2326FF");
		cellRevealed = Color.newHS("#2e383cAA");
		-- cellFrame    = Color.newHS("#4f5b5866");
		cellFrame    = Color.newHS("#a7c08034");
		cellSelectedInner = Color.newHS("#4C4C47FF");
		cellSelectedFrame = Color.newHS("#FFFFF233");
	},]]
}

local DEFAULT_THEME_NAME = "Theme Zero"
local DEFAULT_THEME = themes[DEFAULT_THEME_NAME]

_G.palette = DEFAULT_THEME

setTheme = function(themeName)
	assert(themeName, "theme name is not provided")
	local theme = themes[themeName]
	if not theme then
		print(string.format("WARNING: Theme `%s` not found, using default `%s`", themeName, DEFAULT_THEME_NAME))
		palette = DEFAULT_THEME
		return
	end
	palette = theme
end
