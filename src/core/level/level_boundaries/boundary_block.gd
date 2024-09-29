@tool
extends Control
class_name BoundaryBlock

signal unlocked()
signal locked()

@export var lazer_position: Vector2 = Vector2.ZERO :
	set(new_lazer_position):
		lazer_position = new_lazer_position
		position_lazer.call_deferred()
@export var lazer_bounce_count: int = 0:
	set(new_lazer_bounce_count):
		lazer_bounce_count = new_lazer_bounce_count
		%Lazer.bounces = lazer_bounce_count
@export var displayed_size: float = 10.0:
	set(new_size):
		displayed_size = new_size
		%Boundary.shrink_inner = displayed_size

var unlock_duration: float = 3.0 :
	set(new_duration):
		unlock_duration = new_duration
		%Timer.wait_time = unlock_duration


func position_lazer() -> void:
	%Lazer.position = size * lazer_position


func request_refresh() -> void:
	position_lazer.call_deferred()
	%Boundary.refresh.call_deferred()


func from_position(mouse_position: Vector2) -> void:
	%Lazer.from_position(mouse_position)


func adjust_angle(d_angle: float) -> void:
	%Lazer.adjust_angle(d_angle)


func _on_boundary_hit_by_lazer():
	%Timer.start()


func _on_lazer_casting_finished():
	%Timer.stop()
	locked.emit()


func _on_timer_timeout():
	unlocked.emit()
