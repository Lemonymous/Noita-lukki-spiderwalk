
local path_lukki_update = "mods/lmn_lukki/files/scripts/update.lua"
dofile_once("mods/lmn_lukki/files/config.lua")
dofile_once("mods/lmn_lukki/files/scripts/libs/globals.lua")
dofile_once("mods/lmn_lukki/files/scripts/libs/objectify.lua")
dofile_once("mods/lmn_lukki/files/scripts/libs/private_globals.lua")

for _, perk in ipairs(perk_list) do
	if perk.id == "ATTACK_FOOT" then
		perk.ui_description = "You grow nimble spiderlegs, but lose flight!"
		perk.func = function(entity_perk_item, entity_who_picked, item_name)
			
			local player = objectify_entity(entity_who_picked)
			local x, y = EntityGetTransform(entity_who_picked)
			local chardata = player.CharacterDataComponent
			
			local globals = private_globals(lmn.prefix)
			local prefix = lmn.prefix
			local config = lmn.config
			
			lmn.globals.update(entity_who_picked)
			
			local perk_count = globals.perk_count or 0
			globals.perk_count = perk_count + 1
			
			local base = config.limb_count
			local stack_add = config.stack_perk.limbs_count_add
			local count_max = config.stack_perk.limbs_count_max
			
			local limb_count = base + perk_count * stack_add
			limb_count = math.min(limb_count, count_max)
			limb_count = math.max(limb_count, base)
			limb_count = math.max(limb_count, 1)
			
			local limb_length
			local multiplier = config.stack_perk.limb_length_multiplier
			
			if multiplier == 1 then
				limb_length = config.limb_length * (1 + perk_count)
			else
				local base = config.limb_length
				local stack_mul = multiplier ^ perk_count
				
				limb_length = stack_mul * base + (1-stack_mul) * base / (1-multiplier)
			end
			
			limb_length = limb_length - math.floor(limb_count / 2)
			limb_length = math.max(1, limb_length)
			
			chardata.climb_over_y = 5
			
			-- get existing limbs
			local limbs = {}
			
			if config.enable_leg_attacks and #limbs == 0 then
				limb_attacker = EntityLoad( "data/entities/misc/perks/attack_foot/limb_attacker.xml", x, y )
				EntityAddChild(entity_who_picked, limb_attacker)
			end
			
			local children = EntityGetAllChildren(entity_who_picked)
			for _, child in ipairs(children) do
				local name = EntityGetName(child)
				if name == prefix .."limb" then
					limbs[#limbs+1] =
					{
						obj = objectify_entity(child),
						length = limb_length
					}
					
					limb_length = limb_length + 1
				end
			end
			
			-- if not enough limbs, add more
			if #limbs < limb_count then
				
				for i = #limbs + 1, limb_count do
					local limb = EntityLoad("data/entities/misc/perks/attack_foot/limb_walker.xml", x, y)
					EntitySetName(limb, prefix .."limb")
					EntityAddChild(entity_who_picked, limb)
					
					limbs[i] = {
						obj = objectify_entity(limb),
						length = limb_length
					}
					
					limb_length = limb_length + 1
				end
			end
			
			-- adjust values for limb components
			for _, limb in ipairs(limbs) do
				local obj = objectify_entity(limb.entity)
				local iklimb = limb.obj.IKLimbComponent
				local ikwalker = limb.obj.IKLimbWalkerComponent
				
				if ikwalker then
					ikwalker.ground_attachment_max_tries = 15
					ikwalker.ground_attachment_max_angle = 1.0
				end
				
				if iklimb then
					iklimb.length = limb.length
					iklimb.thigh_extra_lenght = 0
				end
			end
			
			EntityAddComponent(entity_who_picked, "LuaComponent", {
				script_source_file = path_lukki_update,
				execute_every_n_frame = "1",
			})
		end
	end
end