extends StaticBody2D
class_name Obstacle


@export_range(0.0, 1.0) var jaggedness: float = 0.1 :
	set(new_jaggedness):
		jaggedness = new_jaggedness
		_pending_refresh = true
		refresh.call_deferred()
@export var random_seed: int = 1 :
	set(new_seed):
		random_seed = new_seed
		randomizer.seed = new_seed
		randomizer.randomize()
		_pending_refresh = true
		refresh.call_deferred()

var polygons: Array[Polygon] = []
var collisions: Array[CollisionPolygon2D] = []
var randomizer := RandomNumberGenerator.new()

var _pending_refresh: bool = false


func _ready() -> void:
	_pending_refresh = true
	refresh.call_deferred()


func refresh() -> void:
	pass


func _update_data() -> void:
	if polygons.size() > 1:
		return _update_multiple_polygons()

	_update_single_polygon()


func _update_multiple_polygons() -> void:
	$Display.polygons.resize(polygons.size())
	var points: Array[Vector2] = []
	var index_array: Array[int] = []
	for i in range(polygons.size()):
		var polygon := polygons[i]
		var collision := collisions[i]
		var count := points.size()
		points.append_array(polygon.points)
		collision.polygon = PackedVector2Array(polygon.points)
		for n in range(polygon.size()):
			index_array.append(n + count)
		$Display.polygons[i] = PackedInt32Array(index_array)
		index_array.clear()
	$Display.polygon = PackedVector2Array(points)


func _update_single_polygon() -> void:
	var packed_array := PackedVector2Array(polygons[0].points)
	$Display.polygon = packed_array
	collisions[0].polygon = packed_array


func _build_polygon_shape(
	inner_points: Array[Vector2],
	outer_points: Array[Vector2],
) -> Array[Vector2]:
	var points: Array[Vector2] = []
	points.append_array(inner_points)
	outer_points.reverse()
	points.append_array(outer_points)
	inner_points.clear()
	outer_points.clear()
	return points
