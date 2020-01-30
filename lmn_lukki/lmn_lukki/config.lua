
-- CONFIGURATION:
-- tweak these variables however you like.
-- let me know if you need any more.

lmn = lmn or {}
lmn.config = {
	velocity_max_multiplier_at_full_grip = 1.50,
	climb_acceleration = 500,
	limb_count = 6,
	limb_length = 55,
	ignores_oil_slippyness = false, -- not sure if this option still works
	
	stack_perk = {
		velocity_max_multiplier_at_full_grip = 0.25,
		limbs_count_add = 1,
		limbs_count_max = 8,
		limb_length_multiplier = 0.5,
	}
}