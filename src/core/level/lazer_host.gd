extends Node2D
class_name LazerHost

signal all_target_hit()

var target_count := 0
var target_bool: Array[bool] = []

func _ready() -> void:
	target_count = get_child_count()
	target_bool.resize(target_count)
	target_bool.fill(false)
	for i in range(target_count):
		var child: Lazer = get_child(i)
		child.boundary_hit.connect(_on_lazer_boundary_hit.bind(i))
		child.boundary_missed.connect(_on_lazer_boundary_missed.bind(i))


func _check_target() -> void:
	if target_bool.count(true) == target_count:
		all_target_hit.emit()


func _on_lazer_boundary_hit(i: int) -> void:
	target_bool[i] = true
	_check_target()


func _on_lazer_boundary_missed(i: int) -> void:
	target_bool[i] = false


func _on_control_parser_mouse_moved(mouse_position: Vector2, relative: Vector2) -> void:
	for child: Lazer in get_children():
		child.from_position(mouse_position)


func _on_control_parser_wheel_down_pressed(ctrl, alt, shift):
	pass # Replace with function body.


func _on_control_parser_wheel_up_pressed(ctrl, alt, shift):
	pass # Replace with function body.
