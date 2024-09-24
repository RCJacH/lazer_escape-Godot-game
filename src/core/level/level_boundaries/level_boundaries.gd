@tool
extends Area2D
class_name LevelBoundaries

@export var shrink_inner: float = 10.0 :
	set(new_value):
		shrink_inner = new_value
@export var grow_outer: float = 10.0:
	set(new_value):
		grow_outer = new_value
@export var update_now: bool = false:
	set(new_value):
		update_boundaries()

@export var rect_ref: Control


func _ready() -> void:
	update_boundaries()


func update_boundaries(rect: Rect2 = Rect2()) -> void:
	if not rect:
		if not rect_ref:
			rect = get_viewport_rect()
		else:
			rect = Rect2(rect_ref.position, rect_ref.size)

	var points: Array[Vector2] = _get_corners(rect.grow(-shrink_inner))
	var outer_corner := _get_corners(rect.grow(grow_outer))
	outer_corner.reverse()
	points.append_array(outer_corner)
	points.append(points[0])
	update_polygon.bind(points).call_deferred()


func update_polygon(points: Array[Vector2]) -> void:
	$CollisionPolygon2D.polygon = PackedVector2Array(points)


func _get_corners(rect: Rect2) -> Array[Vector2]:
	return [
		rect.position,
		rect.position + Vector2(rect.size.x, 0.0),
		rect.end,
		rect.position + Vector2(0.0, rect.size.y),
		rect.position,
	]
