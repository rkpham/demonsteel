extends RigidBody3D

@onready var mesh = $Model/Armature/Skeleton3D/Cube_006

func _ready() -> void:
	$Model/AnimationPlayer.play("Fling")
	var tween = create_tween()
	tween.tween_property(mesh, "transparency", 1.0, 4.0)
	await tween.finished
	queue_free()


func fling(dir: Vector3) -> void:
	apply_central_impulse(-dir * 16.0 + Vector3.UP * 4.0)
	var rot = Vector3(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0), randf_range(-1.0, 1.0))
	apply_torque_impulse(rot)
