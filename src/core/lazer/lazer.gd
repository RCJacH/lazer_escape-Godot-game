extends Node2D
class_name Lazer

signal angle_changed(new_angle: float)
signal boundary_hit()
signal boundary_missed()

@export var reduction_rate := 0.01

var angle: float = 0.0

var _draw_points: Array[Vector2] = [Vector2.ZERO]

@onready var ray: RayCast2D = $RayCast2D
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
	var _hit_boundary := false
	var length := get_viewport_rect().size.length()

	var local_target_position := Vector2.from_angle(angle) * length
	var collision_point: Vector2
	var collision_normal: Vector2
	var ray_direction: Vector2
	var energy := 1.0

	ray.global_position = global_position
	ray.target_position = local_target_position

	while energy > 0.0:
		ray.force_raycast_update()
		if not ray.is_colliding():
			break

		var collider := ray.get_collider()

		collision_point = ray.get_collision_point()
		if collision_point == ray.global_position:
			ray.add_exception_rid(ray.get_collider_rid())
			continue

		ray.clear_exceptions()
		_draw_points.append(collision_point - global_position)
		if collider is LevelBoundaries:
			_hit_boundary = true
			break

		collision_normal = ray.get_collision_normal()
		ray_direction = ray.global_position.direction_to(collision_point)
		ray_direction = ray_direction.bounce(collision_normal)
		ray.global_position = collision_point
		ray.target_position = ray_direction * length
		local_target_position = collision_point + ray.target_position - global_position
		energy -= reduction_rate

	if _hit_boundary:
		boundary_hit.emit()
	else:
		boundary_missed.emit()

	display.points = PackedVector2Array(_draw_points)
