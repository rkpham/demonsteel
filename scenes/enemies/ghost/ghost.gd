class_name Ghost extends CharacterBody3D

enum BEHAVIOR {
	IDLE,
	RELOCATING,
}

const GHOST_BODY = preload("res://scenes/enemies/ghost/ghost_body.tscn")
const GHOST_PUFF = preload("res://scenes/vfx/ghost_puff.tscn")
const ACCEL = 48
const FRICTION = 12
const AIR_ACCEL = 32
const AIR_FRICTION = 4
const SPEED = 4.0

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var nailed = false
var player_in_zone: bool = false
var alert: bool = false
var current_behavior = BEHAVIOR.IDLE
var blind: bool = false
var target

@export var properties: Dictionary:
	get:
		return properties
	set(new_properties):
		if properties != new_properties:
			properties = new_properties
			update_properties()

@onready var nail_model = $NailModel
@onready var anim: AnimationPlayer = $Model/AnimationPlayer
@onready var model: Node3D = $Model
@onready var sight_cast: RayCast3D = $Sight
@onready var nav = $NavigationAgent3D
@onready var state_machine = $StateMachine


func _ready() -> void:
	pass


func _physics_process(delta):
	if not sight_cast.is_colliding() and player_in_zone and not blind:
		alert = true
	else:
		alert = false


func update_properties() -> void:
	if "blind" in properties:
		blind = true if properties.blind != 0 else false


func hit(direction) -> void:
	nail_model.look_at(global_transform.origin + direction, Vector3.UP)
	nail_model.visible = true
	nailed = true
	velocity += direction * 8.0
	var new_ghost_puff = GHOST_PUFF.instantiate()
	add_child(new_ghost_puff)
	new_ghost_puff.emit()
	state_machine.enter_state("Hit")


func kill(direction) -> bool:
	var new_body = GHOST_BODY.instantiate()
	new_body.global_transform = global_transform
	get_parent().add_child(new_body)
	new_body.fling(-direction)
	queue_free()
	return true


func dash() -> void:
	pass


func _on_alert_body_entered(body: Node3D) -> void:
	if body is Player:
		player_in_zone = true
		target = body


func _on_alert_body_exited(body: Node3D) -> void:
	if body is Player:
		player_in_zone = false
		target = null
