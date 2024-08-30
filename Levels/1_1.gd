extends Node2D

func _ready() -> void:
	$AudioStreamPlayer2D.stream = load("res://Audio/Music/Underground.ogg")
	$AudioStreamPlayer2D.play()

func _physics_process(delta: float) -> void:
	$AudioStreamPlayer2D.position = $Player.position
	if !$AudioStreamPlayer2D.playing:
		$AudioStreamPlayer2D.play()
