class_name GhostHit extends State


## Called when a state is entered.
func enter() -> void:
	node.anim.play("Fling")
	await get_tree().create_timer(1).timeout
	if node.is_on_floor():
		state_machine.enter_state("Idle")

## Called in state machine's _process function.
func run(delta) -> void:
	pass

## Called in state machine's _physics_process function.
func run_physics(delta) -> void:
	# Add the gravity.
	if not node.is_on_floor():
		node.velocity.y -= node.gravity * delta

	var horiz_vel = Vector2(node.velocity.x, node.velocity.z)
	horiz_vel = horiz_vel.move_toward(Vector2.ZERO, node.FRICTION * delta)
	node.velocity = Vector3(horiz_vel.x, node.velocity.y, horiz_vel.y)
	
	node.move_and_slide()

## Called when the state exits.
func exit() -> void:
	pass
