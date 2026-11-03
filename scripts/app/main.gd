extends Node2D

const ChaletProgression = preload("res://scripts/app/chalet_progression.gd")

var player: CharacterBody2D
var hud: CanvasLayer
var progression := ChaletProgression.new()
var slice_state := ChaletProgression.ENCERRADO
var suit_equipped := false
var selected_exit := ""
var zone_title := ""
var radio_activated := false
var slice_closed := false

func _ready() -> void:
	_render_background()
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

func _process(_delta: float) -> void:
	if slice_closed:
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
	_refresh_hud("Favalli seals the suit. The snow is no longer an immediate barrier.")
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
	hud.show_terminal(zone_title)
	slice_closed = true
	player.velocity = Vector2.ZERO
	player.set_physics_process(false)
	return true

func _enter_vicente_lopez_norte() -> void:
	var exterior := preload("res://scenes/world/vicente_lopez_norte.tscn").instantiate()
	exterior.name = "VicenteLopezNorte"
	add_child(exterior)
	exterior.radio_requested.connect(_activate_radio)
	get_node("Chalet").queue_free()
	player.position = Vector2(100, 670)
	_refresh_hud("Nieve cerrada. Una radio transmite al norte.")

func _activate_radio() -> void:
	if progression.activate_radio():
		_refresh_hud("R-1 activa: la señal apunta hacia General Paz.")

func _refresh_hud(status: String) -> void:
	slice_state = progression.slice_state
	suit_equipped = progression.suit_equipped
	selected_exit = progression.selected_exit
	zone_title = progression.zone_title
	radio_activated = progression.radio_activated
	hud.set_status(status)
	hud.set_slice_state(slice_state)
	if slice_state == ChaletProgression.RADIO_ACTIVADA:
		hud.set_objective("Signal confirmed: head toward General Paz.")
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

func _render_background() -> void:
	var background := ColorRect.new()
	background.name = "ChaletInterior"
	background.color = Color("233039")
	background.position = Vector2.ZERO
	background.size = Vector2(1280, 800)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)
