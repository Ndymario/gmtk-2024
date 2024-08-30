extends CanvasLayer

signal finished_fade

@onready var color_rect: ColorRect = get_node("ColorRect")
@onready var animation_player: AnimationPlayer = get_node("AnimationPlayer")
var coins: int

func _ready() -> void:
	color_rect.visible = false

func transition():
	color_rect.visible = true
	animation_player.play("fade_to_black")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fade_to_black":
		finished_fade.emit()
		animation_player.play("fade_in")
	elif anim_name == "fade_in":
		color_rect.visible = false
