class_name Player extends CharacterBody3D

signal health_changed(health: int)

const NAIL = preload("res://scenes/nail/nail.tscn")
const NAIL_HIT = preload("res://scenes/vfx/nail_hit_effect.tscn")
const NAIL_IMPACT = preload("res://scenes/nail/nail_impact.tscn")
const SMOKE_PUFF = preload("res://scenes/vfx/smoke_puff.tscn")

const ACCEL = 48
const FRICTION = 64
const AIR_ACCEL = 32
const AIR_FRICTION = 4
const SPEED = 8.0
const JUMP_BUFFER = 0.1
const COYOTE_BUFFER = 0.1
const WALL_JUMP_VELOCITY = 12.5
const JUMP_VELOCITY = 12.0
const MAX_NAILS = 1
const NAIL_GUIDANCE = 16.0
const NAIL_GUIDANCE_RANGE = 4.0
const NAIL_TOSS = 4.0
const ATTACK_COOLDOWN = 0.2
const KICK_COOLDOWN = 0.2
const ACTION_COOLDOWN = 0.4
const PULL_COOLDOWN = 1.0

static var current = self

var wall_jumped = false
var nails_out: Array[Nail] = []
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var health: int = 100
var attack_heat = 0.0
var kick_heat = 0.0
var pull_heat = 0.0
var action_heat = 0.0
var jump_buffer_time = 0.0
var coyote_time = 0.0

var tilt: Vector2 = Vector2.ZERO
var tilt_targ: Vector2 = Vector2.ZERO
var walk_cycle: float = 0.0

var checkpoints: Array[Checkpoint] = []
var keys = 0

@export var properties: Dictionary:
	get:
		return properties
	set(new_properties):
		if properties != new_properties:
			properties = new_properties
			update_properties()

@onready var camera: Camera3D = $Head/Camera3D
@onready var head = $Head
@onready var viewmodel = $Head/Camera3D/Viewmodel
@onready var nail_target: Node3D = $Head/Camera3D/NailTarget
@onready var melee_hitbox: Area3D = $Head/MeleeHitbox
@onready var nail_cast: ShapeCast3D = $Head/Camera3D/NailShapeCast
@onready var nail_raycast: RayCast3D = $Head/Camera3D/NailRayCast
@onready var wall_jump_raycast: RayCast3D = $Head/Camera3D/WallJumpRayCast
@onready var hammer_hit_sound = $HammerHit
@onready var key_sound = $KeyPickup


func _ready() -> void:
	current = self


func _init() -> void:
	add_to_group("player")
	Game.player_added.emit(self)


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	action_heat = move_toward(action_heat, 0.0, delta)
	jump_buffer_time = move_toward(jump_buffer_time, 0.0, delta)
	coyote_time = move_toward(coyote_time, 0.0, delta)
	kick_heat = move_toward(kick_heat, 0.0, delta)
	pull_heat = move_toward(pull_heat, 0.0, delta)
	attack_heat = move_toward(attack_heat, 0.0, delta)
	
	# Handle Jump.
	if Input.is_action_just_pressed("move_jump"):
		if is_on_floor():
			jump()
		elif coyote_time > 0.0:
			jump()
		else:
			jump_buffer_time = JUMP_BUFFER
	
	if is_on_floor() and jump_buffer_time > 0:
		jump()
	
