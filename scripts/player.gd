extends CharacterBody2D

# Simple side-scroller movement with coyote time and jump buffering for smoother feel.
@export var move_speed: float = 250.0
@export var jump_velocity: float = -520.0
@export var gravity: float = 1600.0
@export var coyote_time: float = 0.12
@export var jump_buffer_time: float = 0.15

var _coyote_timer := 0.0
var _jump_buffer_timer := 0.0

func _physics_process(delta: float) -> void:
	var direction := Input.get_axis("ui_left", "ui_right")
	velocity.x = direction * move_speed

	if not is_on_floor():
		velocity.y += gravity * delta
		_coyote_timer -= delta
	else:
		_coyote_timer = coyote_time

	if Input.is_action_just_pressed("ui_accept"):
		_jump_buffer_timer = jump_buffer_time
	else:
		_jump_buffer_timer -= delta

	if _jump_buffer_timer > 0.0 and _coyote_timer > 0.0:
		velocity.y = jump_velocity
		_jump_buffer_timer = 0.0
		_coyote_timer = 0.0

	move_and_slide()

	var sprite := $Sprite2D
	if direction != 0.0:
		sprite.flip_h = direction < 0.0
