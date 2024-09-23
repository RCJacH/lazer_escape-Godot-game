extends Area2D
class_name LevelBoundaries

@onready var collision_shape: CollisionPolygon2D = $CollisionPolygon2D


func _ready() -> void:
	var viewport := get_viewport_rect()
	var margin := Vector2(10.0, 10.0)
	var points: Array[Vector2] = [
		viewport.position,
		viewport.position + Vector2(viewport.size.x, 0.0),
		viewport.end,
		viewport.position + Vector2(0.0, viewport.size.y),
		viewport.position - Vector2(0.0, 0.0),
		viewport.position - margin,
		viewport.position + Vector2(-margin.x, viewport.size.y + margin.y),
		viewport.end + margin,
		viewport.position + Vector2(viewport.size.x + margin.x, -margin.y),
		viewport.position - Vector2(0.0, margin.y),
		viewport.position,
	]
	collision_shape.polygon = PackedVector2Array(points)
