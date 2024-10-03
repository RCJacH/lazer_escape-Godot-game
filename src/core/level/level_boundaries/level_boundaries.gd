@tool
extends GridContainer
class_name LevelBoundaries

signal all_unlocked()

@export_file("boundary_block.tscn") var block_path: String
@export var add_boundary: bool = false :
	set(pressed):
		if not pressed:
			return

		_add_block.call_deferred()
@export var remove_last: bool = false :
	set(pressed):
		if not pressed:
			return

		_remove_block.call_deferred()

var boundaries: Dictionary = {}

@onready var block_scene: Resource = load(block_path)


func _ready() -> void:
	for child in get_children():
		if child is not BoundaryBlock:
			continue
		var block: BoundaryBlock = child
		block.visibility_changed.connect(_on_boundary_visibility_changed)
		block.locked.connect(_on_boundary_locked.bind(block))
		block.unlocked.connect(_on_boundary_unlocked.bind(block))


func refresh() -> void:
	pass


func _update_blocks() -> void:
	var visible_block_count := 0
	for child in get_children():
		if child.visible:
			visible_block_count += 1
	columns = 2 if visible_block_count > 1 else 1
	boundaries.clear()
	for child in get_children():
		if child is BoundaryBlock:
			child.request_refresh()
			boundaries[child] = false


func _add_block() -> void:
	var block: BoundaryBlock = block_scene.instantiate()
	add_child(block)

	block.visibility_changed.connect(_on_boundary_visibility_changed)
	block.locked.connect(_on_boundary_locked.bind(block))
	block.unlocked.connect(_on_boundary_unlocked.bind(block))
	_update_blocks()

	block.owner = get_tree().edited_scene_root
	block.name = "BoundaryBlock%d" % get_child_count()


func _remove_block() -> void:
	if get_child_count() < 1:
		return

	var block: BoundaryBlock = get_child(-1)
	remove_child(block)
	block.queue_free()
	_update_blocks()


func _on_boundary_visibility_changed() -> void:
	_update_blocks()


func _on_boundary_locked(boundary: BoundaryBlock) -> void:
	boundaries[boundary] = false


func _on_boundary_unlocked(boundary: BoundaryBlock) -> void:
	boundaries[boundary] = true
	if boundaries.values().all(func(x): return x == true):
		if Engine.is_editor_hint():
			return

		all_unlocked.emit()


func _on_child_order_changed():
	_update_blocks()


func _on_control_parser_mouse_moved(mouse_position, relative):
	for child: BoundaryBlock in get_children():
		child.from_position(mouse_position)


func _on_control_parser_wheel_down_pressed(ctrl, alt, shift):
	for child: BoundaryBlock in get_children():
		child.adjust_angle(-0.000001)


func _on_control_parser_wheel_up_pressed(ctrl, alt, shift):
	for child: BoundaryBlock in get_children():
		child.adjust_angle(0.000001)
