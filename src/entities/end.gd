extends Area3D


@export var properties: Dictionary:
	get:
		return properties
	set(new_properties):
		if properties != new_properties:
			properties = new_properties
			update_properties()


## Handle updates to [member properties]
func update_properties() -> void:
	pass


func _init() -> void:
	body_entered.connect(on_body_entered)


func on_body_entered(body) -> void:
	if body.is_in_group("player"):
		Game.end_game()
