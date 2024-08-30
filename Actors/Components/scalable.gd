extends Area2D

# If we wanna disable scaling when this object normally has scaling
@export var scale_enabled: bool = true
@export var scale_points: int = 10

# Simple calculation that determines how many scale points are needed
#	Negative = Refund of points
func calc_points(scale_vec: Vector2, curr_scale: Vector2) -> int:
	var final_scale = scale_vec - curr_scale
	var x_points = final_scale.x
	var y_points = final_scale.y
	
	return x_points + y_points

func try_scale(scaler_points: int, scale_vec: Vector2) -> bool:
	if !scale_enabled:
		return false
	
	# If the total amount of points needed exceeds how many the scaler has,
	#	fail to scale the actor
	if calc_points(scale_vec, get_parent().size) > scaler_points:
		return false
	
	return true

# Scales the target node, returning what the "cost" of this scale is.
#	We assume the try_scale function has been called to validate the scale eco.
#	Not bundling the check lets scripted events happen
func scale(scale_vec: Vector2) -> int:
	get_parent().size = scale_vec
	return calc_points(scale_vec, get_parent().size)
