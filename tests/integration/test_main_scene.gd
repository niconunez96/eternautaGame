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

func test_kenney_presentation_contract_preserves_gameplay_nodes() -> void:
	var instance := await _spawn_main()
	_assert_textured_sprite(instance.get_node_or_null("Player/Visual"))
	_assert_textured_sprite(instance.get_node_or_null("Chalet/Floor/Visual"))
	_assert_textured_sprite(instance.get_node_or_null("Chalet/MaterialLona/Visual"))
	_assert_textured_sprite(instance.get_node_or_null("Chalet/FavalliFabrication/Visual"))
	_assert_textured_sprite(instance.get_node_or_null("Chalet/ExitVN/Visual"))
	assert_not_null(instance.get_node_or_null("HUD/TerminalOverlay"))
	assert_not_null(instance.get_node_or_null("HUD/TerminalOverlay/TerminalTitle"))
	_assert_textured_control(instance.get_node_or_null("HUD/TerminalOverlay/Frame"))
	_equip_suit(instance)
	assert_true(instance.try_exit(ChaletProgression.EXIT_VN))
	_assert_textured_control(instance.get_node_or_null("VicenteLopezNorte/SnowfieldBackground"))
	_assert_textured_sprite(instance.get_node_or_null("VicenteLopezNorte/LowRoof/Visual"))
	_assert_textured_sprite(instance.get_node_or_null("VicenteLopezNorte/Radio/Visual"))
	_assert_textured_sprite(instance.get_node_or_null("VicenteLopezNorte/GeneralPazExit/Visual"))

func _assert_textured_sprite(node: Node) -> void:
	assert_true(node is Sprite2D, "Expected a Sprite2D presentation node")
	if node is Sprite2D:
		assert_not_null(node.texture, "Expected a texture binding")

func _assert_textured_control(node: Node) -> void:
	assert_true(node is TextureRect or node is NinePatchRect, "Expected a textured Control presentation node")
	if node is TextureRect or node is NinePatchRect:
		assert_not_null(node.texture, "Expected a texture binding")

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

func _equip_suit(instance: Node2D) -> void:
	for material in ChaletProgression.MATERIALS:
		instance.collect_material(material)
	assert_true(instance.try_craft_suit())

func test_north_exit_stays_playable_and_radio_sets_general_paz_objective() -> void:
	var instance := await _spawn_main()
	assert_false(instance.try_exit(ChaletProgression.EXIT_VN))
	assert_eq(instance.slice_state, ChaletProgression.ENCERRADO)
	assert_string_contains(instance.get_node("HUD/StatusLabel").text, "lethal without the insulated suit")
	_equip_suit(instance)
	assert_true(instance.try_exit(ChaletProgression.EXIT_VN))
	assert_eq(instance.selected_exit, ChaletProgression.EXIT_VN)
	assert_eq(instance.slice_state, "vicente_lopez_norte")
	assert_not_null(instance.get_node_or_null("VicenteLopezNorte"))
	assert_false(instance.slice_closed)
	assert_false(instance.get_node("HUD/TerminalOverlay").visible)
	assert_true(instance.player.is_physics_processing())
	var general_paz_exit = instance.get_node_or_null("VicenteLopezNorte/GeneralPazExit")
	assert_not_null(general_paz_exit)
	assert_false(general_paz_exit.available)
	instance.get_node("VicenteLopezNorte").emit_signal("general_paz_requested")
	assert_eq(instance.slice_state, ChaletProgression.VICENTE_LOPEZ_NORTE)
	assert_string_contains(instance.get_node("HUD/StatusLabel").text, "bloqueada")
	instance.get_node("VicenteLopezNorte").emit_signal("radio_requested")
	assert_true(instance.progression.radio_activated)
	assert_eq(instance.slice_state, "radio_activada")
	assert_string_contains(instance.get_node("HUD/ObjectiveLabel").text, "General Paz")
	assert_true(general_paz_exit.available)
	instance.get_node("VicenteLopezNorte").emit_signal("general_paz_requested")
	assert_true(instance.general_paz_reached)
	assert_eq(instance.slice_state, ChaletProgression.GENERAL_PAZ_ALCANZADA)
	assert_true(instance.slice_closed)
	assert_true(instance.get_node("HUD/TerminalOverlay").visible)
	assert_string_contains(instance.get_node("HUD/TerminalOverlay/TerminalTitle").text, "General Paz")
	assert_false(instance.player.is_physics_processing())
	instance.get_node("VicenteLopezNorte").emit_signal("general_paz_requested")
	assert_eq(instance.slice_state, ChaletProgression.GENERAL_PAZ_ALCANZADA)

func test_south_exit_stays_terminal_and_disables_player() -> void:
	var instance := await _spawn_main()
	_equip_suit(instance)
	assert_true(instance.try_exit(ChaletProgression.EXIT_VS))
	assert_eq(instance.slice_state, ChaletProgression.EXTERIOR_INICIADO)
	assert_eq(instance.selected_exit, ChaletProgression.EXIT_VS)
	assert_eq(instance.zone_title, "Vicente López sur")
	assert_true(instance.slice_closed)
	assert_true(instance.get_node("HUD/TerminalOverlay").visible)
	assert_string_contains(instance.get_node("HUD/TerminalOverlay/TerminalTitle").text, "Vicente López sur")
	assert_false(instance.player.is_physics_processing())
