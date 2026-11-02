class_name AccessReward
extends Area2D

signal collected(ability_id: String)

var collected_state := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if collected_state or not body.is_in_group("player"):
		return
	collected_state = true
	set_deferred("monitoring", false)
	visible = false
	collected.emit("access_key")
