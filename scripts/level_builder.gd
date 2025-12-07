extends TileMap

@export var tile_size: int = 32
@export var ground_y: int = 8

func _ready() -> void:
	if tile_set == null:
		tile_set = _build_tile_set()
	_build_level()

func _build_tile_set() -> TileSet:
	var tex: Texture2D = load("res://assets/ground.png")
	var atlas := TileSetAtlasSource.new()
	atlas.texture = tex
	atlas.texture_region_size = Vector2i(tile_size, tile_size)
	atlas.create_tile(Vector2i(0, 0))
	var set := TileSet.new()
	set.add_source(atlas, 0)
	return set

func _build_level() -> void:
	_clear_existing()
	# Main ground strip with small pits
	_add_platform(-5, 35, ground_y)
	_add_platform(40, 110, ground_y)
	# Elevated and staggered platforms
	_add_platform(8, 14, ground_y - 3)
	_add_platform(20, 26, ground_y - 5)
	_add_platform(48, 54, ground_y - 2)
	_add_platform(62, 66, ground_y - 4)
	_add_platform(76, 82, ground_y - 6)
	_add_platform(94, 100, ground_y - 3)

func _clear_existing() -> void:
	clear()
	for child in get_parent().get_children():
		if child is StaticBody2D and child.has_meta("generated_platform"):
			child.queue_free()

func _add_platform(x_start: int, x_end: int, y: int) -> void:
	for x in range(x_start, x_end + 1):
		set_cell(0, Vector2i(x, y), 0, Vector2i.ZERO)
	_create_collider(x_start, x_end, y)

func _create_collider(x_start: int, x_end: int, y: int) -> void:
	var body := StaticBody2D.new()
	body.set_meta("generated_platform", true)
	body.collision_layer = 1
	body.collision_mask = 1

	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	var width := float(x_end - x_start + 1) * tile_size
	rect.extents = Vector2(width * 0.5, tile_size * 0.5)
	shape.shape = rect

	var local_pos := map_to_local(Vector2i(x_start, y)) + Vector2(width * 0.5, tile_size * 0.5)
	body.global_position = to_global(local_pos)
	body.add_child(shape)

	get_parent().add_child(body)
