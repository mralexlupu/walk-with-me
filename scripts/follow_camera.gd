extends Camera2D

@export var target_path: NodePath
@export var deadzone: Vector2 = Vector2(120, 70)
@export var follow_speed: float = 6.0

var _target: Node2D

func _ready() -> void:
	if target_path != NodePath(""):
		_target = get_node(target_path)

func _process(delta: float) -> void:
	if not is_instance_valid(_target):
		return
	var to_target := _target.global_position - global_position
	var move := Vector2.ZERO
	if abs(to_target.x) > deadzone.x:
		move.x = sign(to_target.x) * (abs(to_target.x) - deadzone.x)
	if abs(to_target.y) > deadzone.y:
		move.y = sign(to_target.y) * (abs(to_target.y) - deadzone.y)
	var target_pos := global_position + move
	global_position = global_position.lerp(target_pos, clamp(follow_speed * delta, 0.0, 1.0))
