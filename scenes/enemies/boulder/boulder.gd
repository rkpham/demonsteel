class_name Boulder extends CharacterBody3D

var nailed = false

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
	nail_model.visible = true
	nailed = true


func kill(direction) -> bool:
	nail_model.visible = false
	nailed = false
	return false
