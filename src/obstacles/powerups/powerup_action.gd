@tool
extends Resource
class_name PowerUpAction

signal modifier_changed(value: int)
signal target_changed(value: Target)

@export_enum("+1:1", "-1:-1") var modifier := 1 :
	set(new_modifier):
		if new_modifier == modifier:
			return

		modifier = new_modifier
		modifier_changed.emit(modifier)
@export var mod_target: Target = Target.BOUNCE :
	set(new_target):
		if new_target == mod_target:
			return

		mod_target = new_target
		target_changed.emit(mod_target)

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
