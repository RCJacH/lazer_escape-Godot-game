extends Node2D
class_name Lazer

@export var reduction_rate := 0.01

var draw_points: Array[Vector2] = [Vector2.ZERO]

@onready var ray: RayCast2D = $RayCast2D
@onready var display: Line2D = $Line2D


func update(mouse_position: Vector2) -> void:
	draw_points.clear()
	draw_points.resize(1)
	var length := get_viewport_rect().size.length()

	var angle := global_position.angle_to_point(mouse_position)
	var local_target_position := Vector2.from_angle(angle) * length
	var collision_point: Vector2
	var normal: Vector2
	var bounce: Vector2
	var energy := 1.0

	ray.global_position = global_position
	ray.target_position = local_target_position

	while energy > 0.0:
		ray.force_raycast_update()
		var collider := ray.get_collider()
		if not collider:
			draw_points.append(local_target_position)
			break

		collision_point = ray.get_collision_point()
		draw_points.append(collision_point - global_position)
		normal = ray.get_collision_normal()
		bounce = ray.global_position.direction_to(ray.target_position).bounce(normal)
		local_target_position = collision_point + bounce * length
		ray.global_position = collision_point
		ray.target_position = bounce * length + global_position
		energy -= reduction_rate

	display.points.clear()
	display.points = draw_points
