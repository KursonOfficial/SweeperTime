H2C = function(HexString, single) -- Hex to Color
	if single then
		return tonumber(HexString, 16)/255
	else
		local r = tonumber(string.sub(HexString, 1, 2), 16)/255
		local g = tonumber(string.sub(HexString, 3, 4), 16)/255
		local b = tonumber(string.sub(HexString, 5, 6), 16)/255
		local a = tonumber(string.sub(HexString, 7, 8), 16)/255
		return r, g, b, a
	end
end

getColor = function(hexValue) --> Color
	local color = {};

	color.r = (hexValue >> 24) & 0xff
	color.g = (hexValue >> 16) & 0xff
	color.b = (hexValue >> 8 ) & 0xff
	color.a =  hexValue        & 0xff

	return table.unpack(color);
end

palette = {
	LogoFront    = "CCCCFFFF";
	Hint         = "4C527FFF";
	VersionText  = "333333FF";
	DebugInfo    = "000000FF";
	CellInner    = "333333FF";
	CellRevealed = "FFFFFF22";
	CellFrame    = "FFFFFF33";
	CellSelectedInner = "4C4C47FF";
	CellSelectedFrame = "FFFFF233";
}