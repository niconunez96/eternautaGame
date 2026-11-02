class_name ChaletProgression
extends RefCounted

const ENCERRADO := "encerrado"
const COMPONENTE_OBTENIDO := "componente_obtenido"
const MATERIALES_COMPLETOS := "materiales_completos"
const TRAJE_EQUIPADO := "traje_equipado"
const EXTERIOR_INICIADO := "exterior_iniciado"

const LONA := "lona"
const SELLADO_GUANTES := "sellado_guantes"
const MASCARA_FILTRO := "mascara_filtro"
const MATERIALS := [LONA, SELLADO_GUANTES, MASCARA_FILTRO]

const EXIT_VN := "VN"
const EXIT_VS := "VS"

var materials: Dictionary = {}
var suit_equipped := false
var selected_exit := ""
var zone_title := ""
var slice_state := ENCERRADO

func collect_material(material_id: String) -> bool:
	if not MATERIALS.has(material_id) or materials.has(material_id):
		return false
	materials[material_id] = true
	slice_state = MATERIALES_COMPLETOS if can_craft() else COMPONENTE_OBTENIDO
	return true

func material_count() -> int:
	return materials.size()

func can_craft() -> bool:
	return material_count() == MATERIALS.size() and not suit_equipped

func craft_suit() -> bool:
	if not can_craft():
		return false
	suit_equipped = true
	slice_state = TRAJE_EQUIPADO
	return true

func can_exit(exit_id: String) -> bool:
	return suit_equipped and (exit_id == EXIT_VN or exit_id == EXIT_VS) and selected_exit.is_empty()

func take_exit(exit_id: String) -> bool:
	if not can_exit(exit_id):
		return false
	selected_exit = exit_id
	zone_title = "Vicente López norte" if exit_id == EXIT_VN else "Vicente López sur"
	slice_state = EXTERIOR_INICIADO
	return true
