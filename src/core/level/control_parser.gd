extends Control
class_name ControlParser

signal mouse_moved(position: Vector2, shift: bool, dragging: bool, press_position: Vector2)
signal wheel_up_pressed(ctrl: bool, alt: bool, shift: bool)
signal wheel_down_pressed(ctrl: bool, alt: bool, shift: bool)

var _shift_pressed: bool = false
var _alt_pressed: bool = false
var _ctrl_pressed: bool = false
var _pressed_button_flag := 0
var _press_position := Vector2.ZERO


func _on_gui_input(event):
	match event:
		InputEventMouseButton:
			_parse_mouse_button(event)
		InputEventMouseMotion:
			_parse_mouse_motion(event)
		InputEventKey:
			_parse_key(event)
	return event


func _parse_mouse_button(event: InputEventMouseButton) -> void:
	if event.pressed:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				_pressed_button_flag |= MOUSE_BUTTON_LEFT
				_press_position = event.global_position
			MOUSE_BUTTON_WHEEL_UP:
				wheel_up_pressed.emit(_ctrl_pressed, _alt_pressed, _shift_pressed)
			MOUSE_BUTTON_WHEEL_DOWN:
				wheel_down_pressed.emit(_ctrl_pressed, _alt_pressed, _shift_pressed)
	else:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				_pressed_button_flag ^= MOUSE_BUTTON_LEFT
				_press_position *= 0.0


func _parse_mouse_motion(event: InputEventMouseMotion) -> void:
	mouse_moved.emit(
		event,
		_shift_pressed,
		_pressed_button_flag & MOUSE_BUTTON_LEFT,
		_press_position
	)


func _parse_key(event: InputEventKey) -> void:
	_shift_pressed = event.shift_pressed
	_ctrl_pressed = event.ctrl_pressed
	_alt_pressed = event.alt_pressed
