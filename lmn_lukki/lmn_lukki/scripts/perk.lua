
dofile_once("mods/lmn_lukki/lmn_lukki/scripts/libs/globals.lua")
dofile_once("mods/lmn_lukki/lmn_lukki/scripts/libs/objectify.lua")

local globals = private_globals(lmn.prefix)
--local count = 0

local old_perk_pickup = perk_pickup
function perk_pickup(entity_item, entity_who_picked, ...)
	
	local picker = objectify_entity(entity_who_picked)
	local item = objectify_entity(entity_item)
	local id = item.VariableStorageComponent.value_string
	
	if GameHasFlagRun("PERK_PICKED_ATTACK_FOOT") then
		lmn.globals.apply(entity_who_picked)
	end
	
	local result = old_perk_pickup(entity_item, entity_who_picked, ...)
	
	if GameHasFlagRun("PERK_PICKED_ATTACK_FOOT") then
		lmn.globals.update(entity_who_picked)
		
		picker.CharacterPlatformingComponent.jump_velocity_y = 0
		picker.CharacterPlatformingComponent.jump_velocity_x = 0
	end
	
	-- testing compatibility with other perks
	--[[
	local x, y = EntityGetTransform(entity_who_picked)
	
	if count == 0 then
		perk_spawn(x, y, "BREATH_UNDERWATER")
		count = 1
	elseif count == 1 then
		perk_spawn(x, y, "SPEED_DIVER")
		count = 2
	else
		perk_spawn(x, y, "MOVEMENT_FASTER")
	end]]
	
	return result
end