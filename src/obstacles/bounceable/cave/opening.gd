@tool
extends Resource
class_name Opening

signal change_made()

@export_range(0.0, 1.0) var position: float = 0.5 :
	set(new_position):
		if position != new_position:
			position = new_position
			emit_changed()
			change_made.emit()
@export_range(0.0001, 1.0) var width: float = 0.05 :
	set(new_width):
		if width != new_width:
			width = new_width
			emit_changed()
			change_made.emit()


static func sort_by_position(a: Opening, b: Opening) -> bool:
	var a_pos := a.position
	if a_pos >= 1.0:
		a_pos -= 1.0
	var b_pos := b.position
	if b_pos >= 1.0:
		b_pos -= 1.0
	return a_pos <= b_pos


static func sort_by_weight(a: Opening, b: Opening) -> bool:
	return a.weight <= b.weight


static func as_vectors(openings: Array[Opening]) -> PackedVector2Array:
	var sorted_openings: Array[Opening] = openings.duplicate()
	sorted_openings.sort_custom(Opening.sort_by_position)
	var result: PackedVector2Array = []
	for opening in sorted_openings:
		if not opening.width:
			continue

		var vector := opening.as_vector()
		_append_result(vector, result)
	return result


func as_vector() -> Vector2:
	var start := position
	if start >= 1.0:
		start -= 1.0
	var end := start + width
	return Vector2(start, end)


static func _append_result(vector: Vector2, array: Array[Vector2]) -> void:
	if not array:
		array.append(vector)
		return

	var previous: Vector2 = array.back()
	if vector.y < previous.x or vector.x > previous.y:
		array.append(vector)
		return

	var min_x = min(previous.x, vector.x)
	var max_y = max(previous.y, vector.y)
	array[-1] = Vector2(min_x, max_y)
