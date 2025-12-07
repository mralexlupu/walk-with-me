extends Area2D

var collected := false

func _ready() -> void:
	add_to_group("coin")
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body: Node) -> void:
	if collected:
		return
	if not body is CharacterBody2D:
		return
	collected = true
	get_tree().call_group("game_manager", "_on_coin_collected", self)
	queue_free()
