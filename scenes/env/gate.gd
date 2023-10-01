@tool
extends Node3D


var opened: bool = false

@export var properties: Dictionary:
	get:
		return properties
	set(new_properties):
		if properties != new_properties:
			properties = new_properties
			update_properties()

@onready var anim = $AnimationPlayer


## Handle updates to [member properties]
func update_properties() -> void:
	if "rotation" in properties:
		rotation_degrees.y = properties.rotation


func open() -> void:
	anim.play("open")
	$AudioStreamPlayer3D.play()


func _on_open_area_body_entered(body: Node3D) -> void:
	if body is Player:
		if not opened:
			if body.keys > 0:
				body.keys -= 1
				open()
				opened = true
