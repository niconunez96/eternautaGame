extends GutTest

const PlayerMotionRules = preload("res://scripts/player/player_motion_rules.gd")

func test_accelerate_toward_target_clamps_to_target() -> void:
	assert_eq(PlayerMotionRules.accelerate(0.0, 240.0, 100.0, 1.0), 100.0)

func test_coyote_time_allows_jump_after_leaving_floor() -> void:
	assert_true(PlayerMotionRules.can_jump(false, 0.08, 0.12))

func test_extra_jump_requires_acquired_ability_and_available_air_charge() -> void:
	assert_false(PlayerMotionRules.can_extra_jump(false, true, false, 0.0, 0.12))
	assert_false(PlayerMotionRules.can_extra_jump(true, false, false, 0.0, 0.12))
	assert_false(PlayerMotionRules.can_extra_jump(true, true, true, 0.0, 0.12))
	assert_false(PlayerMotionRules.can_extra_jump(true, true, false, 0.08, 0.12))
	assert_true(PlayerMotionRules.can_extra_jump(true, true, false, 0.0, 0.12))

func test_extra_jump_consumes_its_only_charge_and_blocks_another_attempt_until_landing() -> void:
	var air_jump_available := true
	air_jump_available = PlayerMotionRules.consume_extra_jump(true, air_jump_available, false, 0.0, 0.12)
	assert_false(air_jump_available)
	assert_false(PlayerMotionRules.can_extra_jump(true, air_jump_available, false, 0.0, 0.12))
	assert_false(PlayerMotionRules.consume_extra_jump(true, air_jump_available, false, 0.0, 0.12))
	assert_true(PlayerMotionRules.refresh_air_jump(true, air_jump_available, true))

func test_landing_refreshes_the_single_air_charge_only_for_acquired_ability() -> void:
	assert_false(PlayerMotionRules.refresh_air_jump(false, false, true))
	assert_false(PlayerMotionRules.refresh_air_jump(true, false, false))
	assert_true(PlayerMotionRules.refresh_air_jump(true, false, true))
	assert_true(PlayerMotionRules.refresh_air_jump(true, true, true))

func test_neutral_dash_uses_facing_direction() -> void:
	assert_eq(PlayerMotionRules.resolve_dash_direction(0.0, -1), -1)

func test_dash_cooldown_blocks_dash_until_expired() -> void:
	assert_false(PlayerMotionRules.can_dash(0.05))
	assert_true(PlayerMotionRules.can_dash(0.0))
