extends Control

@export var game_scene: String = "res://scenes/Main.tscn"

func _ready() -> void:
	$VBox/PlayButton.pressed.connect(_on_play_pressed)
	$VBox/QuitButton.pressed.connect(_on_quit_pressed)

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file(game_scene)

func _on_quit_pressed() -> void:
	get_tree().quit()
