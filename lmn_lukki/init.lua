
-- version 1.3

ModLuaFileAppend("data/scripts/perks/perk_list.lua", "mods/lmn_lukki/lmn_lukki/scripts/perk_list.lua")
ModLuaFileAppend("data/scripts/perks/perk.lua", "mods/lmn_lukki/lmn_lukki/scripts/perk.lua")
dofile_once( "mods/lmn_lukki/lmn_lukki/scripts/libs/globals.lua" )

function OnPlayerSpawned(player)
	if not GameHasFlagRun("lmn_lukki_init") then
		lmn.globals.update(player)
		
		dofile_once("data/scripts/perks/perk.lua")
		
		GameAddFlagRun("lmn_lukki_init")
		
		
		-- spawn perk
		local x, y = EntityGetTransform( player )
		perk_spawn(x, y, "ATTACK_FOOT")
		
		
		-- testing compatibility with some effects
		--for i = 1, 10 do
		--	EntityLoad( "data/entities/items/pickup/potion.xml", 400 + Random(-100, 100), -100 + Random(-10, 10) )
		--end
		
		
		-- testing compatibility with water
		--local x, y = EntityGetTransform( player )
		--x = x + 2200
		--EntitySetTransform(player, x, y)
		--perk_spawn(x, y, "ATTACK_FOOT")
	end
end