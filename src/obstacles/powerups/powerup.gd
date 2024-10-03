@tool
extends ObstacleGeneratorRock
class_name PowerUp

signal destroy()

@export var action: PowerUpAction

var connected_lazer: Lazer
var is_unlocking := false


func on_lazer_hit(
	lazer: Lazer,
	_bounce_remaining: int,
	collision_result: Collision,
	previous_positions: Array[Vector2],
) -> PackedVector2Array:
	previous_positions.append(collision_result.collision_point)
	hit_by_lazer.emit()
	is_unlocking = true
	if not lazer.casting_finished.is_connected(_on_lazer_casting_finished):
		connected_lazer = lazer
		connected_lazer.casting_finished.connect(_on_lazer_casting_finished)
		$Timer.start()
	_lock.call_deferred()
	return previous_positions


func _lock() -> void:
	is_unlocking = false


func _on_lazer_casting_finished() -> void:
	if is_unlocking:
		return

	connected_lazer.casting_finished.disconnect(_on_lazer_casting_finished)
	connected_lazer = null
	$Timer.stop()


func _on_timer_timeout() -> void:
	if Engine.is_editor_hint():
		return

	if action:
		action.do(connected_lazer)
	visible = false
	polygons.front().collision.disabled = true
	destroy.emit()
	connected_lazer.update()
	connected_lazer = null
