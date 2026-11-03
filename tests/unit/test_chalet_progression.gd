extends GutTest

const ChaletProgression = preload("res://scripts/app/chalet_progression.gd")

func test_starts_locked_with_no_materials() -> void:
	var progression = ChaletProgression.new()
	assert_eq(progression.slice_state, ChaletProgression.ENCERRADO)
	assert_eq(progression.material_count(), 0)
	assert_false(progression.can_craft())
	assert_false(progression.can_exit(ChaletProgression.EXIT_VN))
	assert_false(progression.can_exit(ChaletProgression.EXIT_VS))

func test_collecting_each_material_is_idempotent() -> void:
	var progression = ChaletProgression.new()
	assert_true(progression.collect_material(ChaletProgression.LONA))
	assert_false(progression.collect_material(ChaletProgression.LONA))
	assert_true(progression.collect_material(ChaletProgression.SELLADO_GUANTES))
	assert_true(progression.collect_material(ChaletProgression.MASCARA_FILTRO))
	assert_eq(progression.material_count(), 3)
	assert_eq(progression.slice_state, ChaletProgression.MATERIALES_COMPLETOS)

func test_every_material_order_unlocks_fabrication_only_after_the_third() -> void:
	var orders := [
		[ChaletProgression.LONA, ChaletProgression.SELLADO_GUANTES, ChaletProgression.MASCARA_FILTRO],
		[ChaletProgression.LONA, ChaletProgression.MASCARA_FILTRO, ChaletProgression.SELLADO_GUANTES],
		[ChaletProgression.SELLADO_GUANTES, ChaletProgression.LONA, ChaletProgression.MASCARA_FILTRO],
		[ChaletProgression.SELLADO_GUANTES, ChaletProgression.MASCARA_FILTRO, ChaletProgression.LONA],
		[ChaletProgression.MASCARA_FILTRO, ChaletProgression.LONA, ChaletProgression.SELLADO_GUANTES],
		[ChaletProgression.MASCARA_FILTRO, ChaletProgression.SELLADO_GUANTES, ChaletProgression.LONA],
	]
	for order in orders:
		var progression = ChaletProgression.new()
		assert_true(progression.collect_material(order[0]))
		assert_false(progression.can_craft())
		assert_true(progression.collect_material(order[1]))
		assert_false(progression.can_craft())
		assert_true(progression.collect_material(order[2]))
		assert_true(progression.can_craft())

func test_crafting_rejects_zero_one_and_two_materials() -> void:
	for count in 3:
		var progression = ChaletProgression.new()
		for material in ChaletProgression.MATERIALS.slice(0, count):
			progression.collect_material(material)
		assert_false(progression.craft_suit())
		assert_false(progression.suit_equipped)

func test_crafting_equips_the_suit_and_unlocks_both_exits() -> void:
	var progression = ChaletProgression.new()
	for material in ChaletProgression.MATERIALS:
		progression.collect_material(material)
	assert_true(progression.craft_suit())
	assert_true(progression.suit_equipped)
	assert_eq(progression.slice_state, ChaletProgression.TRAJE_EQUIPADO)
	assert_true(progression.can_exit(ChaletProgression.EXIT_VN))
	assert_true(progression.can_exit(ChaletProgression.EXIT_VS))

func test_exits_are_blocked_before_suit_and_keep_distinct_titles_afterward() -> void:
	for exit_id in [ChaletProgression.EXIT_VN, ChaletProgression.EXIT_VS]:
		var progression = ChaletProgression.new()
		assert_false(progression.take_exit(exit_id))
		for material in ChaletProgression.MATERIALS:
			progression.collect_material(material)
		progression.craft_suit()
		assert_true(progression.take_exit(exit_id))
		assert_eq(progression.selected_exit, exit_id)
		assert_eq(progression.zone_title, "Vicente López norte" if exit_id == ChaletProgression.EXIT_VN else "Vicente López sur")
		var expected_state := "vicente_lopez_norte" if exit_id == ChaletProgression.EXIT_VN else ChaletProgression.EXTERIOR_INICIADO
		assert_eq(progression.slice_state, expected_state)

func test_radio_requires_vn_and_activates_only_once() -> void:
	var progression = ChaletProgression.new()
	assert_false(progression.get("radio_activated") == true)
	assert_true(progression.has_method("activate_radio"))
	assert_false(progression.call("activate_radio"))
	for material in ChaletProgression.MATERIALS:
		progression.collect_material(material)
	progression.craft_suit()
	assert_true(progression.take_exit(ChaletProgression.EXIT_VN))
	assert_eq(progression.slice_state, "vicente_lopez_norte")
	assert_true(progression.call("activate_radio"))
	assert_true(progression.get("radio_activated") == true)
	assert_eq(progression.slice_state, "radio_activada")
	assert_eq(progression.get("objective"), "general_paz")
	assert_false(progression.call("activate_radio"))
	assert_eq(progression.get("objective"), "general_paz")

func test_vs_route_cannot_activate_radio() -> void:
	var progression = ChaletProgression.new()
	for material in ChaletProgression.MATERIALS:
		progression.collect_material(material)
	progression.craft_suit()
	assert_true(progression.take_exit(ChaletProgression.EXIT_VS))
	assert_false(progression.has_method("activate_radio") and progression.call("activate_radio"))
	assert_false(progression.get("radio_activated") == true)
