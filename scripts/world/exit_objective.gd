extends Area2D

signal completed_changed

var completed := false
var traversal_unlocked := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if completed or not traversal_unlocked or not body.is_in_group("player"):
		return
	completed = true
	completed_changed.emit()

func unlock_after_traversal() -> void:
	traversal_unlocked = true
