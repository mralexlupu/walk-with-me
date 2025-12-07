extends Area2D

signal reached(position: Vector2)

var _activated := false

@onready var flag := $Flag

func _ready() -> void:
	add_to_group("checkpoint")
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body: Node) -> void:
	if _activated:
		return
	if not body is CharacterBody2D:
		return
	_activate()

func _activate() -> void:
	_activated = true
	if flag:
		flag.modulate = Color(0.2, 0.9, 0.6, 1)
		flag.scale = Vector2(1.05, 1.05)
	reached.emit(global_position)
	get_tree().call_group("game_manager", "_on_checkpoint_reached", global_position)