#	# Guide nails toward the front of the camera
#	for nail in nails_out:
#		#var nail = nails_out.back()
#		var horiz_nail = Vector2(nail.global_position.x, nail.global_position.z)
#		var horiz_target = Vector2(nail_target.global_position.x, nail_target.global_position.z)
#		if (horiz_nail - horiz_target).length() < NAIL_GUIDANCE_RANGE:
#			if abs(nail.global_position.y - nail_target.global_position.y) < NAIL_GUIDANCE_RANGE * 2:
#				var guidance = horiz_target - horiz_nail
#				nail.velocity += Vector3(guidance.normalized().x, 0, guidance.normalized().y) * NAIL_GUIDANCE
	
	if nails_out.size() > 0:
		var nail = nails_out.back()
		var guidance: Vector3 = nail.global_position - nail_target.global_position
		if guidance.length() < NAIL_GUIDANCE_RANGE:
			nail.velocity -= guidance.normalized() * NAIL_GUIDANCE * delta
	
	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	var horizontal = Vector2(velocity.x, velocity.z)
	var horizontal_targ = Vector2(direction.x, direction.z) * SPEED
	
	if is_on_floor():
		coyote_time = COYOTE_BUFFER
		wall_jumped = false
		if input_dir.length_squared() > 0:
			horizontal = horizontal.move_toward(horizontal_targ, ACCEL * delta)
		else:
			horizontal = horizontal.move_toward(Vector2.ZERO, FRICTION * delta)
	else:
		if input_dir.length_squared() > 0:
			horizontal = horizontal.move_toward(horizontal_targ, AIR_ACCEL * delta)
		else:
			horizontal = horizontal.move_toward(Vector2.ZERO, AIR_FRICTION * delta)
	
	velocity = Vector3(horizontal.x, velocity.y, horizontal.y)
	
	# Inputs
	if Input.is_action_just_pressed("attack"):
		attack()
	if Input.is_action_just_pressed("secondary_attack"):
		secondary_attack()
	if Input.is_action_just_pressed("pull"):
		pull()
	if Input.is_action_just_pressed("melee"):
		kick()
	
	move_and_slide()


func _process(delta: float) -> void:
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	# Walking camera effects
	tilt_targ = input_dir * 4.0
	tilt = tilt.lerp(tilt_targ, delta * 8.0)
	head.rot_offset = Vector3(-tilt.x, 0.0, 0.0)
	if input_dir.length_squared() > 0 and is_on_floor():
		var bob_height = sin(walk_cycle * 12.0) * 0.5 * camera.global_transform.basis.y.dot(Vector3.UP)
		walk_cycle += delta
		camera.v_offset = lerp(camera.v_offset, bob_height, delta * 3.0)
	else:
		camera.v_offset = lerp(camera.v_offset, 0.0, delta * 3.0)
	viewmodel.position.y = camera.v_offset


func update_properties() -> void:
	pass


func attack() -> void:
	if attack_heat > 0:
		return
	if action_heat > 0:
		return
	
	var bodies = melee_hitbox.get_overlapping_bodies()
	var hit_nail = false
	
	for body in bodies:
		if body is Nail:
			hit_nail = true
			head.play_swing_anim(true)
			body.hit(camera.global_position)
	
	if not hit_nail:
		head.play_swing_anim(false)
		if wall_jump_raycast.is_colliding():
			var new_smoke_puff = SMOKE_PUFF.instantiate()
			add_child(new_smoke_puff)
			new_smoke_puff.global_position = wall_jump_raycast.get_collision_point()
			new_smoke_puff.look_at(new_smoke_puff.global_position + wall_jump_raycast.get_collision_normal())
			new_smoke_puff.emitting = true
	
	if hit_nail:
		nail_flash()
		await Game.hit_lag_ended
		fire_nail()
	
	attack_heat = ATTACK_COOLDOWN


func secondary_attack() -> void:
	if nails_out.size() < MAX_NAILS:
		head.play_toss_anim()
		var new_nail = NAIL.instantiate()
		get_parent().add_child(new_nail)
		new_nail.global_transform = nail_target.global_transform
		new_nail.global_position += new_nail.basis * Vector3(0, -1, 0.5)
		new_nail.transform = new_nail.transform.rotated_local(Vector3.UP, PI)
		new_nail.transform = new_nail.transform.rotated_local(Vector3.RIGHT, deg_to_rad(270))
		new_nail.velocity = velocity - camera.global_transform.basis.z * 0.2 + Vector3.UP * NAIL_TOSS
		
		nails_out.append(new_nail)
		new_nail.tree_exited.connect(func():
			nails_out.erase(new_nail)
			)
		
		action_heat = ACTION_COOLDOWN


func pull() -> void:
	if pull_heat > 0.0:
		return
	
	var pulled: bool = false
	
	for entity in get_tree().get_nodes_in_group("ent"):
		if entity.get("nailed"):
			if (entity.global_position - global_position).length() < 32.0:
				pulled = true
				var pull_dir = (global_position - entity.global_position)
				entity.velocity += pull_dir.normalized() * 12.0 + Vector3.UP * 4.0
				velocity -= pull_dir.normalized() * 4.0
	
	if pulled:
		head.play_pull_anim()
		pull_heat = PULL_COOLDOWN


