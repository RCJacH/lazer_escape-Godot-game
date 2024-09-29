@tool
extends ObstacleGenerator
class_name ObstacleGeneartorBoundary

@export var shrink_inner: float = 10.0 :
	set(new_value):
		shrink_inner = new_value
		_refresh_deferred()
@export var grow_outer: float = 10.0:
	set(new_value):
		grow_outer = new_value
		_refresh_deferred()
@export var rect_ref: Control :
	set(new_node):
		rect_ref = new_node
		_refresh_deferred()


func _ready() -> void:
	_polygon_count = 1
	_refresh_deferred()


func refresh() -> void:
	_polygon_count = 1
	var rect := _get_rect()

	var points: PackedVector2Array = _get_corners(rect.grow(-shrink_inner))
	var outer_corner := _get_corners(rect.grow(grow_outer))
	outer_corner.reverse()
	points.append_array(outer_corner)
	points.append(points[0])
	polygons[0].points = points
	_update_data()
	_pending_refresh = false


func _get_rect() -> Rect2:
	if rect_ref:
		return Rect2(rect_ref.position, rect_ref.size)

	var parent := get_parent()
	if parent is Control:
		return Rect2(parent.position, parent.size)

	return get_viewport_rect()



func _get_corners(rect: Rect2) -> PackedVector2Array:
	return [
		rect.position,
		rect.position + Vector2(rect.size.x, 0.0),
		rect.end,
		rect.position + Vector2(0.0, rect.size.y),
		rect.position,
	]
