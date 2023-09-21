extends CharacterBody3D

const ACCEL = 0.8
const FRICTION = 0.5
const AIR_ACCEL = 0.1
const AIR_FRICTION = 0.1
const SPEED = 12.0
const JUMP_VELOCITY = 4.5

@export var camera: Camera3D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("move_jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	var horizontal = Vector2(velocity.x, velocity.z)
	var horizontal_targ = Vector2(direction.x, direction.z) * SPEED
	
	if is_on_floor():
		if input_dir.length_squared() > 0:
			horizontal = horizontal.move_toward(horizontal_targ, ACCEL)
		else:
			horizontal = horizontal.move_toward(Vector2.ZERO, FRICTION)
	else:
		if input_dir.length_squared() > 0:
			horizontal = horizontal.move_toward(horizontal_targ, AIR_ACCEL)
		else:
			horizontal = horizontal.move_toward(Vector2.ZERO, AIR_FRICTION)
	
	velocity = Vector3(horizontal.x, velocity.y, horizontal.y)

	move_and_slide()
