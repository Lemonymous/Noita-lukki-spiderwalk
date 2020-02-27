
-- CONFIGURATION:
-- tweak these variables however you like.
-- let me know if you need any more.

lmn = lmn or {}
lmn.config = {
	
	-- whether or not you should start with the perk
	spawn_perk_at_new_game = false,
	
	-- whether or not the perk should add the vanilla leg attack
	enable_leg_attacks = false,
	
	-- not sure if the following option still works or not
	ignores_oil_slippyness = false,
	
	-- speed multiplier when enough legs are touching
	velocity_multiplier_at_full_grip = 1.50,
	
	-- how fast velocity should change in up/down directions
	climb_acceleration = 500,
	
	-- number of limbs from 1 perk
	limb_count = 6,
	
	-- length of legs from 1 perk
	limb_length = 45,
	
	stack_perk = {
		-- additional speed multiplier for each stacked perk beyond the first
		velocity_multiplier_at_full_grip = 0.25,
		
		-- the upper limit for speed multiplier from stacking the perk
		velocity_multiplier_limit = 3.00,
		
		-- additional leg count for each stacked perk beyond the first
		limb_count_add = 1,
		
		-- the upper limit for leg count from stacking the perk
		limb_count_limit = 8,
		
		-- additional leg length as a portion of original 'limb_length' for each stacked perk beyond the first
		limb_length_multiplier = 0.2,
		
		-- the upper limit for leg length from stacking the perk
		limb_length_limit = 70,
	}
}