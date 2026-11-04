class_name RouteEndpoint
extends Area2D

@export_enum("safe", "shortcut") var route := "safe"
var available := false

func interact() -> void:
	if available:
		get_parent().complete_route(route)

func set_available(value: bool) -> void:
	available = value
	visible = value
