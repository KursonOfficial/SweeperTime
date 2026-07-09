local UD = {}

local DEFAULT_SETTINGS = {
	--[[
		15% default, but little silly Kurson whants BIGGER.
		But suddenly, this is predestined by fate, and nobody
		can chaange it.
	]]
	fullscreen  = true,
	theme       = "Ocean",
	bomb_chance = 15/100,
}

local DEFAULD_USER_DATA = {
	settings = DEFAULT_SETTINGS,
	-- stats.maxScore = 0
	-- maingame_state.lives = 3
	-- ...
}

UD.new = function()
	return setmetatable(DEFAULD_USER_DATA, { __index = UD })
end

UD.save = function(self)
	-- TODO: Serealise and write save file to userdata folder
	assert(false, "Not yet implemented user data saving")
end

UD.load = function(self)
	local save_file_exists = false -- TODO: actually check it
	-- Read user's save file from disc and dispatch
	-- all properties accordingly
	if save_file_exists then
		-- TODO: load save file
		assert(false, "Not yet implemented save file loading")
	end
end

UD.apply = function(self)
	love.window.setFullscreen(self.settings.fullscreen)
	GM.width, GM.height = love.graphics.getDimensions()
	UI.refreshFonts()
	setTheme(self.settings.theme)
end

return UD.new()
