extends Node2D
class_name LazerHost


func _on_control_parser_mouse_moved(mouse_position: Vector2, relative: Vector2) -> void:
	for child: Lazer in get_children():
		child.from_position(mouse_position)


func _on_control_parser_wheel_down_pressed(ctrl, alt, shift):
	pass # Replace with function body.


func _on_control_parser_wheel_up_pressed(ctrl, alt, shift):
	pass # Replace with function body.
