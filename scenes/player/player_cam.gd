extends Node3D


@export var body: Node3D
@export var sensitivity: float = 0.5

var rot = Vector2()


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		event.relative *= sensitivity
		rot.x -= event.relative.x
		rot.y -= event.relative.y
		rot.y = clamp(rot.y, -90, 90)
		set_cam_rot(rot)


func set_cam_rot(vec: Vector2) -> void:
	if body:
		body.rotation.y = deg_to_rad(vec.x)
	rotation.x = deg_to_rad(vec.y)
