extends Node

var active_device := "keyboard"
func _input(event: InputEvent) -> void:
	if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		active_device = "controller"
	elif event is InputEventKey:
		active_device = "keyboard"
