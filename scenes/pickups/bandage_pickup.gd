extends Area3D


func _ready() -> void:
	$AnimationPlayer.play("spin")


func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		body.heal(20)
		queue_free()
