@tool
extends Control
class_name BoundaryBlock


func position_lazer(percent: Vector2) -> void:
	%Lazer.position = size * percent


func request_refresh() -> void:
	%Boundary.refresh.call_deferred()
