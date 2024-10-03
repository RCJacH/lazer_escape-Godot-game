@tool
extends StaticBody2D
class_name Obstacle

signal hit_by_lazer()

@export var bounceable: bool = false
@export var health: float = 0.0

var polygons: Array[Polygon] = []
var randomizer := RandomNumberGenerator.new()

var _polygon_count: int = 0 :
	set(new_polygon_count):
		_polygon_count = new_polygon_count
		_update_polygons(_polygon_count)


func on_lazer_hit(
	lazer: Lazer,
	bounce_remaining: int,
	collision_result: Collision,
	previous_positions: Array[Vector2],
) -> PackedVector2Array:
	previous_positions.append(collision_result.collision_point)
	hit_by_lazer.emit()
	if not bounceable or not bounce_remaining:
		return previous_positions

	var new_result = Collision.bounce(collision_result)
	while true:
		if not new_result.collider:
			return previous_positions

		if not collision_result.is_stuck():
			break

		print("stuck")
		new_result = new_result.back_trace()

	return new_result.collider.on_lazer_hit(
		lazer,
		bounce_remaining - 1,
		new_result,
		previous_positions,
	)


func _add_polygon(ref: Node = null) -> Polygon:
	var polygon := Polygon.new()
	if ref:
		polygon.ref_node = ref
	polygons.append(polygon)
	add_child.call_deferred(polygon.collision)
	return polygon


func _remove_polygon(ref: Node = null) -> void:
	if not polygons:
		return

	var polygon: Polygon
	if ref:
		for i in polygons.size():
			polygon = polygons[i]
			if polygon.ref_node == ref:
				polygons.pop_at(i)
				break
		return

	else:
		polygon = polygons.pop_back()
	polygon.queue_free()


func _copy_existing_polygon_to_collisions() -> void:
	if not polygons:
		return

	if polygons.size() == 1:
		var polygon: Polygon = polygons.front()
		polygon.points = $Display.polygon
		polygon.collision.polygon = $Display.polygon
		return

	for i in range(polygons.size()):
		var polygon: Polygon = polygons[i]
		var points: PackedVector2Array = []
		var count: int = $Display.polygons[i].size()
		points.resize(count)
		for j in range(count):
			var index: int = $Display.polygons[i][j]
			points[j] = $Display.polygon[index]
		polygon.points = points
		polygon.collision.polygon = points


func _update_polygons(new_count: int) -> void:
	var cur_count := polygons.size()
	var diff := new_count - cur_count
	if diff >= 0:
		for i in range(diff):
			_add_polygon()
	elif diff <= 0:
		for i in range(-diff):
			_remove_polygon()
