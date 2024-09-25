extends RefCounted
class_name Polygon

var points: Array[Vector2]


func clear() -> void:
	points.clear()


func append(v: Vector2) -> void:
	points.append(v)


func append_array(v: Array[Vector2]) -> void:
	points.append_array(v)


func size() -> int:
	return points.size()
