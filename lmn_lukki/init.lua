
ModLuaFileAppend("data/scripts/perks/perk_list.lua", "mods/lmn_lukki/files/scripts/perk_list.lua")
ModLuaFileAppend("data/scripts/perks/perk.lua", "mods/lmn_lukki/files/scripts/perk.lua")
dofile_once( "mods/lmn_lukki/files/scripts/libs/globals.lua" )
dofile_once("mods/lmn_lukki/files/config.lua")

function OnPlayerSpawned(player)
	if not GameHasFlagRun("lmn_lukki_init") then
		GameAddFlagRun("lmn_lukki_init")
		
		-- spawn perk
		dofile_once("data/scripts/perks/perk.lua")
		
		lmn.globals.update(player)
		
		if lmn.config.spawn_perk_at_new_game then
			local x, y = EntityGetTransform( player )
			perk_spawn(x, y, "ATTACK_FOOT")
		end
		
		
		-- testing compatibility with some effects
		--[[
		for i = 1, 10 do
			EntityLoad( "data/entities/items/pickup/potion.xml", 400 + Random(-100, 100), -100 + Random(-10, 10) )
		end
		--]]
		
		-- testing compatibility with water
		--[[
		local x, y = EntityGetTransform( player )
		x = x + 2200
		EntitySetTransform(player, x, y)
		perk_spawn(x, y, "ATTACK_FOOT")
		--]]
	end
end