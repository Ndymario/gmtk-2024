extends AnimatedSprite2D
signal clicked
signal released

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	self.position = get_global_mouse_position()
	if Input.is_action_just_pressed("click"):
		self.play("pinch")
		clicked.emit()
		
	if Input.is_action_just_released("click"):
		self.play("point")
		released.emit()
