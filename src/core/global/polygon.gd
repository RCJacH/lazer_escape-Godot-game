@tool
extends RefCounted
class_name Polygon

var points: PackedVector2Array
var collision: CollisionPolygon2D :
	get():
		if not _collision:
			_collision = CollisionPolygon2D.new()
		return _collision

var ref_node: Node2D = null

var pending_update: bool = false

var _collision: CollisionPolygon2D
var _index_array: Array[int] = []


func queue_free() -> void:
	var parent := collision.get_parent()
	if parent:
		parent.remove_child.call_deferred(collision)
	collision.queue_free()


func clear() -> void:
	points.clear()


func append(v: Vector2) -> void:
	points.append(v)


func append_array(v: PackedVector2Array) -> void:
	points.append_array(v)


func index_array(from: int = 0) -> Array[int]:
	_index_array.clear()
	_index_array.resize(points.size())
	for i in range(_index_array.size()):
		_index_array[i] = from + i
	return _index_array


func size() -> int:
	return points.size()
