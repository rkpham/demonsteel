extends Area3D


var next_level: String = "tutorial"


@export var properties: Dictionary:
	get:
		return properties
	set(new_properties):
		if properties != new_properties:
			properties = new_properties
			update_properties()


## Handle updates to [member properties]
func update_properties() -> void:
	if "next_level" in properties:
		next_level = properties.next_level


func _init() -> void:
	body_entered.connect(on_body_entered)


func on_body_entered(body) -> void:
	if body.is_in_group("player"):
		Game.load_next_level(next_level)
