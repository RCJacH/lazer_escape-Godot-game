@tool
extends Polygon2D
class_name Obstacle

signal hit_by_lazer()

@export var bounceable: bool = false
@export var health: float = 0.0

var randomizer := RandomNumberGenerator.new()

var _is_manual_editing: bool = true

@onready var collision_host: CollisionObject2D = $CollisionHost


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


func _copy_existing_polygon_to_collisions() -> void:
	_update_collisions()
	if not polygons.size():
		var collision: CollisionPolygon2D = collision_host.get_child(0)
		collision.polygon = polygon
		return

	for i in range(polygons.size()):
		var points: PackedVector2Array = []
		var count: int = polygons[i].size()
		points.resize(count)
		for j in range(count):
			var index: int = polygons[i][j]
			points[j] = polygon[index]
		var collision: CollisionPolygon2D = collision_host.get_child(i)
		collision.polygon = points


func _update_collisions() -> void:
	var target_count := polygons.size()
	if not target_count:
		target_count = 1
	var cur_count := collision_host.get_child_count()
	var diff := target_count - cur_count
	if diff >= 0:
		for i in range(diff):
			_add_collision()
	elif diff <= 0:
		for i in range(-diff):
			_remove_collision()


func _add_collision() -> void:
	var collision := CollisionPolygon2D.new()
	collision_host.add_child(collision)
	collision.owner = get_tree().edited_scene_root


func _remove_collision() -> void:
	collision_host.remove_child(collision_host.get_child(-1))


func _on_draw():
	if not Engine.is_editor_hint():
		return

	if _is_manual_editing:
		_copy_existing_polygon_to_collisions()
	_is_manual_editing = true
