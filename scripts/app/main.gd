extends Node2D

const ProgressionRules = preload("res://scripts/world/progression_rules.gd")

var player: CharacterBody2D
var hud: CanvasLayer
var basic_enemy: Area2D
var checkpoint: Area2D
var access_reward: Area2D
var locked_door: Area2D
var initial_spawn := Vector2(110, 688)
var checkpoint_position := initial_spawn
var has_access_key := false
var paused := false

func _ready() -> void:
	_render_arena()
	player = preload("res://scenes/player/player.tscn").instantiate()
	player.name = "Player"
	player.position = initial_spawn
	add_child(player)
	basic_enemy = preload("res://scenes/world/basic_enemy.tscn").instantiate()
	basic_enemy.position = Vector2(300, 688)
	add_child(basic_enemy)
	checkpoint = preload("res://scenes/world/checkpoint.tscn").instantiate()
	checkpoint.position = Vector2(460, 684)
	add_child(checkpoint)
	access_reward = preload("res://scenes/world/access_reward.tscn").instantiate()
	access_reward.position = Vector2(620, 684)
	add_child(access_reward)
	locked_door = preload("res://scenes/world/locked_door.tscn").instantiate()
	locked_door.position = Vector2(830, 675)
	add_child(locked_door)
	hud = preload("res://scenes/ui/hud.tscn").instantiate()
	add_child(hud)
	player.health_changed.connect(_on_health_changed)
	player.died.connect(_on_player_died)
	player.attack_requested.connect(_on_attack_requested)
	checkpoint.activated.connect(activate_checkpoint)
	access_reward.collected.connect(_on_reward_collected)
	locked_door.interaction_requested.connect(_on_door_interaction_requested)
	hud.set_health(player.current_health, player.maximum_health)
	hud.set_checkpoint(false)
	hud.set_ability(false)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		paused = not paused
		get_tree().paused = paused
		if paused:
			var menu := preload("res://scenes/ui/pause_menu.tscn").instantiate()
			add_child(menu)
		return
	if not paused and event.is_action_pressed("interact"):
		locked_door.request_interaction()

func activate_checkpoint(respawn: Vector2) -> void:
	checkpoint_position = respawn
	hud.set_checkpoint(true)
	hud.set_status("Checkpoint activated")

func acquire_access_key() -> void:
	has_access_key = ProgressionRules.collect_access_key(has_access_key)
	hud.set_ability(has_access_key)
	hud.set_status("Access key acquired")

func _on_health_changed(current: int, maximum: int) -> void:
	hud.set_health(current, maximum)

func _on_player_died() -> void:
	player.reset_at(checkpoint_position)
	hud.set_status("Respawned at checkpoint")

func _on_attack_requested(direction: int) -> void:
	if basic_enemy.defeated_state:
		return
	var horizontal_distance := (basic_enemy.global_position.x - player.global_position.x) * direction
	if horizontal_distance >= -20.0 and horizontal_distance <= 130.0 and absf(basic_enemy.global_position.y - player.global_position.y) <= 80.0:
		basic_enemy.receive_attack()
		hud.set_status("Enemy defeated")

func _on_reward_collected(_ability_id: String) -> void:
	acquire_access_key()

func _on_door_interaction_requested() -> void:
	if ProgressionRules.can_unlock(has_access_key):
		locked_door.unlock()
		hud.set_status("Door unlocked")
	else:
		hud.set_status("Door requires access key")

func _render_arena() -> void:
	var background := ColorRect.new()
	background.name = "Background"
	background.color = Color("18243a")
	background.position = Vector2.ZERO
	background.size = Vector2(1280, 800)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)
	_add_platform("Floor", Vector2(640, 760), Vector2(1280, 80), Color("3f5c6d"))
	_add_platform("PlatformOne", Vector2(520, 570), Vector2(160, 26), Color("55778d"))
	_add_platform("PlatformTwo", Vector2(1000, 510), Vector2(190, 26), Color("55778d"))

func _add_platform(node_name: String, platform_position: Vector2, size: Vector2, color: Color) -> void:
	var platform := StaticBody2D.new()
	platform.name = node_name
	platform.position = platform_position
	var shape := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = size
	shape.shape = rectangle
	platform.add_child(shape)
	var visual := Polygon2D.new()
	visual.polygon = PackedVector2Array([Vector2(-size.x / 2.0, -size.y / 2.0), Vector2(size.x / 2.0, -size.y / 2.0), Vector2(size.x / 2.0, size.y / 2.0), Vector2(-size.x / 2.0, size.y / 2.0)])
	visual.color = color
	platform.add_child(visual)
	add_child(platform)
