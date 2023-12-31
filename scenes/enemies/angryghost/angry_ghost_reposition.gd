class_name AngryGhostReposition extends State

## Called when a state is entered.
func enter() -> void:
	node.nav.target_position = node.home
	node.anim.play("Dash")

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
	
	var horiz_next_pos = Vector2(next_pos.x, next_pos.z)
	var horiz_pos = Vector2(node.global_position.x, node.global_position.z)
	
	node.rotation.y = lerp_angle(node.rotation.y, -PI / 2 - (horiz_next_pos - horiz_pos).angle(), delta * 4.0)
	
	if node.nav.is_target_reached():
		node.velocity = Vector3.ZERO
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
