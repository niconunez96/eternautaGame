extends GutTest

const PlayerMotionRules = preload("res://scripts/player/player_motion_rules.gd")

func test_accelerate_toward_target_clamps_to_target() -> void:
	assert_eq(PlayerMotionRules.accelerate(0.0, 240.0, 100.0, 1.0), 100.0)

func test_coyote_time_allows_one_human_jump_after_leaving_floor() -> void:
	assert_true(PlayerMotionRules.can_jump(false, 0.08, 0.12))

func test_second_air_jump_is_always_rejected() -> void:
	assert_false(PlayerMotionRules.can_jump(false, 0.0, 0.12))
	assert_false(PlayerMotionRules.can_second_air_jump())

func test_dash_is_not_an_input_action() -> void:
	assert_false(InputMap.has_action("dash"))
