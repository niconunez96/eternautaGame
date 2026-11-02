class_name LockedDoor
extends Area2D

signal interaction_requested
signal unlocked_changed

var unlocked := false
var player_in_range := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func request_interaction() -> void:
	if player_in_range:
		interaction_requested.emit()

func unlock() -> void:
	if unlocked:
		return
	unlocked = true
	$Blocker/CollisionShape2D.set_deferred("disabled", true)
	$DoorShape.color = Color("4fd18b")
	unlocked_changed.emit()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = false
