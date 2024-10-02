extends CanvasLayer
class_name LevelUI

signal return_to_menu()
signal next_level()

var has_next_level: bool = true


func _ready() -> void:
	if not has_next_level:
		%NextLevel.visible = false


func _on_menu_button_pressed():
	return_to_menu.emit()


func _on_next_button_pressed():
	next_level.emit()
