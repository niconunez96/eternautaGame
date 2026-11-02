extends GutTest

const ProgressionRules = preload("res://scripts/world/progression_rules.gd")

func test_missing_access_key_cannot_unlock() -> void:
	assert_false(ProgressionRules.can_unlock(false))

func test_acquired_access_key_can_unlock() -> void:
	assert_true(ProgressionRules.can_unlock(true))

func test_collecting_access_key_is_idempotent() -> void:
	assert_true(ProgressionRules.collect_access_key(false))
	assert_true(ProgressionRules.collect_access_key(true))
