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
	assert_not_null(instance.get_node_or_null("DoubleJumpReward"))
	assert_not_null(instance.get_node_or_null("TraversalObstacle"))
	assert_not_null(instance.get_node_or_null("ExitObjective"))
	assert_null(instance.get_node_or_null("AccessReward"))
	assert_null(instance.get_node_or_null("LockedDoor"))
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
	instance.acquire_double_jump()
	var player := instance.get_node("Player")
	assert_true(player.has_double_jump)
	assert_true(player.air_jump_available)
	player.take_damage(99)
	await get_tree().process_frame

	assert_eq(player.current_health, player.maximum_health)
	assert_eq(player.position, checkpoint.respawn_position)
	assert_true(instance.has_double_jump)
	assert_true(player.has_double_jump)

func test_player_capability_starts_disabled_and_has_one_resettable_air_charge() -> void:
	var packed_scene := load("res://scenes/app/main.tscn") as PackedScene
	var instance := packed_scene.instantiate()
	add_child_autofree(instance)
	await get_tree().process_frame
	await get_tree().physics_frame

	var player := instance.get_node("Player")
	assert_false(player.has_double_jump)
	assert_false(player.air_jump_available)
	player.set_double_jump_acquired(true)
	assert_true(player.has_double_jump)
	assert_true(player.air_jump_available)

func test_controller_blocks_air_jump_without_ability_then_consumes_and_blocks_the_only_charge() -> void:
	var packed_scene := load("res://scenes/app/main.tscn") as PackedScene
	var instance := packed_scene.instantiate()
	add_child_autofree(instance)
	await get_tree().process_frame
	await get_tree().physics_frame

	var player := instance.get_node("Player")
	player.position = Vector2(800, 300)
	player.velocity = Vector2.ZERO
	await get_tree().physics_frame
	player.coyote_remaining = 0.0
	assert_false(player.request_jump())
	assert_false(player.air_jump_available)
	player.set_double_jump_acquired(true)
	assert_true(player.request_jump())
	assert_false(player.air_jump_available)
	assert_false(player.request_jump())

func test_exit_stays_locked_until_the_elevated_landing_is_confirmed() -> void:
	var packed_scene := load("res://scenes/app/main.tscn") as PackedScene
	var instance := packed_scene.instantiate()
	add_child_autofree(instance)
	await get_tree().process_frame
	await get_tree().physics_frame

	var obstacle := instance.get_node("TraversalObstacle")
	var exit_objective := instance.get_node("ExitObjective")
	assert_false(obstacle.landing_reached)
	assert_false(exit_objective.traversal_unlocked)
	exit_objective._on_body_entered(instance.get_node("Player"))
	assert_false(exit_objective.completed)
	obstacle.confirm_landing()
	assert_true(obstacle.landing_reached)
	assert_true(exit_objective.traversal_unlocked)
	exit_objective._on_body_entered(instance.get_node("Player"))
	assert_true(exit_objective.completed)
