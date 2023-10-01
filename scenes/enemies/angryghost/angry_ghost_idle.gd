class_name AngryGhostIdle extends State

## Called when a state is entered.
func enter() -> void:
	node.anim.play("Idle")

## Called in state machine's _process function.
func run(delta) -> void:
	pass

## Called in state machine's _physics_process function.
func run_physics(delta) -> void:
	# Add the gravity.
	if not node.is_on_floor():
		node.velocity.y -= node.gravity * delta
	
	if node.target:
		var horiz_pos = Vector2(node.global_position.x, node.global_position.z)
		var target_pos = node.target.global_position
		var target_horiz_pos = Vector2(target_pos.x, target_pos.z)
		if node.alert:
			node.rotation.y = lerp_angle(node.rotation.y, -PI / 2 - (target_horiz_pos - horiz_pos).angle(), delta * 4.0)
		node.sight_cast.target_position = node.to_local(target_pos)
		if (target_pos - node.global_position).length() < 4.0:
			state_machine.enter_state("Swing")
	
	if (node.global_position - node.home).length() > 1:
		state_machine.enter_state("Reposition")

	var horiz_vel = Vector2(node.velocity.x, node.velocity.z)
	horiz_vel = horiz_vel.move_toward(Vector2.ZERO, node.FRICTION * delta)
	node.velocity = Vector3(horiz_vel.x, node.velocity.y, horiz_vel.y)
	
	node.move_and_slide()

## Called when the state exits.
func exit() -> void:
	pass
