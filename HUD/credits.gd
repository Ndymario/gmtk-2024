extends Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Timer.start(10)


func _on_timer_timeout() -> void:
	FadeEffect.transition()
	await FadeEffect.finished_fade
	get_tree().quit()
