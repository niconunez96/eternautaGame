extends GutTest

const PlayerHealth = preload("res://scripts/player/player_health.gd")

func test_damage_cannot_reduce_health_below_zero() -> void:
	assert_eq(PlayerHealth.apply_damage(3, 10), 0)

func test_invulnerability_blocks_repeated_damage() -> void:
	assert_eq(PlayerHealth.apply_damage(5, 2, true), 5)

func test_healing_cannot_exceed_maximum_health() -> void:
	assert_eq(PlayerHealth.heal(8, 10, 5), 10)

func test_reset_restores_maximum_health() -> void:
	assert_eq(PlayerHealth.reset(10), 10)
