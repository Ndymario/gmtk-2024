extends CharacterBody2D
var is_dead = false
var attack_cooldown = false
var attack_timer: Timer
@export var aggro_range = 170
var in_range: bool = false
var player: Player
var sprite: AnimatedSprite2D
var squish_noise

func _ready() -> void:
	player = get_parent().get_node("Player")
	sprite = $AnimatedSprite2D
	attack_timer = $AttackCooldown
	squish_noise = preload("res://Audio/Stepper/squish.ogg")

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	
	if !is_on_floor():
		velocity += get_gravity() * delta
	else:
		velocity = Vector2(0, 0)
		sprite.play("idle")
		
	move_and_slide()


func _on_hitbox_component_area_entered(area: Area2D) -> void:
	if area is HitboxComponent:
		var hitbox: HitboxComponent = area
		
		var attack = Attack.new()
		attack.attack_dmg = 1
		
		hitbox.damage(attack, false)


func _on_health_component_dead() -> void:
	is_dead = true
	get_node("AnimatedSprite2D").play("squash")
	$AudioStreamPlayer2D.stream = squish_noise
	$AudioStreamPlayer2D.play()


func _on_animated_sprite_2d_animation_finished() -> void:
	if is_dead:
		queue_free()


func _on_attack_cooldown_timeout() -> void:
	attack_cooldown = false
