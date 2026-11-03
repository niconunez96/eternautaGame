class_name VicenteLopezNorte
extends Node2D

signal radio_requested
signal general_paz_requested

func request_radio() -> void:
	radio_requested.emit()

func request_general_paz() -> void:
	general_paz_requested.emit()

func set_general_paz_available(available: bool) -> void:
	get_node("GeneralPazExit").set_available(available)
