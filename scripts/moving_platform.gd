extends AnimatableBody2D

@export var start_offset := Vector2.ZERO
@export var end_offset := Vector2(0, -120)
@export var speed: float = 70.0

var _origin := Vector2.ZERO
var _forward := true

func _ready() -> void:
	_origin = global_position

func _physics_process(delta: float) -> void:
	if speed <= 0.0:
		return
	var target := _origin + (end_offset if _forward else start_offset)
	var to_target := target - global_position
	var distance := to_target.length()
	if distance <= speed * delta:
		global_position = target
		_forward = not _forward
	else:
		global_position += to_target.normalized() * speed * delta
