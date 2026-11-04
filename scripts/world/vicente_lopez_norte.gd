class_name VicenteLopezNorte
extends Node2D

signal radio_requested
signal shelter_changed(is_inside: bool)
signal shortcut_requested
signal safe_route_requested
signal route_completed(route: String)

func _ready() -> void:
	$Shelter.body_entered.connect(_on_shelter_body_entered)
	$Shelter.body_exited.connect(_on_shelter_body_exited)

func request_radio() -> void:
	radio_requested.emit()

func request_shortcut() -> void:
	shortcut_requested.emit()

func request_safe_route() -> void:
	safe_route_requested.emit()

func set_routes_available(available: bool) -> void:
	$ShortcutExit.set_available(available)
	$GeneralPazExit.set_available(available)

func begin_route(route: String) -> void:
	if route == "shortcut":
		$Presentation/ExposedRoute.visible = true
		$ShortcutEndpoint.set_available(true)
		return
	$Presentation/CoveredRoute.visible = true
	$CoveredEndpoint.set_available(true)

func complete_route(route: String) -> void:
	route_completed.emit(route)

func _on_shelter_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		shelter_changed.emit(true)

func _on_shelter_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		shelter_changed.emit(false)
