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
palette = {
	Gray       = "333333FF";
	LightGray  = "4C4C4CFF";
	CellInner  = "181818FF";
	CellRevealed = "AAFF0022";
	CellFrame  = "4C4C4CFF";
	CellFrame2 = "FFFFFF33";
}