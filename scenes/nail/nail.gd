class_name Nail extends CharacterBody3D

const NAIL_IMPACT = preload("res://scenes/nail/nail_impact.tscn")
const GRAVITY = 8.0
const LINE_RADIUS = 0.1
const LINE_RESOLUTION = 16

var been_hit = false

@onready var model = $Model


func _physics_process(delta: float) -> void:
	velocity.y -= GRAVITY * delta
	
	var collision = move_and_collide(velocity * delta)
	
	if collision:
		if collision.get_normal().dot(Vector3.UP) < 0.4:
			velocity = velocity.bounce(collision.get_normal(0)) * 0.5
		else:
			if not been_hit:
				var new_nail_impact = NAIL_IMPACT.instantiate()
				var hit_point = collision.get_position(0)
				get_parent().add_child(new_nail_impact)
				new_nail_impact.global_position = hit_point
				new_nail_impact.look_at(hit_point - collision.get_normal(0), Vector3.FORWARD)
				queue_free()


func _process(delta: float) -> void:
	model.rotate_object_local(Vector3.RIGHT, delta * 4)
	var circle = PackedVector2Array()


func hit(from) -> void:
	been_hit = true
	model.look_at(from, Vector3.UP, true)
	await Game.hit_lag_ended
	queue_free()


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("env"):
		queue_free()
