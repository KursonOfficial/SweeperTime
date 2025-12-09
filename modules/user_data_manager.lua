local default_user_settings = {
	--[[
		15% default, but little silly Kurson whants BIGGER.
		But suddenly, this is predestined by fate, and nobody
		can chaange it.
	]]
	BOMB_CHANCE = 15/100,
	FULLSCREEN  = true,
}
local module = {
	loadUserData = function(need_reset)
		local need_reset = need_reset or false
		local save_file_exists = false -- TODO: actually check it
		-- Read user's save file from disc and dispatch
		-- all properties accordingly
		if save_file_exists and (not need_reset) then
			-- TODO: load save file
			assert(false, "Not yet implemented save file loading")
		else
			-- We don' have any saves, load defalt values and create one
			GM.settings = default_user_settings
			-- GM.xxx1 = default_yyy1
			-- GM.xxx2 = default_yyy2
			-- ...
			-- TODO: Serealise and write save file to userdata folder
		end
	end
}
return module
