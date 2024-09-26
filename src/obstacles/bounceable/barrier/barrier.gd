@tool
extends BounceableObstacle
class_name BounceableObstacleBarrier

var lines: Dictionary = {}

var _polygons_pending_refresh: Array[Polygon] = []


func refresh() -> void:
	if _polygons_pending_refresh.is_empty():
		_polygons_pending_refresh = polygons.duplicate()
	for polygon in _polygons_pending_refresh:
		_refresh_polygon(polygon)
	_update_data()
	_pending_refresh = false
	_polygons_pending_refresh.clear()


func _refresh_polygon(polygon: Polygon) -> void:
	var line: Line2D = polygon.ref_node
	var inners: Array[Vector2]
	var outers: Array[Vector2]
	var previous_point: Vector2 = line.points[0]
	var final_index := line.points.size() - 1
	var previous_direction := Vector2.ZERO
	for i in range(final_index):
		var point: Vector2 = line.points[i + 1]
		previous_direction = _get_outline_from_point_pairs(
			previous_point,
			point,
			line.width,
			previous_direction,
			inners,
			outers,
			i == 0,
			i==final_index - 1
		)
		previous_point = point

	polygon.points = _build_polygon_shape(inners, outers)


func _get_outline_from_point_pairs(
	point_a: Vector2,
	point_b: Vector2,
	width: float,
	previous_direction: Vector2,
	inners: Array[Vector2],
	outers: Array[Vector2],
	is_first: bool,
	is_last: bool,
) -> Vector2:
	var direction := point_a.direction_to(point_b)
	var angle := previous_direction.angle_to(direction)
	var total_points := roundi(density + density * 0.5 * _randf())
	var half_width := width * 0.5
	var offset := direction.orthogonal() * half_width
	if is_last:
		point_b += direction * half_width
	if is_first:
		point_a -= direction * half_width
	var corner_a: Vector2 = point_a + offset
	var corner_b: Vector2 = point_b + offset
	var point_count := roundi(total_points * 0.5 + _randf())
	var new_points := _split_line(corner_a, corner_b, direction, point_count, -width)
	var is_bend_angle = abs(angle) <= PI * 2.0 / 3.0
	var bending_ccw = sign(angle) == 1
	if is_bend_angle or not bending_ccw:
		_merge_intersection(inners, new_points, angle)
	inners.append_array(new_points)

	var corner_d: Vector2 = point_a - offset
	var corner_c: Vector2 = point_b - offset
	point_count = total_points - point_count
	new_points = _split_line(corner_c, corner_d, -direction, point_count, width)
	new_points.reverse()
	if is_bend_angle or bending_ccw:
		_merge_intersection(outers, new_points, angle)
	outers.append_array(new_points)
	return direction


func _split_line(
	point_a: Vector2,
	point_b: Vector2,
	direction: Vector2,
	point_count: int,
	width: float,
) -> PackedVector2Array:
	var new_points: PackedVector2Array = []
	var step_pct := 1.0 / (point_count - 1)
	for i in range(point_count):
		var new_point := point_a.lerp(point_b, step_pct * i + step_pct * 0.25 * _randf())
		new_point += direction.orthogonal() * width * _randf()
		new_points.append(new_point)
	return new_points


func _merge_intersection(points: Array[Vector2], new_points: Array[Vector2], angle: float) -> void:
	if not points or not new_points:
		return

	var a: Vector2 = points.pop_back()
	var b: Vector2 = new_points.pop_front()
	var midpoint := a.lerp(b, 0.5)
	var direction := a.direction_to(b)
	var perpendicular = direction.orthogonal()
	var distance := a.distance_to(b) * 0.5
	points.append(midpoint + sign(angle) * perpendicular * distance * (1.0 + 0.5 * _randf()))


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


func _on_line_redraw(line: Line2D) -> void:
	_polygons_pending_refresh.append(lines[line])
	_refresh_deferred()


func _on_child_entered_tree(node: Node) -> void:
	if not node is Line2D:
		return

	var line: Line2D = node
	line.draw.connect(_on_line_redraw.bind(node))
	var polygon := _add_polygon()
	polygon.ref_node = line
	lines[line] = polygon


func _on_child_exiting_tree(node: Node) -> void:
	if not node is Line2D:
		return

	var line: Line2D = node
	if not line.draw.is_connected(_on_line_redraw):
		return
	line.draw.disconnect(_on_line_redraw)
	lines[line].queue_free()
	lines.erase(node)
