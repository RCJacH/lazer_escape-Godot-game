@tool
extends BounceableObstacle
class_name BounceableObstacleCave


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
		_polygon_count = openings.size()
		_collision_count = openings.size()
		_pending_refresh = true
		refresh.call_deferred()
@export_range(0.01, 0.5) var opening_width: float = 0.05 :
	set(new_opening_width):
		opening_width = new_opening_width
		_pending_refresh = true
		refresh.call_deferred()


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

	for deg in range(starting_deg, ending_deg, density):
		var direction := Vector2.from_angle(deg_to_rad(deg + density * jagged_range * randomizer.randf()))
		var inner := direction * (radius + thickness * jagged_range * randomizer.randf())
		var outer := direction * (radius + thickness + thickness * jagged_range * randomizer.randf())
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
				opening_close_pct = pct + opening_width - opening_width * jagged_range * randomizer.randf()
				if inner_points and outer_points:
					polygons[i].points = _build_polygon_shape(inner_points, outer_points)
					i += 1
				continue

		inner_points.append(inner)
		outer_points.append(outer)
	if i < polygons.size():
		polygons[i].points = _build_polygon_shape(inner_points, outer_points)
	_update_data.call_deferred()
	_pending_refresh = false


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
