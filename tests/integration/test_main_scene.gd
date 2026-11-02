extends GutTest

const ChaletProgression = preload("res://scripts/app/chalet_progression.gd")

func _spawn_main() -> Node2D:
	var packed_scene := load("res://scenes/app/main.tscn") as PackedScene
	var instance := packed_scene.instantiate() as Node2D
	add_child_autofree(instance)
	await get_tree().process_frame
	await get_tree().physics_frame
	return instance

func test_main_composes_chalet_contract_without_arena_systems() -> void:
	var instance := await _spawn_main()
	assert_not_null(instance.get_node_or_null("Player"))
	assert_not_null(instance.get_node_or_null("Chalet/MaterialLona"))
	assert_not_null(instance.get_node_or_null("Chalet/MaterialSelladoGuantes"))
	assert_not_null(instance.get_node_or_null("Chalet/MaterialMascaraFiltro"))
	assert_not_null(instance.get_node_or_null("Chalet/FavalliFabrication"))
	assert_not_null(instance.get_node_or_null("Chalet/ExitVN"))
	assert_not_null(instance.get_node_or_null("Chalet/ExitVS"))
	assert_not_null(instance.get_node_or_null("HUD/StatusLabel"))
	assert_not_null(instance.get_node_or_null("HUD/ObjectiveLabel"))
	assert_not_null(instance.get_node_or_null("HUD/SliceStateLabel"))
	assert_not_null(instance.get_node_or_null("HUD/TerminalOverlay"))
	assert_not_null(instance.get_node_or_null("HUD/TerminalOverlay/TerminalTitle"))
	assert_null(instance.get_node_or_null("BasicEnemy"))
	assert_null(instance.get_node_or_null("Checkpoint"))
	assert_null(instance.get_node_or_null("DoubleJumpReward"))
	assert_null(instance.get_node_or_null("TraversalObstacle"))
	assert_null(instance.get_node_or_null("ExitObjective"))

func test_materials_are_free_order_and_fabrication_requires_all_three() -> void:
	var instance := await _spawn_main()
	assert_eq(instance.slice_state, ChaletProgression.ENCERRADO)
	assert_false(instance.try_craft_suit())
	instance.collect_material(ChaletProgression.MASCARA_FILTRO)
	instance.collect_material(ChaletProgression.LONA)
	assert_false(instance.try_craft_suit())
	instance.collect_material(ChaletProgression.SELLADO_GUANTES)
	assert_eq(instance.slice_state, ChaletProgression.MATERIALES_COMPLETOS)
	assert_true(instance.try_craft_suit())
	assert_true(instance.suit_equipped)
	assert_eq(instance.slice_state, ChaletProgression.TRAJE_EQUIPADO)

func test_exits_block_without_suit_and_close_with_the_selected_zone_title() -> void:
	for exit_id in [ChaletProgression.EXIT_VN, ChaletProgression.EXIT_VS]:
		var instance := await _spawn_main()
		assert_false(instance.try_exit(exit_id))
		assert_eq(instance.slice_state, ChaletProgression.ENCERRADO)
		assert_string_contains(instance.get_node("HUD/StatusLabel").text, "lethal without the insulated suit")
		for material in ChaletProgression.MATERIALS:
			instance.collect_material(material)
		instance.try_craft_suit()
		assert_true(instance.try_exit(exit_id))
		assert_eq(instance.slice_state, ChaletProgression.EXTERIOR_INICIADO)
		assert_eq(instance.selected_exit, exit_id)
		var expected_title := "Vicente López norte" if exit_id == ChaletProgression.EXIT_VN else "Vicente López sur"
		assert_eq(instance.zone_title, expected_title)
		assert_true(instance.get_node("HUD/TerminalOverlay").visible)
		assert_string_contains(instance.get_node("HUD/TerminalOverlay/TerminalTitle").text, expected_title)
		var player_position: Vector2 = instance.player.global_position
		instance.player.velocity = Vector2(300.0, 0.0)
		Input.action_press("move_right")
		Input.action_press("interact")
		await get_tree().physics_frame
		await get_tree().process_frame
		Input.action_release("move_right")
		Input.action_release("interact")
		assert_eq(instance.player.global_position, player_position)
		assert_eq(instance.selected_exit, exit_id)
