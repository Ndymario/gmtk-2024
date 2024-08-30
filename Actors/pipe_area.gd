extends Area2D
class_name Pipe

var destination
var dest_area

func _ready() -> void:
	destination = get_parent().pipe_destination
	dest_area = get_parent().pipe_dest_area
