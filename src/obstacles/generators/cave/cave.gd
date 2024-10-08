@tool
extends ObstacleGenerator
class_name ObstacleGeneratorCave


@export var radius: float = 128.0 :
	set(new_radius):
		radius = new_radius
		_refresh_deferred()
@export var thickness: float = 8.0 :
	set(new_thickness):
		thickness = new_thickness
		_refresh_deferred()
@export var openings: Array[Opening] = [] :
	set(new_openings):
		var to_refresh := true
		if new_openings.size() > openings.size():
			to_refresh = false
		openings = new_openings
		_resize_polygon(openings.size())
		if openings:
			_connect_new_opening(openings.back())
		if to_refresh:
			_refresh_deferred()


func _refresh() -> void:
	for p in polygons:
		p.clear()

	var all_points: PackedVector2Array = []
	var inner_points: Array[Vector2] = []
	var outer_points: Array[Vector2] = []
	var sorted_openings := Opening.as_vectors(openings)
	var i := 0
	var start_index := 0
	var closing_deg := 0.0
	var current_opening: Vector2 = _get_next_opening(sorted_openings)
	var starting_deg: float = current_opening.x if current_opening else 0.0
	var previous_deg := 0.0
	var step_deg := 360.0 / density
	var points: PackedVector2Array

	for n in range(density + 1):
		var deg := n * step_deg
		var shifted_deg := starting_deg + deg
		if deg >= 360:
			shifted_deg -= 360.0
		var d_deg := step_deg * _randf()
		var next_deg := shifted_deg + d_deg
		if current_opening:
			if closing_deg:
				if next_deg > closing_deg:
					d_deg = current_opening.y - shifted_deg
					closing_deg = 0.0
					current_opening = _get_next_opening(sorted_openings) + Vector2.ONE * starting_deg
				else:
					continue
			elif not previous_deg or (previous_deg < current_opening.x and next_deg > current_opening.x):
				d_deg = current_opening.x - shifted_deg
				closing_deg = current_opening.y
				if not previous_deg:
					continue
				if inner_points and outer_points:
					_add_points(next_deg, inner_points, outer_points)
					points = _build_polygon_shape(inner_points, outer_points)
					all_points.append_array(points)
					_update_polygon(i, start_index, points.size())
					i += 1
					start_index = all_points.size()
					previous_deg = next_deg
					inner_points.clear()
					outer_points.clear()
					continue
		_add_points(next_deg, inner_points, outer_points)
		previous_deg = next_deg

	var count := polygons.size()
	if count == 0:
		count = 1

	if i < count:
		points = _build_polygon_shape(inner_points, outer_points)
		all_points.append_array(points)
		if polygons:
			_update_polygon(i, start_index, points.size())

	var half := floori(all_points.size() * 0.5)
	if not openings.size():
		all_points[0] = all_points[half - 1]
		all_points[-1] = all_points[half]
	polygon = all_points


func _connect_new_opening(new_opening: Opening) -> void:
	if not new_opening is Opening:
		return

	if new_opening.changed.is_connected(_refresh_deferred):
		return

	new_opening.changed.connect(_refresh_deferred)


func _get_next_opening(sorted_openings: Array[Vector2]) -> Vector2:
	if not sorted_openings.size():
		return Vector2.ZERO

	return sorted_openings.pop_front() * 360.0


func _add_points(deg: float, inner_points: Array[Vector2], outer_points: Array[Vector2]) -> void:
	var direction := Vector2.from_angle(deg_to_rad(deg))
	var inner := direction * (radius + thickness * _randf())
	var outer := direction * (radius + thickness + thickness * _randf())
	inner_points.append(inner)
	outer_points.append(outer)
