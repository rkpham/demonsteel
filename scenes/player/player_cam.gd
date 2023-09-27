extends Node3D

const MAX_VIEWMODEL_ROT = Vector2(15, 15)

@export var body: Node3D
@export var sensitivity: float = 0.1

var rot = Vector2()
var rot_offset = Vector3()

var viewmodel_rot = Vector2()

@onready var viewmodel = $Camera3D/Viewmodel
@onready var hammer_anim = $Camera3D/Viewmodel/Hammer/AnimationPlayer
@onready var leg_model = $Camera3D/Viewmodel/Leg
@onready var kick_anim = $Camera3D/Viewmodel/Leg/AnimationPlayer


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	hammer_anim.play("Idle")

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		event.relative *= sensitivity
		rot.x -= event.relative.x
		rot.y -= event.relative.y
		rot.y = clamp(rot.y, -89, 89)
		
		viewmodel_rot += event.relative
		viewmodel_rot = viewmodel_rot.clamp(-MAX_VIEWMODEL_ROT, MAX_VIEWMODEL_ROT)


func _process(delta: float) -> void:
	set_cam_rot(rot, rot_offset)
	
	viewmodel.rotation.x = deg_to_rad(viewmodel_rot.y)
	viewmodel.rotation.y = deg_to_rad(viewmodel_rot.x)
	
	viewmodel_rot = viewmodel_rot.lerp(Vector2.ZERO, delta * 16.0)


func play_swing_anim(hit_nail) -> void:
	hammer_anim.stop()
	hammer_anim.play("Swing")
	if hit_nail:
		hammer_anim.advance(0.01)
	await hammer_anim.animation_finished
	hammer_anim.play("Idle")


func play_kick_anim(hit_nail) -> void:
	leg_model.show()
	kick_anim.stop()
	kick_anim.play("Kick")
	if hit_nail:
		kick_anim.advance(0.14)
	await kick_anim.animation_finished
	leg_model.hide()


func set_cam_rot(vec: Vector2, offset: Vector3) -> void:
	if body:
		body.rotation.y = deg_to_rad(vec.x + offset.y)
	rotation.x = deg_to_rad(vec.y + offset.z)
	rotation.z = deg_to_rad(offset.x)
