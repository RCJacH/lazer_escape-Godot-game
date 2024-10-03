@tool
extends Node2D
class_name LevelDesignHelper

signal position_changed(new_position: Vector2, relative: Vector2)


@export var select_memory: int :
	set(new_i):
		if new_i >= memories.size():
			new_i %= memories.size()
		elif new_i < -1:
			new_i += memories.size() + 1
		select_memory = new_i
		if new_i == -1:
			return
		position = memories[new_i]
@export var total_memories: int:
	set(i):
		return
	get():
		return memories.size()
@export var save_memory: bool :
	set(v):
		if select_memory == -1:
			memories.append(position)
			return
		memories[select_memory] = position
@export var delete_memory: bool:
	set(v):
		memories.remove_at(select_memory)

var previous_position := Vector2.ZERO
var memories: Array[Vector2] = []


func _ready() -> void:
	if not Engine.is_editor_hint():
		queue_free()


func _process(_delta: float) -> void:
	if not visible:
		return

	if position != previous_position:
		position_changed.emit(position, position - previous_position)
		previous_position = position
