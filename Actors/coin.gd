extends Node2D
class_name Coin

var collect_sound

func _ready() -> void:
	collect_sound = preload("res://Audio/Coin/coin.ogg")

func collect():
	if !$AudioStreamPlayer2D.playing:
		$AudioStreamPlayer2D.stream = collect_sound
		$AudioStreamPlayer2D.play()
	var sprite: AnimatedSprite2D = get_node("AnimatedSprite2D")
	var new_material: CanvasItemMaterial = CanvasItemMaterial.new()
	new_material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	new_material.light_mode = CanvasItemMaterial.LIGHT_MODE_NORMAL
	sprite.material = new_material
	position.y -= 10
	
	sprite.play("collect")


func _on_animated_sprite_2d_animation_finished() -> void:
	queue_free()
