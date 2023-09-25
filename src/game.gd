extends Node

signal hit_lag_started()
signal hit_lag_ended()
signal player_died()
signal started_up()
signal exit_reached(level: String)
signal player_added(player: Player)
signal level_loaded(level: String)
signal loading_finished()
signal popup_msg(msg: String, time: float)

var hit_lag_left: int = 0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	Engine.max_fps = DisplayServer.screen_get_refresh_rate()


func _physics_process(delta: float) -> void:
	if hit_lag_left <= 0:
		get_tree().paused = false
		hit_lag_ended.emit()
	if hit_lag_left > 0:
		hit_lag_left -= 1


func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()


func display_message(msg: String, time: float) -> void:
	popup_msg.emit(msg, time)


func hit_lag(frames: int) -> void:
	hit_lag_started.emit()
	get_tree().paused = true
	hit_lag_left = frames


func lost() -> void:
	player_died.emit()


func load_level(id: int) -> void:
	level_loaded.emit(id)


func load_next_level(level: String) -> void:
	exit_reached.emit(level)


func start_up() -> void:
	started_up.emit()
