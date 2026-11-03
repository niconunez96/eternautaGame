class_name VicenteLopezNorte
extends Node2D

signal radio_requested

func request_radio() -> void:
	radio_requested.emit()
