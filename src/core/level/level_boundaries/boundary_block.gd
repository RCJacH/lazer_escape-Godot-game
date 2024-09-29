@tool
extends Control
class_name BoundaryBlock

@onready var boundary: ObstacleGeneartorBoundary = %Boundary
@onready var lazer: Lazer = %Lazer


func position_lazer(percent: Vector2) -> void:
	lazer.position = size * percent


func request_refresh() -> void:
	boundary.refresh()
