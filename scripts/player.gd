extends CharacterBody2D

# Simple side-scroller movement with coyote time and jump buffering for smoother feel.
@export var move_speed: float = 250.0
@export var jump_velocity: float = -520.0
@export var gravity: float = 1600.0
@export var coyote_time: float = 0.12
@export var jump_buffer_time: float = 0.15
@export var squash_scale := Vector2(1.15, 0.85)
@export var squash_duration := 0.12
@export var land_scale := Vector2(0.9, 1.1)
@export var land_duration := 0.1
@export var footstep_interval := 0.32
@export var footstep_speed_threshold := 24.0
@export var input_locked := false

var _coyote_timer := 0.0
var _jump_buffer_timer := 0.0
var _footstep_timer := 0.0
var _default_scale := Vector2.ONE
var _current_animation := ""

@onready var _anim: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	var was_on_floor := is_on_floor()

	var direction := Input.get_axis("ui_left", "ui_right") if not input_locked else 0.0
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
		_play_jump_effects()

	move_and_slide()

	if direction != 0.0 and _anim:
		_anim.flip_h = direction < 0.0

	_update_animation(direction)

	_handle_land_effects(was_on_floor)
	_handle_footsteps(delta, direction)

func reset_state(position: Vector2) -> void:
	global_position = position
	velocity = Vector2.ZERO
	scale = _default_scale
	_footstep_timer = 0.0
	input_locked = false

func _ready() -> void:
	_default_scale = scale

func _handle_land_effects(was_on_floor: bool) -> void:
	var landed := not was_on_floor and is_on_floor()
	if landed:
		_play_land_effects()

func _handle_footsteps(delta: float, direction: float) -> void:
	if not is_on_floor() or abs(direction) * move_speed < footstep_speed_threshold:
		_footstep_timer = footstep_interval
		return
	_footstep_timer -= delta
	if _footstep_timer <= 0.0:
		_footstep_timer = footstep_interval
		_play_footstep()

func _play_jump_effects() -> void:
	if has_node("JumpDust"):
		var particles: CPUParticles2D = $JumpDust
		particles.restart()
	if has_node("SFXJump"):
		$SFXJump.play()
	_apply_squash(squash_scale, squash_duration)

func _play_land_effects() -> void:
	if has_node("LandDust"):
		var particles: CPUParticles2D = $LandDust
		particles.restart()
	if has_node("SFXLand"):
		$SFXLand.play()
	_apply_squash(land_scale, land_duration)

func _play_footstep() -> void:
	if has_node("SFXFootstep"):
		var player: AudioStreamPlayer2D = $SFXFootstep
		player.pitch_scale = randf_range(0.9, 1.1)
		player.play()

func _apply_squash(target_scale: Vector2, duration: float) -> void:
	var tween := get_tree().create_tween()
	tween.tween_property(self, "scale", _default_scale * target_scale, duration).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "scale", _default_scale, duration * 1.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)

func _update_animation(direction: float) -> void:
	if not _anim:
		return
	var on_floor := is_on_floor()
	var target := ""
	if not on_floor:
		target = "jump"
	elif abs(direction) > 0.1:
		target = "run"
	else:
		target = "idle"
	if target != _current_animation:
		_current_animation = target
		_anim.play(target)

func set_input_locked(locked: bool) -> void:
	input_locked = locked
