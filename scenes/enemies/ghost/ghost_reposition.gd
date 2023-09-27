class_name GhostReposition extends State

## Called when a state is entered.
func enter() -> void:
	node.anim.play("Dash")
	while not node.nav.is_target_reachable():
		var range = 8.0
		var r = range * sqrt(randf())
		var theta = randf() * 2 * PI
		var rand_point = Vector2(r * cos(theta), r * sin(theta))
		node.nav.target_position = node.global_position + Vector3(rand_point.x, 0, rand_point.z)

## Called in state machine's _process function.
func run(delta) -> void:
	pass

## Called in state machine's _physics_process function.
func run_physics(delta) -> void:
	# Add the gravity.
	if not node.is_on_floor():
		node.velocity.y -= node.gravity * delta
	
	var next_pos = node.nav.get_next_path_position()
	var direction = (next_pos - node.global_position).normalized()
	
	var horiz_pos = Vector2(node.global_position.x, node.global_position.z)
	var horiz_target = Vector2(node.nav.target_position.x, node.nav.target_position.z)
	node.rotation.y = (horiz_target - horiz_pos).angle()
	
	if node.nav.is_target_reached():
		state_machine.enter_state("Idle")
	
	var horiz_vel = Vector2(node.velocity.x, node.velocity.z)
	var horiz_targ_vel = Vector2(direction.x, direction.z) * node.SPEED
	
	if node.is_on_floor():
		horiz_vel = horiz_vel.move_toward(horiz_targ_vel, node.ACCEL * delta)
	else:
		horiz_vel = horiz_vel.move_toward(horiz_targ_vel, node.AIR_ACCEL * delta)
	
	node.velocity = Vector3(horiz_vel.x, node.velocity.y, horiz_vel.y)
	
	node.move_and_slide()

## Called when the state exits.
func exit() -> void:
	pass
