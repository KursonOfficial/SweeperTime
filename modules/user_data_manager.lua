local default_user_settings = {
	--[[
		15% default, but little silly Kurson whants BIGGER.
		But suddenly, this is predestined by fate, and nobody
		can chaange it.
	]]
	fullscreen  = true,
	theme       = "Ocean",
	bomb_chance = 15/100,
}
local default_UD = {
	settings = default_user_settings,
	-- stats.maxScore = 0
	-- maingame_state.lives = 3
	-- ...
}

local module = {
	save = function()
		-- TODO: Serealise and write save file to userdata folder
		assert(false, "Not yet implemented user data saving")
	end;
	load = function(need_reset)
		local need_reset = need_reset or false
		local save_file_exists = false -- TODO: actually check it
		
		-- Read user's save file from disc and dispatch
		-- all properties accordingly
		if save_file_exists and (not need_reset) then
			-- TODO: load save file
			assert(false, "Not yet implemented save file loading")
		else
			-- We don' have any saves, load default values and create one
			GM.UD = default_UD
			-- self.save()
		end
	end;
	apply = function()
		local ss = GM.UD.settings

		love.window.setFullscreen(ss.fullscreen)
		GM.Widht, GM.Height = love.graphics.getDimensions()
		UI.refreshFonts()
		setTheme(ss.theme)
	end;
}
return module

