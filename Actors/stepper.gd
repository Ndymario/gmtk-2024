extends CharacterBody2D
var is_dead = false
var attack_cooldown = false
var attack_timer: Timer
@export var aggro_range = 170
var in_range: bool = false
var player: Player
var sprite: AnimatedSprite2D
var squish_noise
var attack_noise

func _ready() -> void:
	player = get_parent().get_node("Player")
	sprite = $AnimatedSprite2D
	attack_timer = $AttackCooldown
	squish_noise = preload("res://Audio/Stepper/squish.ogg")
	attack_noise = preload("res://Audio/Stepper/pumpkin.ogg")

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	
	if !is_on_floor():
		velocity += get_gravity() * delta
	else:
		velocity = Vector2(0, 0)
		sprite.play("idle")
	
	var distance_to_target: int
	var aggro: bool = false
	
	if player.position.x < position.x:
		if is_on_floor():
			sprite.flip_h = true
		
		distance_to_target = position.x - player.position.x
		
		
	if player.position.x > position.x:
		if is_on_floor():
			sprite.flip_h = false
			
		distance_to_target = player.position.x - position.x
		
	if distance_to_target <= aggro_range and is_on_floor() and !attack_cooldown:
		velocity = calculate_jump_velocity(position, player.position, 1, -get_gravity().y)
		if velocity.y < player.JUMP_VELOCITY:
			velocity.y = player.JUMP_VELOCITY
		$AudioStreamPlayer2D.stream = attack_noise
		$AudioStreamPlayer2D.play()
		sprite.play("bounce")
		attack_cooldown = true
		attack_timer.start(1.5)
		
	move_and_slide()


# Fancy equation to make the enemy jump  at the player
func calculate_jump_velocity(enemy_position: Vector2, player_position: Vector2, time_of_flight: float, gravity: float) -> Vector2:
	# Calculate horizontal and vertical distances
	var d_x = player_position.x - enemy_position.x
	var d_y = player_position.y - enemy_position.y
	
	# Calculate horizontal velocity component
	var v_x = d_x / time_of_flight
	
	# Calculate vertical velocity component
	var v_y = (d_y + 0.5 * gravity * time_of_flight * time_of_flight) / time_of_flight
	
	# Return the velocity vector
	return Vector2(v_x, v_y)


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
