extends Node2D

const ChaletProgression = preload("res://scripts/app/chalet_progression.gd")
const SurvivalState = preload("res://scripts/app/survival_state.gd")
const ChaletArt = preload("res://assets/kenney/characters/spritesheet.png")
const ROUTE_NONE := ""
const ROUTE_SAFE := "safe"
const ROUTE_SHORTCUT := "shortcut"

var player: CharacterBody2D
var hud: CanvasLayer
var progression := ChaletProgression.new()
var survival := SurvivalState.new()
var slice_state := ChaletProgression.ENCERRADO
var suit_equipped := false
var selected_exit := ""
var zone_title := ""
var radio_activated := false
var general_paz_reached := false
var slice_closed := false
var in_shelter := false
var shelter_visited := false
var route_taken := ROUTE_NONE
var filter_consumed := false

func _ready() -> void:
	var chalet := preload("res://scenes/world/chalet.tscn").instantiate()
	chalet.name = "Chalet"
	add_child(chalet)
	player = preload("res://scenes/player/player.tscn").instantiate()
	player.name = "Player"
	player.position = Vector2(100, 670)
	add_child(player)
	hud = preload("res://scenes/ui/hud.tscn").instantiate()
	add_child(hud)
	for material in get_tree().get_nodes_in_group("suit_material"):
		material.collected.connect(collect_material)
	get_node("Chalet/FavalliFabrication").craft_requested.connect(try_craft_suit)
	for exit_node in get_tree().get_nodes_in_group("suit_exit"):
		exit_node.exit_requested.connect(try_exit)
	_refresh_hud("Favalli needs three materials for an insulated suit.")

func _process(delta: float) -> void:
	if slice_closed:
		return
	if selected_exit == ChaletProgression.EXIT_VN:
		survival.tick(delta * 4.0, in_shelter)
		hud.set_exposure(survival.exposure, survival.risk_label(), not in_shelter)
		if survival.is_lethal():
			_refresh_hud("La nevada atravesó el sellado. No llegaste a refugio.")
			hud.show_terminal("La nieve no perdona", "La exposición rompió el sellado antes de alcanzar refugio.")
			slice_closed = true
			player.velocity = Vector2.ZERO
			player.set_physics_process(false)
			return
	if Input.is_action_just_pressed("interact"):
		_interact_with_nearest()

func _interact_with_nearest() -> void:
	var closest: Node2D
	var closest_distance := 92.0
	for interactable in get_tree().get_nodes_in_group("chalet_interactable"):
		if not interactable is Node2D:
			continue
		var distance := player.global_position.distance_to((interactable as Node2D).global_position)
		if distance < closest_distance:
			closest = interactable
			closest_distance = distance
	if closest != null:
		closest.interact()

func collect_material(material_id: String) -> void:
	if progression.collect_material(material_id):
		_refresh_hud("Material secured: %s." % material_id.replace("_", " "))

func try_craft_suit() -> bool:
	if not progression.craft_suit():
		_refresh_hud("Favalli: the three materials are still needed.")
		return false
	get_node("Chalet/FavalliFabrication").show_fabrication()
	player.get_node("SuitOverlay").show()
	_refresh_hud("Favalli sella el traje. La nieve ya no es una barrera inmediata.")
	return true

func try_exit(exit_id: String) -> bool:
	if not progression.take_exit(exit_id):
		_refresh_hud("The snowfall is lethal without the insulated suit.")
		return false
	get_node("Chalet/Exit%s" % exit_id).close_slice()
	if exit_id == ChaletProgression.EXIT_VN:
		_enter_vicente_lopez_norte()
		return true
	_refresh_hud("First step into the snow. Elena and Martita remain at the chalet.")
	hud.show_terminal(zone_title, "El primer paso al sur abre una ruta distinta, todavía cubierta por la nevada.")
	slice_closed = true
	player.velocity = Vector2.ZERO
	player.set_physics_process(false)
	return true

func _enter_vicente_lopez_norte() -> void:
	var exterior := preload("res://scenes/world/vicente_lopez_norte.tscn").instantiate()
	exterior.name = "VicenteLopezNorte"
	add_child(exterior)
	exterior.radio_requested.connect(_activate_radio)
	exterior.shelter_changed.connect(_on_shelter_changed)
	exterior.shortcut_requested.connect(_take_shortcut)
	exterior.safe_route_requested.connect(_take_safe_route)
	get_node("Chalet").queue_free()
	player.position = Vector2(100, 670)
	in_shelter = false
	shelter_visited = false
	route_taken = ROUTE_NONE
	filter_consumed = false
	_refresh_hud("Nieve cerrada. Una radio transmite al norte.")

func _activate_radio() -> void:
	if progression.activate_radio():
		get_node("VicenteLopezNorte").set_routes_available(true)
		_refresh_hud("R-1 activa: elegí el atajo expuesto o el desvío cubierto.")

func _on_shelter_changed(is_inside: bool) -> void:
	in_shelter = is_inside
	hud.set_exposure(survival.exposure, survival.risk_label(), not in_shelter)
	if is_inside:
		shelter_visited = true
		_refresh_hud("Refugio cálido: la exposición baja.")

func _take_shortcut() -> void:
	if slice_closed or not progression.radio_activated or not route_taken.is_empty():
		return
	if not survival.use_spare_filter():
		_refresh_hud("Sin filtro: volvé al refugio y tomá el desvío cubierto.")
		return
	filter_consumed = true
	route_taken = ROUTE_SHORTCUT
	_complete_general_paz("Atajo expuesto: gastaste el filtro de repuesto.")

func _take_safe_route() -> void:
	if slice_closed or not progression.radio_activated or not route_taken.is_empty():
		return
	if not shelter_visited:
		_refresh_hud("Primero entrá al refugio: el desvío cubierto empieza bajo su techo.")
		return
	route_taken = ROUTE_SAFE
	_complete_general_paz("Desvío cubierto: conservaste el filtro de repuesto.")

func _complete_general_paz(status: String) -> void:
	if not progression.reach_general_paz():
		return
	_refresh_hud(status)
	hud.show_terminal("General Paz", status)
	slice_closed = true
	player.velocity = Vector2.ZERO
	player.set_physics_process(false)

func _refresh_hud(status: String) -> void:
	slice_state = progression.slice_state
	suit_equipped = progression.suit_equipped
	selected_exit = progression.selected_exit
	zone_title = progression.zone_title
	radio_activated = progression.radio_activated
	general_paz_reached = progression.general_paz_reached
	hud.set_status(status)
	if slice_state == ChaletProgression.GENERAL_PAZ_ALCANZADA:
		hud.set_objective("General Paz reached.")
	elif slice_state == ChaletProgression.RADIO_ACTIVADA:
		hud.set_objective("Elegí: atajo expuesto con filtro o desvío cubierto por el refugio.")
	elif slice_state == ChaletProgression.VICENTE_LOPEZ_NORTE:
		hud.set_objective("Find and activate the R-1 neighborhood radio.")
	elif slice_state == ChaletProgression.MATERIALES_COMPLETOS:
		hud.set_objective("Return to Favalli and interact with the fabrication table.")
	elif suit_equipped and selected_exit.is_empty():
		hud.set_objective("Choose the north window (VN) or south door (VS).")
	elif not selected_exit.is_empty():
		hud.set_objective(zone_title)
	else:
		hud.set_objective("Collect lona, sellado/guantes and máscara/filtro in any order.")
