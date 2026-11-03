class_name GeneralPazExit
extends Area2D

var available := false

func interact() -> void:
	get_parent().request_general_paz()

func set_available(value: bool) -> void:
	available = value
	$Label.text = "General Paz / K o X" if available else "General Paz bloqueada"