class_name World extends Node3D

@export var levels: Dictionary
var current_level_node
var current_level: String


func _ready() -> void:
	Game.player_died.connect(reload_level)
	Game.exit_reached.connect(change_level)
	Game.level_loaded.connect(change_level)
	Game.game_ended.connect(clear_level)
	change_level("tutorial")


func reload_level() -> void:
	await get_tree().create_timer(0.5).timeout
	var reloaded_level = levels[current_level].instantiate()
	current_level_node.queue_free()
	add_child(reloaded_level)
	current_level_node = reloaded_level
	Game.loading_finished.emit()


func change_level(level: String) -> void:
	await get_tree().create_timer(0.5).timeout
	if current_level_node:
		current_level_node.queue_free()
	if level in levels:
		var new_level = levels[level].instantiate()
		add_child(new_level)
		current_level_node = new_level
		current_level = level
		Game.loading_finished.emit()
	else:
		Game.loading_finished.emit()
		push_error("No level [%s] found!" % level)


func clear_level() -> void:
	current_level_node.queue_free()
