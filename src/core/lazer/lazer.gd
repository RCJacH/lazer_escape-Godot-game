extends Node2D
class_name Lazer

signal angle_changed(new_angle: float)
signal casting_finished()

@export var bounces := 1

var angle: float = 0.0

var _draw_points: PackedVector2Array = [Vector2.ZERO]

@onready var display: Line2D = $Line2D


func from_position(mouse_position: Vector2) -> void:
	angle = global_position.angle_to_point(mouse_position)
	angle_changed.emit(angle)
	update()


func adjust_angle(d_angle: float) -> void:
	angle += d_angle
	angle_changed.emit(angle)
	update()


func update() -> void:
	_draw_points.resize(1)

	Collision.setup(
		get_world_2d().direct_space_state,
		get_viewport_rect().size.length()
	)
	var previous_positions := PackedVector2Array()

	var collision_result := Collision.create(
		global_position,
		Vector2.from_angle(angle),
	)

	if collision_result.collider:
		previous_positions = collision_result.collider.on_lazer_hit(
			bounces,
			collision_result,
			previous_positions
		)

	for point in previous_positions:
		_draw_points.append(point - global_position)

	display.points = _draw_points
	casting_finished.emit()
