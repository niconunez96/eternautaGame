class_name SuitMaterial
extends Area2D

signal collected(material_id: String)

@export var material_id := ""
var is_collected := false

func interact() -> bool:
	if is_collected:
		return false
	is_collected = true
	visible = false
	monitoring = false
	collected.emit(material_id)
	return true
