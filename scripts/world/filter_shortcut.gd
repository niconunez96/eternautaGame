class_name FilterShortcut
extends Area2D

var available := false

func interact() -> void:
	if available:
		get_parent().request_shortcut()

func set_available(value: bool) -> void:
	available = value
	$Label.text = "ATAJO EXPUESTO · consume filtro / K o X" if value else "ATAJO BLOQUEADO"
