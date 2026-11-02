extends GutTest

const PlayerMotionRules = preload("res://scripts/player/player_motion_rules.gd")

func test_accelerate_toward_target_clamps_to_target() -> void:
	assert_eq(PlayerMotionRules.accelerate(0.0, 240.0, 100.0, 1.0), 100.0)

func test_coyote_time_allows_jump_after_leaving_floor() -> void:
	assert_true(PlayerMotionRules.can_jump(false, 0.08, 0.12))

func test_neutral_dash_uses_facing_direction() -> void:
	assert_eq(PlayerMotionRules.resolve_dash_direction(0.0, -1), -1)

func test_dash_cooldown_blocks_dash_until_expired() -> void:
	assert_false(PlayerMotionRules.can_dash(0.05))
	assert_true(PlayerMotionRules.can_dash(0.0))
