class_name FabricationStation
extends Area2D

signal craft_requested
var fabrication_visible := false

func interact() -> void:
	craft_requested.emit()

func show_fabrication() -> void:
	fabrication_visible = true
	$ReadyGlow.show()
