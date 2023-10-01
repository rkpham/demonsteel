extends Area3D


var damage: int = 1

@export var properties: Dictionary:
	get:
		return properties
	set(new_properties):
		if properties != new_properties:
			properties = new_properties
			update_properties()


## Handle updates to [member properties]
func update_properties() -> void:
	if 'damage' in properties:
		damage = properties.damage


func _init() -> void:
	body_entered.connect(on_body_entered)
	set_collision_mask_value(4, true)
	set_collision_mask_value(3, true)


func on_body_entered(body) -> void:
	if body is Player:
		body.hit(damage, true)
	if body.is_in_group("ent"):
		body.queue_free()
	if body is Nail:
		body.queue_free()
