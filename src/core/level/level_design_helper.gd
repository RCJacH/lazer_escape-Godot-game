@tool
extends Node2D
class_name LevelDesignHelper

signal position_changed(new_position: Vector2, relative: Vector2)

var previous_position := Vector2.ZERO


func _ready() -> void:
	if not Engine.is_editor_hint():
		queue_free()


func _process(_delta: float) -> void:
	if not visible:
		return

	if position != previous_position:
		position_changed.emit(position, position - previous_position)
		previous_position = position
