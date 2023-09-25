class_name GhostLantern extends CharacterBody3D

var nailed = false

const LANTERN_PUFF = preload("res://scenes/vfx/lantern_puff.tscn")

@export var properties: Dictionary:
	get:
		return properties
	set(new_properties):
		if properties != new_properties:
			properties = new_properties
			update_properties()

@onready var nail_model = $NailModel
@onready var model: Node3D = $Model


func _physics_process(delta):
	pass


func update_properties() -> void:
	pass


func hit(direction) -> void:
	nail_model.look_at(global_position + direction, Vector3.UP)
	nail_model.visible = true
	nailed = true
	var new_ghost_puff = LANTERN_PUFF.instantiate()
	add_child(new_ghost_puff)
	new_ghost_puff.look_at(new_ghost_puff.global_position + direction)
	new_ghost_puff.emit()


func kill(direction) -> bool:
	nail_model.visible = false
	nailed = false
	var new_ghost_puff = LANTERN_PUFF.instantiate()
	add_child(new_ghost_puff)
	new_ghost_puff.look_at(new_ghost_puff.global_position + direction)
	new_ghost_puff.emit()
	return false
