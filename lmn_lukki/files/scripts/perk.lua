
dofile_once("mods/lmn_lukki/files/scripts/libs/globals.lua")
dofile_once("mods/lmn_lukki/files/scripts/libs/objectify.lua")

local globals = private_globals(lmn.prefix)

local old_perk_pickup = perk_pickup
function perk_pickup(entity_item, entity_who_picked, ...)
	
	if GameHasFlagRun("PERK_PICKED_ATTACK_FOOT") then
		lmn.globals.apply(entity_who_picked)
	end
	
	local result = old_perk_pickup(entity_item, entity_who_picked, ...)
	
	if GameHasFlagRun("PERK_PICKED_ATTACK_FOOT") then
		lmn.globals.update(entity_who_picked)
	end
	
	-- testing compatibility with other perks
	--[[
	local x, y = EntityGetTransform(entity_who_picked)
	
	perk_spawn(x - 20,  y, "MOVEMENT_FASTER")
	perk_spawn(x - 0,   y, "ATTACK_FOOT")
	perk_spawn(x + 20,  y, "BREATH_UNDERWATER")
	perk_spawn(x + 40, y, "SPEED_DIVER")
	--]]
	
	return result
end