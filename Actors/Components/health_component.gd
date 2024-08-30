extends Node2D
class_name HealthComponent
signal dead

@export var MAX_HEALTH := 10
var health : float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health = MAX_HEALTH


func damage(attack: Attack):
	health -= attack.attack_dmg
	
	if health <= 0:
		emit_signal("dead")
