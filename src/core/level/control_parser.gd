extends Control
class_name ControlParser

signal mouse_moved(mouse_position: Vector2, relative: Vector2)
signal wheel_up_pressed(ctrl: bool, alt: bool, shift: bool)
signal wheel_down_pressed(ctrl: bool, alt: bool, shift: bool)

var _shift_pressed: bool = false
var _alt_pressed: bool = false
var _ctrl_pressed: bool = false


func _on_gui_input(event):
	match event.get_class():
		"InputEventMouseButton":
			_parse_mouse_button(event)
		"InputEventMouseMotion":
			_parse_mouse_motion(event)
		# "InputEventKey":
		# 	_parse_key(event)
	return event


func _parse_mouse_button(event: InputEventMouseButton) -> void:
	if event.pressed:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				mouse_moved.emit(event.global_position, Vector2.ZERO)
			MOUSE_BUTTON_WHEEL_UP:
				wheel_up_pressed.emit(_ctrl_pressed, _alt_pressed, _shift_pressed)
			MOUSE_BUTTON_WHEEL_DOWN:
				wheel_down_pressed.emit(_ctrl_pressed, _alt_pressed, _shift_pressed)


func _parse_mouse_motion(event: InputEventMouseMotion) -> void:
	mouse_moved.emit(event.global_position, event.relative)


func _parse_key(event: InputEventKey) -> void:
	_shift_pressed = event.shift_pressed
	_ctrl_pressed = event.ctrl_pressed
	_alt_pressed = event.alt_pressed
