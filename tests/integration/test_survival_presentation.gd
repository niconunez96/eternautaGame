extends GutTest

func test_main_exposes_survival_state_and_player_facing_risk_ui() -> void:
	var scene := load("res://scenes/app/main.tscn") as PackedScene
	var main := scene.instantiate() as Node2D
	add_child_autofree(main)
	await get_tree().process_frame
	assert_not_null(main.get("survival"))
	assert_not_null(main.get_node_or_null("HUD/ExposureLabel"))
	assert_false(main.get_node("HUD/ExposureLabel").visible)
