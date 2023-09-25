extends StaticBody3D


func _init() -> void:
	add_to_group("env")
	set_collision_layer_value(2, true)
