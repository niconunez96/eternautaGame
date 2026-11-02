class_name BasicEnemy
extends Area2D

signal defeated

@export var contact_damage := 1
var defeated_state := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func receive_attack() -> void:
	if defeated_state:
		return
	defeated_state = true
	monitoring = false
	visible = false
	defeated.emit()

func _on_body_entered(body: Node2D) -> void:
	if defeated_state:
		return
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(contact_damage)
