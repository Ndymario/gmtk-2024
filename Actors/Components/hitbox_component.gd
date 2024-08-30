extends Area2D
class_name HitboxComponent

@export var health_component: HealthComponent
@export var can_be_hurt_from_mini: bool

func damage(attack: Attack, is_mini: bool):
	if is_mini and !can_be_hurt_from_mini:
		return
	if health_component:
		health_component.damage(attack)
