getColorHS = function(hexString)
	local color = {}

	-- Exluding '#' from the start of the string
	color.r = tonumber(string.sub(hexString, 2, 3), 16)/255
	color.g = tonumber(string.sub(hexString, 4, 5), 16)/255
	color.b = tonumber(string.sub(hexString, 6, 7), 16)/255
	color.a = tonumber(string.sub(hexString, 8, 9), 16)/255

	return color
end
getColorNV = function(nVr, nVg, nVb, nVa)
	local color = {}

	color.r = nVr
	color.g = nVg
	color.b = nVb
	color.a = nVa

	return color
end
getColorHL = function(hexLitteral)
	local color = {}
	-- Have to comment out part that is for Lua because LOVE
	-- do not want to run the game without parsing this part
	-- of a code that is for Lua and not Luajit
	--[[ case Lua
		-- We are on lua, everything is ok
		color.r = ((hexLitteral >> 24) & 0xFF)/255
		color.g = ((hexLitteral >> 16) & 0xFF)/255
		color.b = ((hexLitteral >> 8 ) & 0xFF)/255
		color.a = ( hexLitteral        & 0xFF)/255
	]]-- case Luajit
		-- We are on luajit that dont have normal syntax
		-- but have a bit.* functions.
		-- ("band" stands for "binary and" btw)
		color.r = bit.band(bit.rshift(hexLitteral, 24), 0xFF)/255
		color.g = bit.band(bit.rshift(hexLitteral, 16), 0xFF)/255
		color.b = bit.band(bit.rshift(hexLitteral,  8), 0xFF)/255
		color.a = bit.band(           hexLitteral     , 0xFF)/255
		
	--

	return color
end
cup = function(color) -- Color unpack
	return color.r, color.g, color.b, color.a
end

palette = {
	logoFront    = getColorHS("#CCCCFFFF");
	hint         = getColorHS("#4C527FFF");
	versionText  = getColorHS("#333333FF");
	debugInfo    = getColorNV(0, 0, 0, 1);
	cellInner    = getColorHS("#333333FF");
	cellRevealed = getColorHS("#FFFFFF22");
	cellFrame    = getColorHS("#FFFFFF33");
	cellSelectedInner = getColorHS("#4C4C47FF");
	cellSelectedFrame = getColorHS("#FFFFF233");
}
