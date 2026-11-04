class_name GeneralPazExit
extends Area2D

var available := false

func interact() -> void:
	if available:
		get_parent().request_safe_route()

func set_available(value: bool) -> void:
	available = value
	$Label.text = "DESVÍO CUBIERTO · General Paz / K o X" if available else "DESVÍO CUBIERTO BLOQUEADO"