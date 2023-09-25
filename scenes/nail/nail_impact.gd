extends Node3D

const MAX_IMPACTS = 256

static var impacts = []

func _ready() -> void:
	$AudioStreamPlayer3D.pitch_scale = randf_range(0.9, 1.1)
	$SmokePuff.emitting = true
	impacts.push_front(self)
	if impacts.size() > MAX_IMPACTS:
		impacts.pop_back().queue_free()
