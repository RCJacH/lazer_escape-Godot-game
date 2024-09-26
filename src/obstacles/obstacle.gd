@tool
extends StaticBody2D
class_name Obstacle

@export var density := Density.HIGH :
	set(new_density):
		density = new_density
		_refresh_deferred()
@export_range(0.0, 1.0) var jaggedness: float = 0.1 :
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
		random_seed = randi()
@export var call_refresh: bool = false :
	set(new_value):
		_refresh_deferred()


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

var polygons: Array[Polygon] = []
var randomizer := RandomNumberGenerator.new()

var _pending_refresh: bool = false
var _jagged_range := Vector2.ZERO
var _polygon_count: int = 0 :
	set(new_polygon_count):
		_polygon_count = new_polygon_count
		_update_polygons(_polygon_count)


func _ready() -> void:
	if freeze:
		_copy_existing_polygon_to_collisions()


func refresh() -> void:
	pass


func _add_polygon(ref: Node = null) -> Polygon:
	var polygon := Polygon.new()
	if ref:
		polygon.ref_node = ref
	polygons.append(polygon)
	add_child.call_deferred(polygon.collision)
	return polygon


func _remove_polygon(ref: Node = null) -> void:
	if not polygons:
		return

	var polygon: Polygon
	if ref:
		for i in polygons.size():
			polygon = polygons[i]
			if polygon.ref_node == ref:
				polygons.pop_at(i)
				break
		return

	else:
		polygon = polygons.pop_back()
	polygon.queue_free()


func _update_data() -> void:
	if polygons.size() > 1:
		return _update_multiple_polygons()

	_update_single_polygon()


func _update_multiple_polygons() -> void:
	$Display.polygons = []
	$Display.polygons.resize(polygons.size())
	var points: Array[Vector2] = []
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


func _copy_existing_polygon_to_collisions() -> void:
	if not polygons:
		return

	if polygons.size() == 1:
		var polygon: Polygon = polygons.front()
		polygon.points = $Display.polygon
		polygon.collision.polygon = $Display.polygon
		return

	for i in range(polygons.size()):
		var polygon: Polygon = polygons[i]
		var points: PackedVector2Array = []
		var count: int = $Display.polygons[i].size()
		points.resize(count)
		for j in range(count):
			var index: int = $Display.polygons[i][j]
			points[j] = $Display.polygon[index]
		polygon.points = points
		polygon.collision.polygon = points


func _update_polygons(new_count: int) -> void:
	var cur_count := polygons.size()
	var diff := new_count - cur_count
	if diff >= 0:
		for i in range(diff):
			_add_polygon()
	elif diff <= 0:
		for i in range(-diff):
			_remove_polygon()


func _refresh_deferred() -> void:
	if freeze:
		return

	_pending_refresh = true
	refresh.call_deferred()


func _randf() -> float:
	return randomizer.randf_range(_jagged_range.x, _jagged_range.y)
