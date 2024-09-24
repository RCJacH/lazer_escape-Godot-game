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
		rect = _get_rect()

	var points: Array[Vector2] = _get_corners(rect.grow(-shrink_inner))
	var outer_corner := _get_corners(rect.grow(grow_outer))
	outer_corner.reverse()
	points.append_array(outer_corner)
	points.append(points[0])
	update_polygon.bind(points).call_deferred()


func update_polygon(points: Array[Vector2]) -> void:
	$CollisionPolygon2D.polygon = PackedVector2Array(points)


func _get_rect() -> Rect2:
	if rect_ref:
		return Rect2(rect_ref.position, rect_ref.size)

	var parent := get_parent()
	if parent is Control:
		return Rect2(parent.position, parent.size)

	return get_viewport_rect()


func _get_corners(rect: Rect2) -> Array[Vector2]:
	return [
		rect.position,
		rect.position + Vector2(rect.size.x, 0.0),
		rect.end,
		rect.position + Vector2(0.0, rect.size.y),
		rect.position,
	]
