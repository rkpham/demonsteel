class_name AngryGhostSwing extends State

## Called when a state is entered.
func enter() -> void:
	node.anim.play("Swing")
	await get_tree().create_timer(0.8).timeout
	if node.target:
		var horiz_pos = Vector2(node.global_position.x, node.global_position.z)
		var target_pos = node.target.global_position
		var target_horiz_pos = Vector2(target_pos.x, target_pos.z)
		var horiz_diff = (target_horiz_pos - horiz_pos).normalized()
		var hit_direction = Vector3(horiz_diff.x, 0.0, horiz_diff.y) * 16.0
		hit_direction += Vector3.UP * 4.0
		if (target_pos - node.global_position).length() < 4.0:
			node.target.velocity += hit_direction
			node.target.hit(30, false)
	await node.anim.animation_finished
	state_machine.enter_state("Idle")

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
		node.rotation.y = lerp_angle(node.rotation.y, -PI / 2 - (target_horiz_pos - horiz_pos).angle(), delta * 4.0)

	var horiz_vel = Vector2(node.velocity.x, node.velocity.z)
	horiz_vel = horiz_vel.move_toward(Vector2.ZERO, node.FRICTION * delta)
	node.velocity = Vector3(horiz_vel.x, node.velocity.y, horiz_vel.y)
	
	node.move_and_slide()

## Called when the state exits.
func exit() -> void:
	pass
