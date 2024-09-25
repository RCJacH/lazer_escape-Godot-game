@tool
extends StaticBody2D
class_name Obstacle

@export var density := Density.HIGH :
	set(new_density):
		density = new_density
		_pending_refresh = true
		refresh.call_deferred()
@export_range(0.0, 1.0) var jaggedness: float = 0.1 :
	set(new_jaggedness):
		jaggedness = new_jaggedness
		_pending_refresh = true
		refresh.call_deferred()
@export var do_not_connect: bool = false :
	set(new_value):
		do_not_connect = new_value
		_pending_refresh = true
		refresh.call_deferred()
@export var random_seed: int = 1 :
	set(new_seed):
		random_seed = new_seed
		randomizer.seed = new_seed
		randomizer.randomize()
		_pending_refresh = true
		refresh.call_deferred()
@export var randomize_seed: bool = false :
	set(new_value):
		random_seed = randi()

enum Density {
	TRIANGLE = 180,
	SQUARE = 90,
	PENTAGON = 72,
	HEXAGON = 60,
	OCTAGON = 45,
	NONAGON = 40,
	DECAGON = 36,
	DODECAGON = 30,
	LOW = 24,
	MID = 18,
	HIGH = 10,
	SUPERHIGH = 5,
}

var polygons: Array[Polygon] = []
var collisions: Array[CollisionPolygon2D] = []
var randomizer := RandomNumberGenerator.new()

var _pending_refresh: bool = false
var _polygon_count: int = 0 :
	set(new_polygon_count):
		_polygon_count = new_polygon_count
		_update_polygons(_polygon_count)
var _collision_count: int = 0 :
	set(new_collision_count):
		_collision_count = new_collision_count
		_update_collisions(_collision_count)


func _ready() -> void:
	_pending_refresh = true
	refresh.call_deferred()


func refresh() -> void:
	pass


func _update_data() -> void:
	if do_not_connect or polygons.size() > 1:
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


func _update_polygons(new_count: int) -> void:
	var cur_count := polygons.size()
	var diff := new_count - cur_count
	if diff >= 0:
		for i in range(diff):
			polygons.append(Polygon.new())
	elif diff <= 0:
		polygons.resize(new_count)


func _update_collisions(new_count: int) -> void:
	var cur_count := collisions.size()
	var diff := new_count - cur_count
	if diff > 0:
		for i in range(diff):
			var collision := CollisionPolygon2D.new()
			collisions.append(collision)
			add_child(collision)
	elif diff < 0:
		for i in range(-diff):
			var collision := collisions[-1 - i]
			collision.queue_free()
		collisions.resize(new_count)
