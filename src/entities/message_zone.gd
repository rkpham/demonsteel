extends Area3D


var message: String = "Test message."
var display_time: float = 1.0
var repeat: bool = false
var entered: bool = false

@export var properties: Dictionary:
	get:
		return properties
	set(new_properties):
		if properties != new_properties:
			properties = new_properties
			update_properties()


## Handle updates to [member properties]
func update_properties() -> void:
	if "message" in properties:
		message = properties.message
	if "repeat" in properties:
		repeat = properties.repeat
	if "display_time" in properties:
		display_time = properties.display_time


func _init() -> void:
	body_entered.connect(on_body_entered)


func on_body_entered(body) -> void:
	if repeat or not entered:
		if body.is_in_group("player"):
			Game.display_message(message, display_time)
			entered = true
