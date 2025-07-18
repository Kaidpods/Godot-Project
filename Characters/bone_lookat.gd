extends Bone2D

@export var rotation_speed : float = 5.0  # Adjust for smoothness

func _process(delta):
	var mouse_pos = get_global_mouse_position()
	var to_mouse = mouse_pos - global_position
	var target_angle = to_mouse.angle()
	
	
	# Interpolate smoothly
	rotation = lerp_angle(rotation, target_angle, rotation_speed * delta)
