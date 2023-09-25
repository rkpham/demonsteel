class_name Checkpoint extends Area3D

var id: int = -1

@export var properties: Dictionary:
	get:
		return properties
	set(new_properties):
		if properties != new_properties:
			properties = new_properties
			update_properties()

## Handle updates to [member properties]
func update_properties() -> void:
	if "id" in properties:
		id = properties.id


func _init() -> void:
	body_entered.connect(on_body_entered)


func on_body_entered(body) -> void:
	if body.is_in_group("player"):
		if not self in body.checkpoints:
			print("Player hit checkpoint %d" % id)
			if body.checkpoints.size() > 0:
				if id > body.checkpoints.front().id:
					body.checkpoints.push_front(self)
				else:
					print("Player got to checkpoint %d before they were supposed to." % id)
			else:
				body.checkpoints.push_front(self)
