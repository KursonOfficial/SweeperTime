local Palette = {}

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

function Palette.getPaletteByName(themeName)
	assert(themeName, "Theme name is not provided!")
	local colors = themes[themeName]
	if colors then
		return setmetatable(colors, { __index = Palette })
	end

	print(string.format("WARNING: Theme `%s` not found, using default `%s`", themeName, DEFAULT_THEME_NAME))
	return setmetatable(themes[DEFAULT_THEME_NAME], { __index = Palette })
end

return Palette.getPaletteByName(DEFAULT_THEME_NAME)
