extends GutTest

func test_main_scene_composes_vertical_slice_contracts() -> void:
	var packed_scene := load("res://scenes/app/main.tscn") as PackedScene
	assert_not_null(packed_scene)
	var instance := packed_scene.instantiate()
	add_child_autofree(instance)
	await get_tree().process_frame
	await get_tree().physics_frame

	var player := instance.get_node_or_null("Player")
	assert_not_null(player)
	assert_eq(player.maximum_health, 3)
	assert_eq(player.current_health, 3)
	assert_not_null(instance.get_node_or_null("BasicEnemy"))
	assert_not_null(instance.get_node_or_null("Checkpoint"))
	assert_not_null(instance.get_node_or_null("AccessReward"))
	var door := instance.get_node_or_null("LockedDoor")
	assert_not_null(door)
	assert_false(door.unlocked)
	assert_not_null(instance.get_node_or_null("HUD/HealthLabel"))
	assert_not_null(instance.get_node_or_null("HUD/CheckpointLabel"))
	assert_not_null(instance.get_node_or_null("HUD/AbilityLabel"))
	assert_not_null(instance.get_node_or_null("HUD/StatusLabel"))

func test_death_resets_player_at_active_checkpoint_without_losing_progress() -> void:
	var packed_scene := load("res://scenes/app/main.tscn") as PackedScene
	var instance := packed_scene.instantiate()
	add_child_autofree(instance)
	await get_tree().process_frame
	await get_tree().physics_frame

	var checkpoint := instance.get_node("Checkpoint")
	instance.activate_checkpoint(checkpoint.respawn_position)
	instance.acquire_access_key()
	var player := instance.get_node("Player")
	player.take_damage(99)
	await get_tree().process_frame

	assert_eq(player.current_health, player.maximum_health)
	assert_eq(player.position, checkpoint.respawn_position)
	assert_true(instance.has_access_key)
