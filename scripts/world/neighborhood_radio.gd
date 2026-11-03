class_name NeighborhoodRadio
extends Area2D

var activated := false

func interact() -> void:
	if activated:
		return
	activated = true
	get_parent().request_radio()
