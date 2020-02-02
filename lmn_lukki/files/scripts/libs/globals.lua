
dofile_once("mods/lmn_lukki/files/scripts/libs/private_globals.lua")
dofile_once("mods/lmn_lukki/files/scripts/libs/objectify.lua")

lmn = lmn or {}
lmn.prefix = "lmn_lukki_"
local globals = private_globals(lmn.prefix)

local list = {
	CharacterPlatformingComponent = {
		"accel_x",
		"pixel_gravity",
		"swim_idle_buoyancy_coeff",
		"swim_down_buoyancy_coeff",
		"swim_up_buoyancy_coeff",
		"swim_drag",
		"swim_extra_horizontal_drag",
		meta = {
			"run_velocity",
			"fly_velocity_x",
			"velocity_min_x",
			"velocity_max_x",
			"velocity_min_y",
			"velocity_max_y",
		}
	}
}

lmn.globals = lmn.globals or {}

-- component values = global values
function lmn.globals.apply(entity)
	local obj = objectify_entity(entity)
	
	for component, values in pairs(list) do
		for kind, value in pairs(values) do
			if type(value) == 'table' then
				for _, value in ipairs(value) do
					obj[component][kind][value] = globals[value]
				end
			else
				obj[component][value] = globals[value]
			end
		end
	end
end

-- global values = component values
function lmn.globals.update(entity)
	local obj = objectify_entity(entity)
	
	for component, values in pairs(list) do
		for kind, value in pairs(values) do
			if type(value) == 'table' then
				for _, value in ipairs(value) do
					globals[value] = obj[component][kind][value]
				end
			else
				globals[value] = obj[component][value]
			end
		end
	end
	
	globals.globals_changed = true
end
