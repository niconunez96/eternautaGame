extends Node

const SETTINGS_PATH := "user://settings.cfg"
func reset_to_defaults() -> void:
	var settings := ConfigFile.new()
	settings.set_value("controls", "reset", true)
	settings.save(SETTINGS_PATH)
