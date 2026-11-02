extends Node2D

var player: CharacterBody2D
var hud: CanvasLayer
var basic_enemy: Area2D
var checkpoint: Area2D
var double_jump_reward: Area2D
var exit_objective: Area2D
var initial_spawn := Vector2(110, 688)
var checkpoint_position := initial_spawn
var has_double_jump := false
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
	double_jump_reward = preload("res://scenes/world/double_jump_reward.tscn").instantiate()
	double_jump_reward.name = "DoubleJumpReward"
	double_jump_reward.position = Vector2(620, 684)
	add_child(double_jump_reward)
	exit_objective = preload("res://scenes/world/exit_objective.tscn").instantiate()
	exit_objective.name = "ExitObjective"
	exit_objective.position = Vector2(1230, 450)
	add_child(exit_objective)
	var obstacle := get_node("TraversalObstacle")
	obstacle.watch_player(player)
	hud = preload("res://scenes/ui/hud.tscn").instantiate()
	add_child(hud)
	player.health_changed.connect(_on_health_changed)
	player.died.connect(_on_player_died)
	player.attack_requested.connect(_on_attack_requested)
	checkpoint.activated.connect(activate_checkpoint)
	double_jump_reward.collected.connect(_on_reward_collected)
	obstacle.landing_reached_changed.connect(_on_elevated_landing_reached)
	exit_objective.completed_changed.connect(_on_exit_completed)
	hud.set_health(player.current_health, player.maximum_health)
	hud.set_checkpoint(false)
	hud.set_ability(false)
	hud.set_objective("Reach the exit beyond the gap.")

func _process(_delta: float) -> void:
	if player.position.y > 900.0:
		_on_player_died()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		paused = not paused
		get_tree().paused = paused
		if paused:
			var menu := preload("res://scenes/ui/pause_menu.tscn").instantiate()
			add_child(menu)

func activate_checkpoint(respawn: Vector2) -> void:
	checkpoint_position = respawn
	hud.set_checkpoint(true)
	hud.set_status("Checkpoint activated")

func acquire_double_jump() -> void:
	if has_double_jump:
		return
	has_double_jump = true
	player.set_double_jump_acquired(true)
	hud.set_ability(true)
	hud.set_status("Double jump acquired")
	hud.set_objective("Double jump across the gap to reach the exit.")

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
	acquire_double_jump()

func _on_elevated_landing_reached() -> void:
	exit_objective.unlock_after_traversal()
	hud.set_status("Elevated landing reached")

func _on_exit_completed() -> void:
	hud.set_status("Objective complete")
	hud.set_objective("Objective complete: exit reached.")

func _render_arena() -> void:
	var background := ColorRect.new()
	background.name = "Background"
	background.color = Color("18243a")
	background.position = Vector2.ZERO
	background.size = Vector2(1280, 800)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)
	_add_platform_to(self, "StartFloor", Vector2(350, 760), Vector2(700, 80), Color("3f5c6d"))
	var obstacle := preload("res://scripts/world/traversal_obstacle.gd").new()
	obstacle.name = "TraversalObstacle"
	add_child(obstacle)
	_add_platform_to(obstacle, "ElevatedLanding", Vector2(1010, 520), Vector2(260, 32), Color("55778d"))

func _add_platform_to(parent: Node, node_name: String, platform_position: Vector2, size: Vector2, color: Color) -> void:
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
	parent.add_child(platform)
