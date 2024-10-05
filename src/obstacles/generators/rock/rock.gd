@tool
extends ObstacleGenerator
class_name ObstacleGeneratorRock


@export var radius: float = 64.0 :
	set(new_radius):
		radius = new_radius
		_pending_refresh = true
		refresh.call_deferred()


func _refresh() -> void:
	var jagged_range := jaggedness - jaggedness * 0.5
	var points: PackedVector2Array = []
	for deg in range(0, 360, 360.0 / density):
		var direction := Vector2.from_angle(deg_to_rad(deg + density * jagged_range * randomizer.randf()))
		var point := direction * (radius + radius * jagged_range * randomizer.randf())
		points.append(point)
	polygon = points
