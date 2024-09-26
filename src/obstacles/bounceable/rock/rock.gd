@tool
extends BounceableObstacle
class_name BounceableObstacleRock


@export var radius: float = 64.0 :
	set(new_radius):
		radius = new_radius
		_pending_refresh = true
		refresh.call_deferred()
@export var initialize: bool = false:
	set(new_value):
		_polygon_count = 1
		_collision_count = 1


func _ready() -> void:
	_polygon_count = 1
	_collision_count = 1


func refresh() -> void:
	var jagged_range := jaggedness - jaggedness * 0.5
	var points: Array[Vector2] = []
	for deg in range(0, 360, density):
		var direction := Vector2.from_angle(deg_to_rad(deg + density * jagged_range * randomizer.randf()))
		var point := direction * (radius + radius * jagged_range * randomizer.randf())
		points.append(point)
	polygons[0].points = points
	_update_data()
	_pending_refresh = false
