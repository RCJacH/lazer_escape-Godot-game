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
		_polygon_count = openings.size()
		if openings:
			_connect_new_opening(openings.back())
		if to_refresh:
			_refresh_deferred()


func refresh() -> void:
	if not _pending_refresh:
		return

	var inner_points: PackedVector2Array = []
	var outer_points: PackedVector2Array = []
	var sorted_openings := Opening.as_vectors(openings)
	var i := 0
	var closing_deg := 0.0
	var current_opening: Vector2 = _get_next_opening(sorted_openings)
	var starting_deg: float = current_opening.x if current_opening else 0.0
	var previous_deg := 0.0
	var step_deg := 360.0 / density

	for n in range(density + 1):
		var deg := n * step_deg
		var shifted_deg := starting_deg + deg
		if deg >= 360:
			shifted_deg -= 360.0
		var d_deg := step_deg * _randf()
		if current_opening:
			if closing_deg:
				if shifted_deg + d_deg > closing_deg:
					d_deg = current_opening.y - shifted_deg
					closing_deg = 0.0
					current_opening = _get_next_opening(sorted_openings)
				else:
					continue
			elif not previous_deg or (previous_deg < current_opening.x and shifted_deg + d_deg > current_opening.x):
				d_deg = current_opening.x - shifted_deg
				closing_deg = current_opening.y
				if not previous_deg:
					continue
				if inner_points and outer_points:
					_add_points(shifted_deg + d_deg, inner_points, outer_points)
					polygons[i].points = _build_polygon_shape(inner_points, outer_points)
					i += 1
					previous_deg = shifted_deg + d_deg
					continue

		_add_points(shifted_deg + d_deg, inner_points, outer_points)
		previous_deg = shifted_deg + d_deg

	if i < polygons.size():
		polygons[i].points = _build_polygon_shape(inner_points, outer_points)
		i += 1

	while i < polygons.size():
		polygons[i].points.clear()
		i += 1

	_update_data()
	_pending_refresh = false


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


func _add_points(deg: float, inner_points: PackedVector2Array, outer_points: PackedVector2Array) -> void:
	var direction := Vector2.from_angle(deg_to_rad(deg))
	var inner := direction * (radius + thickness * _randf())
	var outer := direction * (radius + thickness + thickness * _randf())
	inner_points.append(inner)
	outer_points.append(outer)


func _build_polygon_shape(
	inner_points: PackedVector2Array,
	outer_points: PackedVector2Array,
) -> PackedVector2Array:
	var points: PackedVector2Array = []
	points.append_array(inner_points)
	outer_points.reverse()
	points.append_array(outer_points)
	# points.append(points[0])
	inner_points.clear()
	outer_points.clear()
	return points
