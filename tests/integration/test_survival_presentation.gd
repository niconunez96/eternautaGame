extends GutTest

func test_main_exposes_survival_state_and_player_facing_risk_ui() -> void:
	var scene := load("res://scenes/app/main.tscn") as PackedScene
	var main := scene.instantiate() as Node2D
	add_child_autofree(main)
	await get_tree().process_frame
	assert_not_null(main.get("survival"))
	assert_not_null(main.get_node_or_null("HUD/ExposureLabel"))
	assert_false(main.get_node("HUD/ExposureLabel").visible)

func test_exposure_indicator_hides_inside_shelter() -> void:
	var scene := load("res://scenes/app/main.tscn") as PackedScene
	var main := scene.instantiate() as Node2D
	add_child_autofree(main)
	await get_tree().process_frame
	for material in main.progression.MATERIALS:
		main.collect_material(material)
	assert_true(main.try_craft_suit())
	assert_true(main.try_exit(main.progression.EXIT_VN))
	await get_tree().process_frame
	assert_true(main.get_node("HUD/ExposureLabel").visible)
	main._on_shelter_changed(true)
	assert_false(main.get_node("HUD/ExposureLabel").visible)
