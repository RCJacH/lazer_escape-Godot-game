@tool
extends CharacterBody2D
class_name PowerUp

signal hit_by_lazer()
signal destroy()

@export var health := 1.0 :
	set(new_health):
		health = new_health
		$Timer.wait_time = health
@export var action: PowerUpAction

var connected_lazer: Lazer
var is_unlocking := false


func on_lazer_hit(
	lazer: Lazer,
	bounce_remaining: int,
	collision_result: Collision,
	previous_positions: Array[Vector2],
) -> PackedVector2Array:
	previous_positions.append(collision_result.collision_point)
	hit_by_lazer.emit()
	is_unlocking = true
	connected_lazer = lazer
	connected_lazer.casting_finished.connect(_on_lazer_casting_finished)
	%Timer.start()
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
	if action:
		action.do(connected_lazer)
	connected_lazer = null
	visible = false
	$CollisionShape2D.disabled = true
	destroy.emit()
