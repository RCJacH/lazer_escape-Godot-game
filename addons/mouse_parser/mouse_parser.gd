@tool
class_name MouseParser
extends Control

signal left_pressed(event: InputEventMouseButton)
signal left_clicked(event: InputEventMouseButton, press_position: Vector2)
signal middle_pressed(event: InputEventMouseButton)
signal middle_clicked(event: InputEventMouseButton, press_position: Vector2)
signal right_pressed(event: InputEventMouseButton)
signal right_clicked(event: InputEventMouseButton, press_position: Vector2)
signal wheel_up_pressed(event: InputEventMouseButton)
signal wheel_up_clicked(event: InputEventMouseButton, press_position: Vector2)
signal wheel_down_pressed(event: InputEventMouseButton)
signal wheel_down_clicked(event: InputEventMouseButton, press_position: Vector2)
signal mouse_motion(event: InputEventMouseMotion)
signal left_dragged(event: InputEventMouseMotion, press_position: Vector2)
signal middle_dragged(event: InputEventMouseMotion, press_position: Vector2)
signal right_dragged(event: InputEventMouseMotion, press_position: Vector2)
signal mouse_hovered(position: Vector2)
signal mouse_no_longer_hovered()

const MOUSE_LEFT_BUTTON_FLAG = 1
const MOUSE_MID_BUTTON_FLAG = 4
const MOUSE_RIGHT_BUTTON_FLAG = 2
const MOUSE_WHEEL_UP_BUTTON_FLAG = 8
const MOUSE_WHEEL_DOWN_BUTTON_FLAG = 16

@export var minimum_drag_distance := 2
@export var hover_detection_time := 0.25

var _pressed_button_flag := 0
var _mouse_position_on_click: Dictionary = {
	left=Vector2.ZERO,
	middle=Vector2.ZERO,
	right=Vector2.ZERO,
	wheel_up=Vector2.ZERO,
	wheel_down=Vector2.ZERO,
}
var _mouse_inside := false
var _mouse_inside_time := 0.0
var _mouse_hover_sent := false
var _mouse_position: Vector2 = Vector2.ZERO
var _mouse_last_position: Vector2 = Vector2.ZERO


func _process(delta):
	if !_mouse_hover_sent && _mouse_inside:
		_mouse_inside_time += delta
		if _mouse_inside_time > hover_detection_time and not _mouse_hover_sent:
			mouse_hovered.emit(_mouse_position)
			_mouse_hover_sent = true


func _on_gui_input(event):
	if event is InputEventMouseButton:
		_parse_mouse_button(event)
	elif event is InputEventMouseMotion:
		_parse_mouse_motion(event)
	return event


func _parse_mouse_button(event: InputEventMouseButton):
	if event.pressed:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				_pressed_button_flag |= MOUSE_LEFT_BUTTON_FLAG
				_mouse_position_on_click.left = event.position
				left_pressed.emit(event)
			MOUSE_BUTTON_MIDDLE:
				_pressed_button_flag |= MOUSE_MID_BUTTON_FLAG
				_mouse_position_on_click.middle = event.position
				middle_pressed.emit(event)
			MOUSE_BUTTON_RIGHT:
				_pressed_button_flag |= MOUSE_RIGHT_BUTTON_FLAG
				_mouse_position_on_click.right = event.position
				right_pressed.emit(event)
			MOUSE_BUTTON_WHEEL_UP:
				_pressed_button_flag |= MOUSE_WHEEL_UP_BUTTON_FLAG
				_mouse_position_on_click.wheel_up = event.position
				wheel_up_pressed.emit(event)
			MOUSE_BUTTON_WHEEL_DOWN:
				_pressed_button_flag |= MOUSE_WHEEL_DOWN_BUTTON_FLAG
				_mouse_position_on_click.wheel_down = event.position
				wheel_down_pressed.emit(event)
	else:
		_set_point_cursor()
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				left_clicked.emit(event, _mouse_position_on_click.left)
				_pressed_button_flag ^= MOUSE_LEFT_BUTTON_FLAG
				_mouse_position_on_click.left = Vector2.ZERO
			MOUSE_BUTTON_MIDDLE:
				middle_clicked.emit(event, _mouse_position_on_click.middle)
				_pressed_button_flag ^= MOUSE_MID_BUTTON_FLAG
				_mouse_position_on_click.middle = Vector2.ZERO
			MOUSE_BUTTON_RIGHT:
				right_clicked.emit(event, _mouse_position_on_click.right)
				_pressed_button_flag ^= MOUSE_RIGHT_BUTTON_FLAG
				_mouse_position_on_click.right = Vector2.ZERO
			MOUSE_BUTTON_WHEEL_UP:
				wheel_up_clicked.emit(event, _mouse_position_on_click.wheel_up)
				_pressed_button_flag ^= MOUSE_WHEEL_UP_BUTTON_FLAG
				_mouse_position_on_click.wheel_up = Vector2.ZERO
			MOUSE_BUTTON_WHEEL_DOWN:
				wheel_down_clicked.emit(event, _mouse_position_on_click.wheel_down)
				_pressed_button_flag ^= MOUSE_WHEEL_DOWN_BUTTON_FLAG
				_mouse_position_on_click.wheel_down = Vector2.ZERO



func _parse_mouse_motion(event: InputEventMouseMotion):
	mouse_motion.emit(event)
	if self.get_rect().has_point(event.position):
		_mouse_inside = true
		_mouse_position = event.position
		var diff := (_mouse_position - _mouse_last_position).abs()
		if max(diff.x, diff.y) > minimum_drag_distance:
			_mouse_hover_sent = false
			_mouse_last_position = _mouse_position

		if _mouse_last_position != _mouse_position:
			return

		if _pressed_button_flag & MOUSE_LEFT_BUTTON_FLAG:
			left_dragged.emit(event, _mouse_position_on_click.left)
			_set_drag_cursor()
		if _pressed_button_flag & MOUSE_MID_BUTTON_FLAG:
			middle_dragged.emit(event, _mouse_position_on_click.middle)
			_set_drag_cursor()
		if _pressed_button_flag & MOUSE_RIGHT_BUTTON_FLAG:
			right_dragged.emit(event, _mouse_position_on_click.right)
			_set_drag_cursor()
	else:
		_mouse_inside = false
		_mouse_inside_time = 0.0
		_mouse_hover_sent = false
		mouse_no_longer_hovered.emit()


func _set_drag_cursor():
	Input.set_default_cursor_shape(Input.CURSOR_DRAG)


func _set_point_cursor():
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
