@tool
extends Obstacle
class_name ObstacleGenerator

@export var density := Density.HIGH :
	set(new_density):
		density = new_density
		_refresh_deferred()
@export_range(0.0, 1.0) var jaggedness: float = 0.0 :
	set(new_jaggedness):
		jaggedness = new_jaggedness
		_jagged_range = Vector2(-0.5, 0.5) * jaggedness
		_refresh_deferred()
@export var freeze: bool = true:
	set(new_freeze):
		freeze = new_freeze
@export var random_seed: int = 1 :
	set(new_seed):
		random_seed = new_seed
		randomizer.seed = new_seed
		randomizer.randomize()
		_refresh_deferred()
@export var randomize_seed: bool = false :
	set(new_value):
		if not new_value:
			return

		random_seed = randi()
@export var call_refresh: bool = false :
	set(new_value):
		if not new_value:
			return

		var old_freeze := freeze
		freeze = false
		_refresh_deferred()
		freeze = old_freeze


enum Density {
	TRIANGLE = 3,
	SQUARE = 4,
	PENTAGON = 5,
	HEXAGON = 6,
	OCTAGON = 8,
	NONAGON = 9,
	DECAGON = 10,
	DODECAGON = 12,
	LOW = 15,
	MID = 20,
	HIGH = 36,
	SUPERHIGH = 72,
}

var _pending_refresh: bool = false
var _jagged_range := Vector2.ZERO


func _ready() -> void:
	if freeze:
		_copy_existing_polygon_to_collisions()
	else:
		_refresh_deferred()

	if Engine.is_editor_hint():
		return

	_in_game_post_ready_actions()


func refresh() -> void:
	if not _pending_refresh:
		return

	_refresh()
	_copy_existing_polygon_to_collisions()
	_pending_refresh = false


func _refresh() -> void:
	pass


func _in_game_post_ready_actions() -> void:
	pass


func _refresh_deferred() -> void:
	if freeze:
		return

	_pending_refresh = true
	_is_manual_editing = false
	refresh.call_deferred()


func _resize_polygon(target_size: int) -> void:
	if target_size == 1:
		target_size = 0
	var diff := target_size - polygons.size()
	polygons.resize(target_size)
	if diff > 0:
		for i in range(diff):
			var x: Array[int] = []
			polygons[i] = x


func _update_polygon(polygon_index: int, start_index: int, count: int) -> void:
	if not polygons:
		return

	var p: Array[int] = polygons[polygon_index]
	p.resize(count)
	for i in range(count):
		var n := i + start_index
		p[i] = n


func _build_polygon_shape(
	inner_points: Array[Vector2],
	outer_points: Array[Vector2],
) -> PackedVector2Array:
	var points: PackedVector2Array = []
	points.append_array(inner_points)
	outer_points.reverse()
	points.append_array(outer_points)
	inner_points.clear()
	outer_points.clear()
	return points


func _randf() -> float:
	return randomizer.randf_range(_jagged_range.x, _jagged_range.y)
