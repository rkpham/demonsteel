class_name UserInterface extends Control

const START_UP_MULT = 0.1

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
	Game.player_added.connect(_on_player_added)


func _process(delta: float) -> void:
	fps_label.text = str(Engine.get_frames_per_second())


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


func _on_player_death() -> void:
	screen_fade(true)


func _on_exit_reached(level) -> void:
	screen_fade(true)


func _on_loading_finished() -> void:
	await get_tree().create_timer(1).timeout
	screen_fade(false)


func _on_player_added(player: Player) -> void:
	player.health_changed.connect(_on_health_changed)