func kick() -> void:
	if kick_heat > 0.0:
		return
	
	var bodies = melee_hitbox.get_overlapping_bodies()
	var hit_enemy = false
	
	for body in bodies:
		if body.is_in_group("ent"):
			if body.get("nailed"):
				hit_enemy = true
				body.set_collision_layer_value(3, false)
				nail_cast.force_shapecast_update()
				var freed = await body.kill(-camera.global_transform.basis.z)
				head.play_kick_anim(true)
				nail_flash()
				await Game.hit_lag_ended
				velocity.y = 0
				var bounce = camera.global_transform.basis.z * WALL_JUMP_VELOCITY + Vector3.UP * 2.0
				velocity += Vector3(bounce.x, 0, bounce.z)
				velocity.y = max(velocity.y, bounce.y)
				if freed:
					fire_nail()
				else:
					if not body is AngryGhost:
						fire_nail()
					body.set_collision_layer_value(3, true)
	
	if not hit_enemy:
		head.play_kick_anim(false)
	
	kick_heat = KICK_COOLDOWN
	
	# Wallkicks
	if not hit_enemy and not wall_jumped and wall_jump_raycast.is_colliding():
		var surface_normal = wall_jump_raycast.get_collision_normal()
		var bounce_dir = camera.global_transform.basis.z
		var bounce_strength = (1 - pow(abs(surface_normal.dot(Vector3.UP)), 2)) * WALL_JUMP_VELOCITY
		var bounce = bounce_dir * bounce_strength
		var new_smoke_puff = SMOKE_PUFF.instantiate()
		get_parent().add_child(new_smoke_puff)
		new_smoke_puff.global_position = wall_jump_raycast.get_collision_point()
		if abs(surface_normal.dot(Vector3.UP)) < 1:
			new_smoke_puff.look_at(new_smoke_puff.global_position + surface_normal, Vector3.UP)
		new_smoke_puff.emitting = true
		wall_jumped = true
		velocity += Vector3(bounce.x, 0, bounce.z)
		velocity.y = max(velocity.y, bounce.y)


func fire_nail() -> void:
	var hit_ground = null
	var hit_enemy = null
	if nail_raycast.is_colliding():
		var obj_hit = nail_raycast.get_collider()
		if obj_hit.is_in_group("env"):
			hit_ground = nail_raycast.get_collision_point()
	if nail_cast.is_colliding():
		var obj_hit = nail_cast.get_collider(0)
		if obj_hit.is_in_group("ent"):
			hit_enemy = obj_hit
	
	if hit_ground and hit_enemy:
		var ground_dist = (hit_ground - global_position).length()
		var enemy_dist = (hit_enemy.global_position - global_position).length()
		if ground_dist < enemy_dist:
			nail_impact(hit_ground)
		else:
			hit_enemy.hit(-camera.global_transform.basis.z)
	elif hit_ground:
		nail_impact(hit_ground)
	elif hit_enemy:
		hit_enemy.hit(-camera.global_transform.basis.z)
	# make it so it doesn't apply nail to every enemy in shapecast, make it so that closest gets hit by nail (ground or enemy)


func nail_impact(pos: Vector3):
	var new_impact = NAIL_IMPACT.instantiate()
	get_parent().add_child(new_impact)
	new_impact.global_position = pos
	new_impact.global_rotation = camera.global_rotation


func nail_flash() -> void:
	hammer_hit_sound.pitch_scale = randf_range(0.9, 1.1)
	hammer_hit_sound.play()
	Game.hit_lag(10)
	
	var new_hit_effect = NAIL_HIT.instantiate()
	get_parent().add_child(new_hit_effect)
	new_hit_effect.global_transform = camera.global_transform


func hit(amount: int, reset: bool) -> void:
	$Hurt.play()
	health -= amount
	health = max(0, health)
	health_changed.emit(health)
	if health <= 0:
		Game.lost()
	if reset:
		var checkpoint_col = checkpoints.front().get_child(0)
		var points = checkpoint_col.shape.points
		var center = Vector3()
		for point in points:
			center += point
		center /= points.size()
		set_deferred("global_position", center)


func heal(amount: int) -> void:
	health += amount
	health = min(100, health)
	health_changed.emit(health)


func jump() -> void:
	velocity.y = JUMP_VELOCITY
	coyote_time = 0.0
	jump_buffer_time = 0.0
