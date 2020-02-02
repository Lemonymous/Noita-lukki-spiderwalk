
lmn = lmn or {}

local player_entity = GetUpdatedEntityID()
if not player_entity then return end

dofile_once("mods/lmn_lukki/files/config.lua")
dofile_once("mods/lmn_lukki/files/scripts/libs/utils.lua")
dofile_once("mods/lmn_lukki/files/scripts/libs/private_globals.lua")
dofile_once("mods/lmn_lukki/files/scripts/libs/vector2.lua")
dofile_once("mods/lmn_lukki/files/scripts/libs/objectify.lua")
dofile_once("mods/lmn_lukki/files/scripts/libs/globals.lua")

local config = lmn.config
local prefix = lmn.prefix
local globals = private_globals(prefix)
local player = objectify_entity(player_entity)
local controls = player.ControlsComponent
local chardata = player.CharacterDataComponent
local platforming = player.CharacterPlatformingComponent
local limbs = {attached = 0}

platforming.jump_velocity_y = 0
platforming.jump_velocity_x = 0

local children = EntityGetAllChildren(player_entity)
for _, child in ipairs(children) do
	child = objectify_entity(child)
	local ikwalker = child.IKLimbWalkerComponent
	local iklimb = child.IKLimbComponent
	local limb = {ikwalker = ikwalker, iklimb = iklimb}
	
	if limb.ikwalker and limb.iklimb then
		local attached = tobool(ikwalker.mState)
		
		limbs[#limbs+1] = {
			ikwalker = ikwalker,
			iklimb = iklimb,
			sprites = child.SpriteComponent,
			attached = attached
		}
		
		if attached then
			limbs.attached = limbs.attached + 1
			
			ikwalker.ground_attachment_ray_length_coeff = 1.15
			ikwalker.leg_velocity_coeff = 15
		else
			-- slow down limbs when they are not attached
			ikwalker.ground_attachment_ray_length_coeff = 1.00
			ikwalker.leg_velocity_coeff = 2
		end
	end
end

local function setInvisible(flag)
	local alpha = flag and .2 or 1
	
	for _, limb in ipairs(limbs) do
		for _, sprite in ipairs(limb.sprites) do
			sprite.alpha = alpha
		end
	end
end

local loc = vector2(EntityGetTransform(player_entity))
local limb_req_for_max_grip = #limbs / 2

local pixel_gravity = tonumber(globals.pixel_gravity)
local climb_gravity = config.climb_acceleration
local swim_idle_buoyancy_coeff = tonumber(globals.swim_idle_buoyancy_coeff)
local swim_up_buoyancy_coeff = tonumber(globals.swim_up_buoyancy_coeff)
local swim_down_buoyancy_coeff = tonumber(globals.swim_down_buoyancy_coeff)
local swim_drag = tonumber(globals.swim_drag)
local swim_extra_horizontal_drag = tonumber(globals.swim_extra_horizontal_drag)

local isUpPressed = tobool(controls.mButtonDownUp)
local isDownPressed = tobool(controls.mButtonDownDown)
local isLeftPressed = tobool(controls.mButtonDownLeft)
local isRightPressed = tobool(controls.mButtonDownRight)

-- swim: [false, true]
local wasSwim = lmn.isSwim
lmn.isSwim = tobool(platforming.mFramesSwimming)
local swim_changed = lmn.isSwim ~= wasSwim

-- oiled: [false, true]
local wasOiled = lmn.isOiled
lmn.isOiled = not tobool(GameGetGameEffectCount(player_entity, "OILED"))
local oiled_changed = lmn.isOiled ~= wasOiled

-- invisible: [false, true]
local wasInvisible = lmn.isInvisible
local effect = GameGetGameEffect(player_entity, "INVISIBILITY")
lmn.isInvisible = effect and tobool(ComponentGetValue(effect, "mInvisible")) or false
local invisible_changed = lmn.isInvisible ~= wasInvisible

-- unattached: [false, true] - boolean for whether any legs are touching terrain.
local prev_unattached = lmn_unattached
lmn.unattached = limbs.attached == 0
local unattached_changed = lmn.unattached ~= prev_unattached

-- grip: [0.0, 1.0] - gradient for how good grip we have on terrain.
local prev_grip = lmn.grip
lmn.grip = math.min(limbs.attached, limb_req_for_max_grip) / limb_req_for_max_grip
local grip_changed = lmn.grip ~= prev_grip

if tobool(globals.globals_changed) then
	-- update everything if globals has been changed.
	swim_changed = true
	oiled_changed = true
	invisible_changed = true
	unattached_changed = true
	grip_changed = true
	
	globals.globals_changed = false
end

if oiled_changed then
	if lmn.isOiled then
		if config.ignores_oil_slippyness then
			platforming.accel_x = 1.0
		else
			local accel_x = globals.accel_x or 0.15
			platforming.accel_x = accel_x
			climb_gravity = 100
		end
	else
		local accel_x = globals.accel_x or 0.15
		platforming.accel_x = accel_x
	end
end

if invisible_changed then
	if lmn.isInvisible then
		setInvisible(true)
	else
		setInvisible(false)
	end
end

local speed_fx_mul = MagicNumbersGetValue('GAMEEFFECT_MOVEMENT_FASTER_SPEED_MULTIPLIER')
local speed_fx_count = GameGetGameEffectCount(player_entity, "MOVEMENT_FASTER")
local speed_multiplier = speed_fx_mul ^ speed_fx_count

