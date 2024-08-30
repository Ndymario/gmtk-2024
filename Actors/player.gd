extends CharacterBody2D
class_name Player
signal coin_collected
signal clear

@export var SPEED = 300.0
@export var JUMP_VELOCITY = -525.0
@export var curr_scale_points = 0
@onready var sprite: AnimatedSprite2D = get_node("AnimatedSprite2D")
@onready var hitbox: CollisionShape2D = get_node("CollisionShape2D")
@onready var pinch_area: Area2D = get_node("Pinch Area")
@onready var animation_player: AnimationPlayer = get_node("AnimationPlayer")
@onready var camera: Camera2D = get_parent().get_node("Camera2D")
@onready var pipe_timer: Timer = get_node("Timer")
@onready var pipe_animation_timer: Timer = get_node("Timer2")
@onready var death_timer: Timer = get_node("Timer3")
var pipe_sound
var no_grow_sound
var no_grow = false
var dead_sound
var clear_sound
var grow_sound
var shrink_sound
var clear_played = false
var is_dead = false
var course_clear = false
var is_pinched = false
var in_pipe = false
var is_mini = false
var facing = 1
var jump_big_sound
var jump_mini_sound
var coyote_time = 10
var bg_music: AudioStreamPlayer2D
var pipe = {"ready": false, "pipe": null, "destination": null, "area": null}

func _ready() -> void:
	sprite.play("idle")
	pipe_sound = preload("res://Audio/Pipe/pipe.ogg")
	no_grow_sound = preload("res://Audio/Player/buzz.ogg")
	jump_big_sound = preload("res://Audio/Player/jump_big.ogg")
	jump_mini_sound = preload("res://Audio/Player/jump_small.ogg")
	dead_sound = preload("res://Audio/Player/death.ogg")
	clear_sound = preload("res://Audio/Player/goal.ogg")
	grow_sound = preload("res://Audio/Player/grow.ogg")
	shrink_sound = preload("res://Audio/Player/shrink.ogg")
	bg_music = get_parent().get_node("AudioStreamPlayer2D")

func _physics_process(delta: float) -> void:
	# Don't update physiscs when dead, in a pipe, or after reaching the goal
	if course_clear:
		emit_signal("clear")
		if !clear_played:
			bg_music.position.x = 5088
			$AudioStreamPlayer2D.stream = clear_sound
			$AudioStreamPlayer2D.play()
			$GoalClear.start(3)
			clear_played = true
		if !is_on_floor():
			velocity = Vector2(0, velocity.y + (get_gravity().y * delta))
		else:
			velocity.y = 0
		sprite.flip_h = false
		sprite.play("run")
		velocity.x = lerp(velocity.x, float(SPEED), 0.25)
		move_and_slide()
		return
	
	if is_dead:
		# Hacky way to fix enemies killing you when dead
		velocity = Vector2(0, velocity.y + (get_gravity().y * 1.25 * delta))
		$HitboxComponent.set_collision_layer_value(1, false)
		$HitboxComponent2.set_collision_layer_value(1, false)
		$PipeHitbox.set_collision_layer_value(1, false)
		$HitboxComponent.set_collision_mask_value(2, false)
		$HitboxComponent2.set_collision_mask_value(2, false)
		move_and_slide()
		return
	else:
		$HitboxComponent.set_collision_layer_value(1, true)
		$HitboxComponent2.set_collision_layer_value(1, true)
		$PipeHitbox.set_collision_layer_value(1, true)
		$HitboxComponent.set_collision_mask_value(2, true)
		$HitboxComponent2.set_collision_mask_value(2, true)
	
	var stomp_box = $HitboxComponent.get_child(0)
	# Add the gravity.
	if not is_on_floor():
		if coyote_time > 0:
			coyote_time -= 1
		if !is_mini:
			velocity += get_gravity() * delta
			if velocity.y > 500:
				velocity.y = 500
			
		else:
			velocity += get_gravity()/2 * delta
			if velocity.y > 200:
				velocity.y = 200
		
		if velocity.y > 0:
			sprite.play("fall")
			
	else:
		stomp_box.scale.y = 1
		coyote_time = 10
			
	if is_on_floor() and velocity == Vector2(0,0):
		if Input.is_action_just_pressed("click") and !is_pinched:
			for area in pinch_area.get_overlapping_areas():
				if area.name == "PointerArea":
					if is_mini and no_grow:
						$AudioStreamPlayer2D.stream = no_grow_sound
						$AudioStreamPlayer2D.play()
					else:
						sprite.play("pinch")
						if !is_mini:
							$AudioStreamPlayer2D.stream = shrink_sound
							$AudioStreamPlayer2D.play()
							animation_player.play("shrink")
							is_mini = true
							JUMP_VELOCITY = -450.0
							SPEED = 200
						else:
							$AudioStreamPlayer2D.stream = grow_sound
							$AudioStreamPlayer2D.play()
							animation_player.play("grow")
							is_mini = false
							JUMP_VELOCITY = -525.0
							SPEED = 300
							
						is_pinched = true

	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("left", "right")
	if direction and !is_pinched:
		facing = direction
		
		if !is_mini:
			velocity.x = lerpf(velocity.x, direction * SPEED, 0.2)
		else:
			velocity.x = lerpf(velocity.x, direction * SPEED, 0.1)
		
		if is_on_floor():
			sprite.play("run")
			
		if direction < 0:
			camera.position.x = lerp(camera.position.x, position.x -20, 0.1)
			sprite.flip_h = true
			
		else:
			camera.position.x = lerp(camera.position.x, position.x + 100, 0.1)
			sprite.flip_h = false
	else:
		velocity.x = lerpf(velocity.x, 0, 0.3)
		if velocity.x < 1 and facing > 0:
			velocity.x = 0
		elif velocity.x > -1 and facing < 0:
			velocity.x = 0
		
	# Force the camera to never go past teh start of the level (< 0)
	if camera.position.x < 190:
		camera.position.x = 190
		
	# Handle jump.
	if Input.is_action_just_pressed("jump") and (is_on_floor() or coyote_time > 0) and !is_pinched:
		if is_mini:
			$AudioStreamPlayer2D.stream = jump_mini_sound
		else:
			$AudioStreamPlayer2D.stream = jump_big_sound
		$AudioStreamPlayer2D.play()
		coyote_time = 0
		velocity.y = JUMP_VELOCITY
		sprite.play("jump")
		
	if velocity.x == 0 and velocity.y == 0 and !is_pinched:
		sprite.play("idle")
		
	if pipe["ready"] and Input.is_action_just_pressed("down") and (pipe["destination"] != Vector2(0,0) or pipe["area"] != null):
		velocity = Vector2(0, 0)
		$AudioStreamPlayer2D.stream = pipe_sound
		$AudioStreamPlayer2D.play()
		sprite.play("enter_pipe")
		animation_player.play("enter_pipe")
		is_pinched = true
		in_pipe = true
		pipe_timer.start(1)
		pipe_animation_timer.start(0.25)

	if position.y > 600:
		var attack: Attack = Attack.new()
		attack.attack_dmg = 999
		$HealthComponent.damage(attack)

	move_and_slide()

