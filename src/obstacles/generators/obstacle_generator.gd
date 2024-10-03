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
@export var do_not_connect: bool = false :
	set(new_value):
		do_not_connect = new_value
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
	if Engine.is_editor_hint():
		return

	if freeze:
		_copy_existing_polygon_to_collisions()
	else:
		refresh()
	_in_game_post_ready_actions()


func refresh() -> void:
	pass


func _in_game_post_ready_actions() -> void:
	pass


func _refresh_deferred() -> void:
	if freeze:
		return

	_pending_refresh = true
	refresh.call_deferred()


func _update_data() -> void:
	if polygons.size() > 1:
		return _update_multiple_polygons()

	_update_single_polygon()


func _update_multiple_polygons() -> void:
	$Display.polygons = []
	$Display.polygons.resize(polygons.size())
	var points: PackedVector2Array = []
	for i in range(polygons.size()):
		var polygon: Polygon = polygons[i]
		var count := points.size()
		points.append_array(polygon.points)
		polygon.collision.polygon = PackedVector2Array(polygon.points)
		$Display.polygons[i] = PackedInt32Array(polygon.index_array(count))
	$Display.polygon = PackedVector2Array(points)


func _update_single_polygon() -> void:
	if not polygons:
		$Display.polygon = PackedVector2Array()
		$Display.polygons.clear()
		return

	var polygon: Polygon = polygons.front()
	var packed_array := PackedVector2Array(polygon.points)
	$Display.polygon = packed_array
	$Display.polygons.clear()
	polygon.collision.polygon = packed_array


func _randf() -> float:
	return randomizer.randf_range(_jagged_range.x, _jagged_range.y)
