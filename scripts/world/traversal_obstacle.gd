extends Node2D

signal landing_reached_changed

const LANDING_CENTER := Vector2(1010, 472)
const LANDING_HALF_WIDTH := 130.0

var player: CharacterBody2D
var landing_reached := false

func watch_player(candidate: CharacterBody2D) -> void:
	player = candidate

func _physics_process(_delta: float) -> void:
	if landing_reached or player == null:
		return
	if player.is_on_floor() and absf(player.global_position.y - LANDING_CENTER.y) <= 2.0 and absf(player.global_position.x - LANDING_CENTER.x) <= LANDING_HALF_WIDTH:
		confirm_landing()

func confirm_landing() -> void:
	if landing_reached:
		return
	landing_reached = true
	landing_reached_changed.emit()