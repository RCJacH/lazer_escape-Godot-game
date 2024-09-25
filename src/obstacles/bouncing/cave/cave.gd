@tool
extends StaticBody2D
class_name ObstacleCave

const DEGREE_STEP: int = 10

@export var radius: float = 128.0 :
	set(new_radius):
		radius = new_radius
		_pending_refresh = true
		refresh.call_deferred()
@export var thickness: float = 8.0 :
	set(new_thickness):
		thickness = new_thickness
		_pending_refresh = true
		refresh.call_deferred()
@export_range(0.0, 1.0) var openings: Array[float] = [0.5] :
	set(new_openings):
		openings = new_openings
		change_polygon_counts()
		# change_collision_counts()
		_pending_refresh = true
		refresh.call_deferred()
@export_range(0.0, 0.5) var opening_width: float = 0.05 :
	set(new_opening_width):
		opening_width = new_opening_width
		_pending_refresh = true
		refresh.call_deferred()
@export_range(0.0, 1.0) var jaggedness: float = 0.1 :
	set(new_jaggedness):
		jaggedness = new_jaggedness
		_pending_refresh = true
		refresh.call_deferred()

var polygons: Array[Polygon] = []

var _pending_refresh: bool = false


func refresh() -> void:
	if not _pending_refresh:
		return

	var inner_points: Array[Vector2] = []
	var outer_points: Array[Vector2] = []
	var opening_pcts := openings.duplicate()
	var jagged_range := jaggedness - jaggedness * 0.5
	opening_pcts.sort()
	var i := 0
	var is_opening: bool = false
	var opening_close_pct: float = 0.0
	var starting_deg: int = ceili(opening_pcts[0] * 360) if opening_pcts else 0
	var ending_deg := starting_deg + 360

	for deg in range(starting_deg, ending_deg, DEGREE_STEP):
		var direction := Vector2.from_angle(deg_to_rad(deg + DEGREE_STEP * jagged_range * randf()))
		var inner := direction * (radius - thickness * jagged_range * randf())
		var outer := direction * (radius + thickness + thickness * jagged_range * randf())
		var pct: float = deg / 360.0
		if opening_pcts:
			if is_opening:
				if pct >= opening_close_pct:
					is_opening = false
					opening_pcts.pop_front()
				else:
					continue
			elif pct >= opening_pcts.front():
				is_opening = true
				opening_close_pct = pct + opening_width - opening_width * jagged_range * randf()
				if inner_points and outer_points:
					polygons[i].points = _build_polygon_shape(inner_points, outer_points)
					i += 1
				continue

		inner_points.append(inner)
		outer_points.append(outer)
	if i < polygons.size():
		polygons[i].points = _build_polygon_shape(inner_points, outer_points)
	queue_redraw()
	_pending_refresh = false


func _draw():
	for polygon in polygons:
		if polygon.points.size() >= 2:
			draw_polyline(polygon.points, Color.WHITE)
		for point in polygon.points:
			draw_circle(point, 2, Color.WHITE)


func change_polygon_counts() -> void:
	var cur_count := polygons.size()
	var new_count := openings.size()
	var diff := new_count - cur_count
	if diff >= 0:
		for i in range(diff):
			polygons.append(Polygon.new())
	elif diff <= 0:
		polygons.resize(new_count)


func change_collision_counts() -> void:
	var cur_count := get_child_count() - 1
	var new_count := openings.size()
	var diff := new_count - cur_count
	if diff >= 0:
		for i in range(diff):
			add_child(CollisionPolygon2D.new())
	elif diff <= 0:
		for i in range(-diff):
			remove_child(get_child(-1))


func _update_data() -> void:
	for polygon in polygons:
		var collision := CollisionPolygon2D.new()
		add_child(collision)
		collision.polygon = PackedVector2Array(polygon.points)
	$Display.polygons = polygons


func _build_polygon_shape(
	inner_points: Array[Vector2],
	outer_points: Array[Vector2],
) -> Array[Vector2]:
	var points: Array[Vector2] = []
	points.append_array(inner_points)
	outer_points.reverse()
	points.append_array(outer_points)
	points.append(inner_points.front())
	inner_points.clear()
	outer_points.clear()
	return points


class Polygon:
	var points: Array[Vector2]

	func clear() -> void:
		points.clear()


	func append(v: Vector2) -> void:
		points.append(v)


	func append_array(v: Array[Vector2]) -> void:
		points.append_array(v)
