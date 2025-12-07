extends Node2D

@export var respawn_position: Vector2
@export var fade_duration := 0.18
@export var camera_shake_strength := 8.0

var coins_collected := 0
var coins_total := 0
var _game_finished := false

@onready var player := $"World/Player"
@onready var ui_label := $"UI/CoinLabel"
@onready var fade_rect := $"UI/FadeRect"
@onready var volume_slider := $"UI/VolumeSlider"
@onready var camera := $"World/Camera2D"
@onready var hazard_sfx := $"SFX/Hazard"
@onready var coin_sfx := $"SFX/Coin"
@onready var checkpoint_sfx := $"SFX/Checkpoint"
@onready var bgm := $"SFX/BGM"
@onready var title_card := $"UI/TitleCard"
@onready var message_label := $"UI/MessageLabel"
@onready var ending_panel := $"UI/EndingPanel"

func _ready() -> void:
	randomize()
	add_to_group("game_manager")
	if respawn_position == Vector2.ZERO:
		respawn_position = player.global_position
	coins_total = get_tree().get_nodes_in_group("coin").size()
	_update_ui()

	for hazard in get_tree().get_nodes_in_group("hazard"):
		hazard.connect("body_entered", Callable(self, "_on_hazard_body_entered"))
	for checkpoint in get_tree().get_nodes_in_group("checkpoint"):
		checkpoint.connect("reached", Callable(self, "_on_checkpoint_reached"))

	if volume_slider:
		volume_slider.value = -12.0
		volume_slider.connect("value_changed", Callable(self, "_on_volume_slider_value_changed"))
		_on_volume_slider_value_changed(volume_slider.value)
	if bgm and not bgm.playing and bgm.stream:
		bgm.play()
	await _show_intro()

func respawn_player() -> void:
	if not player:
		return
	if player.has_method("reset_state"):
		player.reset_state(respawn_position)
	else:
		player.global_position = respawn_position
		player.velocity = Vector2.ZERO

func _on_hazard_body_entered(body: Node) -> void:
	if body == player and not _game_finished:
		await _death_sequence()

func _on_coin_collected(_coin: Node) -> void:
	coins_collected += 1
	_update_ui()
	_play_coin_sfx()
	if coins_collected >= coins_total and not _game_finished:
		await _on_all_coins_collected()

func _update_ui() -> void:
	if not ui_label:
		return
	ui_label.text = "Coins: %d / %d" % [coins_collected, coins_total]

func _on_checkpoint_reached(position: Vector2) -> void:
	respawn_position = position
	_play_checkpoint_sfx()
	await _show_message("Checkpoint reached", 1.6)

func _death_sequence() -> void:
	_play_hazard_sfx()
	if camera:
		await _shake_camera()
	if fade_rect:
		await _fade_to(0.6)
	respawn_player()
	if fade_rect:
		await _fade_to(0.0)

func _fade_to(alpha: float) -> void:
	if not fade_rect:
		return
	var tween := get_tree().create_tween()
	tween.tween_property(fade_rect, "modulate:a", alpha, fade_duration)
	await tween.finished

func _shake_camera() -> void:
	if not camera:
		return
	var original_offset: Vector2 = camera.offset
	var tween := get_tree().create_tween()
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	for i in 4:
		var offset := Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * camera_shake_strength
		tween.tween_property(camera, "offset", original_offset + offset, 0.05)
	tween.tween_property(camera, "offset", original_offset, 0.06)
	await tween.finished

func _play_hazard_sfx() -> void:
	if hazard_sfx and hazard_sfx.stream:
		hazard_sfx.play()

func _play_coin_sfx() -> void:
	if coin_sfx and coin_sfx.stream:
		coin_sfx.play()

func _play_checkpoint_sfx() -> void:
	if checkpoint_sfx and checkpoint_sfx.stream:
		checkpoint_sfx.play()

func _on_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(0, value)

func _show_intro() -> void:
	if not title_card:
		return
	title_card.visible = true
	title_card.modulate.a = 1.0
	await get_tree().create_timer(1.6).timeout
	await _fade_control(title_card, 0.0, 0.6, false)

func _show_message(text: String, duration: float) -> void:
	if not message_label:
		return
	message_label.text = text
	message_label.modulate.a = 0.0
	message_label.visible = true
	await _fade_control(message_label, 1.0, 0.2, true)
	await get_tree().create_timer(duration).timeout
	await _fade_control(message_label, 0.0, 0.3, false)

func _on_all_coins_collected() -> void:
	_game_finished = true
	await _show_message("All coins collected", 1.5)
	if player and player.has_method("set_input_locked"):
		player.set_input_locked(true)
	if ending_panel:
		ending_panel.visible = true
		await _fade_control(ending_panel, 1.0, 0.5, true)

func _fade_control(control: CanvasItem, target_alpha: float, duration: float, stay_visible: bool) -> void:
	if not control:
		return
	control.visible = true
	var tween := get_tree().create_tween()
	tween.tween_property(control, "modulate:a", target_alpha, duration)
	await tween.finished
	if target_alpha == 0.0 and not stay_visible:
		control.visible = false
