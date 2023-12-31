class_name UserInterface extends Control

const START_UP_MULT = 1.0

@onready var health_label = $HUD/HealthHUD/HealthLabel
@onready var message_box = $HUD/MessageCenter/MessageOffset/Message
@onready var hit_flash = $Flash
@onready var fps_label = $HUD/FPS
@onready var fade = $FadeInOut


func _ready() -> void:
	Game.hit_lag_started.connect(func():
		hit_flash.visible = true
		)
	Game.hit_lag_ended.connect(func():
		hit_flash.visible = false
		)
	Game.player_died.connect(_on_player_death)
	Game.exit_reached.connect(_on_exit_reached)
	Game.loading_finished.connect(_on_loading_finished)
	Game.popup_msg.connect(_on_show_message)
	Game.started_up.connect(_on_start_up)
	Game.game_ended.connect(_on_game_ended)
	Game.player_added.connect(_on_player_added)


func _process(delta: float) -> void:
	fps_label.text = str(Engine.get_frames_per_second())
	if Input.is_action_just_pressed("ui_cancel"):
		show_pause_menu(not $HUD/Pause.visible)


func screen_fade(out: bool) -> void:
	var fade_material: ShaderMaterial = fade.material
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	if out:
		fade_material.set_shader_parameter("left", 0.0)
		fade_material.set_shader_parameter("right", 0.0)
		tween.tween_property(fade_material, "shader_parameter/right", 1.1, 0.5)
	else:
		fade_material.set_shader_parameter("left", 0.0)
		fade_material.set_shader_parameter("right", 1.1)
		tween.tween_property(fade_material, "shader_parameter/left", 1.1, 0.5)
	await tween.finished


func show_pause_menu(show: bool) -> void:
	$HUD/Pause.visible = show
	get_tree().paused = show
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if show else Input.MOUSE_MODE_CAPTURED


func _on_health_changed(health: int) -> void:
	health_label.text = str(health)


func _on_show_message(msg: String, time: float) -> void:
	$Ding.play()
	var tween = create_tween()
	message_box.text = msg.c_unescape()
	tween.tween_property(message_box, "modulate", Color.WHITE, 0.5)
	await tween.finished
	await get_tree().create_timer(time).timeout
	tween = create_tween()
	tween.tween_property(message_box, "modulate", Color.TRANSPARENT, 0.5)


func _on_start_up() -> void:
	$MainMenu/GodotIcon.show()
	$MainMenu/Bell.play()
	await get_tree().create_timer(START_UP_MULT).timeout
	$MainMenu/GodotIcon.hide()

	await get_tree().create_timer(START_UP_MULT).timeout
	$MainMenu/Author.show()
	$MainMenu/Bell.play()
	await get_tree().create_timer(START_UP_MULT).timeout
	$MainMenu/Author.hide()

	await get_tree().create_timer(START_UP_MULT).timeout
	$MainMenu/Title.show()
	$MainMenu/Bell.play()
	await get_tree().create_timer(START_UP_MULT).timeout
	$MainMenu/Title.hide()

	await get_tree().create_timer(START_UP_MULT).timeout
	$MainMenu.hide()
	pass


func _on_player_death() -> void:
	screen_fade(true)
	_on_health_changed(100)


func _on_exit_reached(level) -> void:
	screen_fade(true)


func _on_loading_finished() -> void:
	await get_tree().create_timer(1).timeout
	screen_fade(false)


func _on_player_added(player: Player) -> void:
	player.health_changed.connect(_on_health_changed)


func _on_back_button_pressed() -> void:
	show_pause_menu(false)


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_game_ended() -> void:
	await screen_fade(true)
	$EndSlides.show()
	$EndMusic.play()
	for slide in $EndSlides.get_children():
		if not slide is ColorRect:
			$Ding.play()
			slide.show()
			var slide_timer: Timer = slide.get_node("Timer")
			slide_timer.start()
			await slide_timer.timeout
			slide.hide()
	get_tree().quit()


func _on_h_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(0, value)


func _on_sens_slider_value_changed(value: float) -> void:
	Game.sens_changed.emit(value)
