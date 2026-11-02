class_name Checkpoint
extends Area2D

signal activated(respawn: Vector2)

var active := false
var respawn_position := Vector2.ZERO

func _ready() -> void:
	respawn_position = global_position
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if active or not body.is_in_group("player"):
		return
	active = true
	activated.emit(respawn_position)
