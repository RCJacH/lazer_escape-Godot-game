@tool
extends Node2D

signal next_level()
signal return_to_menu()


func _on_level_ui_next_level():
	next_level.emit()


func _on_level_ui_return_to_menu():
	return_to_menu.emit()