chardata.flying_needs_recharge = 1
chardata.fly_time_max = 0

if lmn.grip == 0 or lmn.isSwim then
	platforming.pixel_gravity = pixel_gravity
end

if lmn.grip > 0 then
	-- "being on ground" changes animation to walk instead of fly.
	-- however, what we need it for is to avoid being stunned while we are attached with our limbs.
	chardata.is_on_ground = 1
else
	chardata.is_on_ground = 0
end

if lmn.isSwim then
	-- lack of flying makes swimming very difficult.
	-- change around values to always allow swimming up and down,
	-- and add some limited climbing along walls underwater as well.
	if swim_changed or unattached_changed then
		
		swim_up_delta = 1 - swim_up_buoyancy_coeff
		swim_down_delta = 1 - swim_down_buoyancy_coeff
		
		if swim_up_delta < 0 then
			swim_up_delta = -swim_up_delta
		end
		
		if swim_down_delta < 0 then
			swim_down_delta = -swim_down_delta
		end
		
		-- nudge swim values to counteract lack of fly
		swim_idle_buoyancy_coeff = swim_idle_buoyancy_coeff - 0.3
		swim_up_buoyancy_coeff = 1 + swim_up_delta + 0.3
		swim_down_buoyancy_coeff = 1 - swim_down_delta - 0.3
		
		if lmn.grip > 0 then
			platforming.swim_idle_buoyancy_coeff = 1.0
			platforming.swim_up_buoyancy_coeff = math.min(2, swim_up_buoyancy_coeff + 0.2 * speed_multiplier)
			platforming.swim_down_buoyancy_coeff = math.max(0, swim_down_buoyancy_coeff - 0.3 * speed_multiplier)
			platforming.swim_drag = math.min(0.95, swim_drag)
			platforming.swim_extra_horizontal_drag = math.min(0.95, swim_extra_horizontal_drag)
		else
			platforming.swim_idle_buoyancy_coeff = swim_idle_buoyancy_coeff
			platforming.swim_up_buoyancy_coeff = math.min(2, swim_up_buoyancy_coeff)
			platforming.swim_down_buoyancy_coeff = math.max(0, swim_down_buoyancy_coeff)
			platforming.swim_drag = swim_drag
			platforming.swim_extra_horizontal_drag = swim_extra_horizontal_drag
		end
	end
else
	if lmn.grip > 0 then
		local adjust_gravity = 0
		
		-- if feet aren't actually touching ground, climbing y elevation is not automatic.
		-- additional code to more easily climb y to compensate.
		if isLeftPressed then
			local feet_hit = Raytrace(loc.x, loc.y+2, loc.x-4, loc.y+2)
			
			if feet_hit then
				local body_hit = Raytrace(loc.x, loc.y-2, loc.x-4, loc.y-2)
				
				if not body_hit then
					adjust_gravity = -pixel_gravity
				end
			end
			
		elseif isRightPressed then
			local feet_hit = Raytrace(loc.x, loc.y+2, loc.x+4, loc.y+2)
			
			if feet_hit then
				local body_hit = Raytrace(loc.x, loc.y-2, loc.x+4, loc.y-2)
				
				if not body_hit then
					adjust_gravity = -pixel_gravity
				end
			end
		end
		
		if isDownPressed then
			platforming.pixel_gravity = climb_gravity + adjust_gravity
		elseif isUpPressed then
			platforming.pixel_gravity = -climb_gravity + adjust_gravity
		else
			local _, vel_y = GameGetVelocityCompVelocity(player_entity)
			local gravity = -vel_y * lmn.grip * climb_gravity + (1-lmn.grip) * pixel_gravity
			
			platforming.pixel_gravity = gravity + adjust_gravity
		end
	end
end

if swim_changed or grip_changed then
	if lmn.isSwim and lmn.grip == 0 then
		platforming.meta.fly_velocity_x = globals.fly_velocity_x
		platforming.meta.run_velocity = globals.run_velocity
		platforming.meta.velocity_min_x = globals.velocity_min_x
		platforming.meta.velocity_max_x = globals.velocity_max_x
		platforming.meta.velocity_min_y = globals.velocity_min_y
		platforming.meta.velocity_max_y = globals.velocity_max_y
	else
		local perk_count = tonumber(globals.perk_count) or 1
		-- multiplier: [1.0, velocity_max_multiplier_at_full_grip]
		local mul = config.velocity_max_multiplier_at_full_grip + config.stack_perk.velocity_max_multiplier_at_full_grip * (perk_count - 1)
		mul = 1 + math.max(0, (lmn.grip * (mul - 1)))
		
		local vmax = globals.fly_velocity_x * mul
		
		platforming.meta.fly_velocity_x = vmax
		platforming.meta.run_velocity = globals.run_velocity * mul
		platforming.meta.velocity_min_x = -vmax
		platforming.meta.velocity_max_x = vmax
		
		platforming.meta.velocity_min_y = lmn.grip * -vmax * speed_multiplier + (1-lmn.grip) * globals.velocity_min_y
		platforming.meta.velocity_max_y = lmn.grip * vmax * speed_multiplier + (1-lmn.grip) * globals.velocity_max_y
	end
end
