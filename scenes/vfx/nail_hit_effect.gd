extends Node3D

func _ready() -> void:
	$GPUParticles3D.emitting = true
	$GPUParticles3D2.emitting = true
	await get_tree().create_timer(4).timeout
	queue_free()
