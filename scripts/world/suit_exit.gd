class_name SuitExit
extends Area2D

signal exit_requested(exit_id: String)

@export var exit_id := ""
var completed := false

func interact() -> void:
	if not completed:
		exit_requested.emit(exit_id)

func close_slice() -> void:
	completed = true
