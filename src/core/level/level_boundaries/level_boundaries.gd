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

var visible_block_count: int = 0
var boundaries: Dictionary = {}

@onready var block_scene: Resource = load(block_path)


func refresh() -> void:
	pass


func _update_blocks() -> void:
	columns = 2 if visible_block_count > 1 else 1
	boundaries.clear()
	for child in get_children():
		if child is BoundaryBlock:
			child.request_refresh()
			boundaries[child] = false


func _add_block() -> void:
	var block: BoundaryBlock = block_scene.instantiate()
	add_child(block)
	block.owner = get_tree().edited_scene_root
	block.name = "BoundaryBlock%d" % get_child_count()


func _on_boundary_visibility_changed() -> void:
	visible_block_count = 0
	for child in get_children():
		if child.visible:
			visible_block_count += 1
	_update_blocks()


func _on_boundary_locked(boundary: BoundaryBlock) -> void:
	boundaries[boundary] = false


func _on_boundary_unlocked(boundary: BoundaryBlock) -> void:
	boundaries[boundary] = true
	if boundaries.values().all(func(x): return x == true):
		all_unlocked.emit()


func _on_child_entered_tree(node: Node):
	if not node is BoundaryBlock:
		return

	var boundary: BoundaryBlock = node
	visible_block_count += 1
	boundary.visibility_changed.connect(_on_boundary_visibility_changed)
	boundary.locked.connect(_on_boundary_locked.bind(boundary))
	boundary.unlocked.connect(_on_boundary_unlocked.bind(boundary))
	_update_blocks()


func _on_child_exiting_tree(node):
	if not node is BoundaryBlock:
		return

	var boundary: BoundaryBlock = node
	visible_block_count -= 1
	boundary.visibility_changed.disconnect(_on_boundary_visibility_changed)
	boundary.locked.disconnect(_on_boundary_locked)
	boundary.unlocked.disconnect(_on_boundary_unlocked)
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