func _on_animated_sprite_2d_animation_finished() -> void:
	if is_pinched and !in_pipe:
		is_pinched = false
		

func _on_hitbox_component_area_entered(area: Area2D) -> void:
	if area is HitboxComponent:
		var hitbox: HitboxComponent = area
		
		var attack = Attack.new()
		attack.attack_dmg = 1
		
		hitbox.damage(attack, is_mini)
		velocity.y = JUMP_VELOCITY


func _on_pipe_hitbox_area_entered(area: Area2D) -> void:
	var pipe_area: Pipe = area
	var pipe_object = area.get_parent()
	pipe = {"ready": true, "pipe": pipe_object, "destination": pipe_object.pipe_destination, "area": pipe_object.pipe_dest_area}


func _on_pipe_hitbox_area_exited(area: Area2D) -> void:
	pipe = {"ready": false, "pipe": null, "destination": null, "area": null}


func _on_timer_timeout() -> void:
	if pipe["pipe"] != null:
		var coins = FadeEffect.coins
		FadeEffect.transition()
		await FadeEffect.finished_fade
		if pipe["area"] != null:
			var new_scene: PackedScene = pipe["area"]
			get_tree().change_scene_to_file(new_scene.resource_path)
			return
		FadeEffect.coins = coins
		in_pipe = false
		is_pinched = false
		pipe["ready"] = false
		camera.position.x = pipe["destination"].x
		position = pipe["destination"]
		animation_player.play("exit_pipe")
		sprite.play("jump")
		velocity.y = JUMP_VELOCITY


func _on_timer_2_timeout() -> void:
	if pipe["pipe"] != null:
		pipe["pipe"].get_node("AnimatedSprite2D").play("warping_player")


func _on_health_component_dead() -> void:
	is_dead = true
	death_timer.start(3)
	sprite.play("death")
	$AudioStreamPlayer2D.stream = dead_sound
	$AudioStreamPlayer2D.play()
	z_index = 9


func _on_timer_3_timeout() -> void:
	FadeEffect.transition()
	await FadeEffect.finished_fade
	FadeEffect.coins = 0
	get_tree().reload_current_scene()
	#position = Vector2(0, 424)
	#is_dead = false
	#velocity = Vector2(0, 0)
	#sprite.play("idle")
	#camera.position = lerp(camera.position, Vector2(position.x, 280), 1)
	#camera.zoom = lerp(camera.zoom, Vector2(1, 1), 1)
	#z_index = 0


func _on_up_box_area_entered(area: Area2D) -> void:
	if area.collision_layer == 4 and area.name == "NoGrow":
		no_grow = true


func _on_up_box_area_exited(area: Area2D) -> void:
	if area.collision_layer == 4 and area.name == "NoGrow":
		no_grow = false


func _on_hitbox_component_2_area_entered(area: Area2D) -> void:
	if area.get_parent() is Coin:
		var coin: Coin = area.get_parent()
		coin.collect()
		emit_signal("coin_collected")
		
	if area.get_parent().name == "Goal":
		course_clear = true


func _on_goal_clear_timeout() -> void:
	var hud: CanvasLayer = get_parent().get_node("CanvasLayer")
	hud.hide()
	FadeEffect.transition()
	await FadeEffect.finished_fade
	FadeEffect.coins = 0
	get_tree().change_scene_to_file("res://HUD/credits.tscn")
