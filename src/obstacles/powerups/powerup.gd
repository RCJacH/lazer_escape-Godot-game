@tool
extends ObstacleGeneratorRock
class_name PowerUp

signal destroy()

@export var action: PowerUpAction :
	set(new_action):
		action = new_action
		if not action:
			return

		_connect_new_action()


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


func _connect_new_action() -> void:

	action.modifier_changed.connect(_on_action_modifier_changed)
	action.target_changed.connect(_on_action_target_changed)


func _change_name() -> void:
	name = "%s %s" % [
		action.Target.find_key(action.mod_target),
		action.mod_as_text(),
	]


func _on_lazer_casting_finished() -> void:
	if is_unlocking:
		return

	connected_lazer.casting_finished.disconnect(_on_lazer_casting_finished)
	connected_lazer = null
	$Timer.stop()


func _on_action_modifier_changed(_mod: int) -> void:
	$Label.text = action.mod_as_text()
	_change_name()


func _on_action_target_changed(_target: PowerUpAction.Target) -> void:
	pass


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
