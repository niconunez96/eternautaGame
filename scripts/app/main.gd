extends Node2D

var player: CharacterBody2D
var paused := false

func _ready() -> void:
	_render_arena()
	player = preload("res://scenes/player/player.tscn").instantiate()
	player.position = Vector2(260, 580)
	add_child(player)
	var hud := preload("res://scenes/ui/hud.tscn").instantiate()
	add_child(hud)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		paused = not paused
		get_tree().paused = paused
		if paused:
			var menu := preload("res://scenes/ui/pause_menu.tscn").instantiate()
			add_child(menu)

func _render_arena() -> void:
	var background := ColorRect.new()
	background.color = Color("18243a")
	background.position = Vector2.ZERO
	background.size = Vector2(1280, 800)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)
	var floor := StaticBody2D.new()
	floor.position = Vector2(640, 710)
	var shape := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(1280, 80)
	shape.shape = rectangle
	floor.add_child(shape)
	add_child(floor)
