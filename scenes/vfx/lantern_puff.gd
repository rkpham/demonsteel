extends GPUParticles3D


func emit() -> void:
	emitting = true
	$Sparks.emitting = true
	await get_tree().create_timer(4).timeout
	queue_free()
