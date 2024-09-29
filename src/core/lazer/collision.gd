extends RefCounted
class_name Collision

static var space_state: PhysicsDirectSpaceState2D
static var length: float

var position: Vector2 # point in the world space for source
var collision_point: Vector2 # point in world space for collision
var normal: Vector2 # normal in world space for collision
var collider: Obstacle # Object collided or null (if unassociated)
var collider_id: int # Object it collided against
var rid: RID # RID it collided against
var shape: int # shape index of collider
# var metadata: Variant() # metadata of collider


static func setup(state: PhysicsDirectSpaceState2D, new_length: float) -> void:
	space_state = state
	length = new_length


static func create(from: Vector2, direction: Vector2) -> Collision:
	var query := PhysicsRayQueryParameters2D.create(from, from + direction * length)
	return Collision.new(
		from,
		space_state.intersect_ray(query)
	)


static func bounce(from_result: Collision) -> Collision:
	var direction := from_result.position.direction_to(from_result.collision_point)
	direction = direction.bounce(from_result.normal)
	return Collision.create(from_result.collision_point, direction)


func _init(from: Vector2, result: Dictionary) -> void:
	if not result:
		return

	position = from
	collision_point = result.position
	normal = result.normal
	collider = result.collider
	collider_id = result.collider_id
	rid = result.rid
	shape = result.shape


func is_stuck() -> bool:
	return collision_point == position


func back_trace() -> Collision:
	return Collision.create(
		position,
		position.direction_to(collision_point) * (position.distance_to(collision_point) - 0.1)
	)
