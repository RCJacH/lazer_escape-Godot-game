extends Resource
class_name PowerUpAction

@export_enum("+1:1", "-1:-1") var modifier := 1
@export var mod_target: Target = Target.BOUNCE

enum Target {
	BOUNCE,
	POWER,
}

func do(lazer: Lazer) -> void:
	match mod_target:
		Target.BOUNCE:
			lazer.bounces += modifier
		Target.POWER:
			pass
