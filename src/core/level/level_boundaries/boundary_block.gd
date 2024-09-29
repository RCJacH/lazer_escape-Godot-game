@tool
extends Control
class_name BoundaryBlock

signal unlocked()
signal locked()

@export var displayed_size: float = 10.0:
	set(new_size):
		displayed_size = new_size
		%Boundary.shrink_inner = displayed_size

var unlock_duration: float = 3.0 :
	set(new_duration):
		unlock_duration = new_duration
		%Timer.wait_time = unlock_duration


func position_lazer(percent: Vector2) -> void:
	%Lazer.position = size * percent


func request_refresh() -> void:
	%Boundary.refresh.call_deferred()


func _on_boundary_hit_by_lazer():
	%Timer.start()


func _on_lazer_casting_finished():
	%Timer.stop()
	locked.emit()


func _on_timer_timeout():
	unlocked.emit()
