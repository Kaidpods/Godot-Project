extends CharacterBody3D

@export var MOVEMENT_SPEED : float = 60
@export var ACCELERATION := 400
@export var FRICTION := 600
@export var GRAVITY : float = 4.6
@export var JUMP_FORCE : float = 6

@onready var ANIMATION_TREE := $Sprite3D/SubViewport/Node2D/AnimationTree
var input
var playback: AnimationNodeStateMachinePlayback


func _ready():
	playback = ANIMATION_TREE["parameters/playback"]
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	ANIMATION_TREE["parameters/Idle/blend_position"] = get_mouse_world_position()
	ANIMATION_TREE["parameters/Walk/blend_position"] = get_mouse_world_position()
	
	player_movement(delta)
	
	select_animation()
	update_animation_params()

func player_movement(delta: float) -> void:
	# 2D input: X = right/left, Y = down/up (convert to -Z forward if you prefer).
	var input_dir := Vector2(
		Input.get_action_strength("left") - Input.get_action_strength("right"),
		Input.get_action_strength("up") - Input.get_action_strength("down")
	)
	if input_dir.length() > 0.0:
		input_dir = input_dir.normalized()

	# Convert 2D input to world-space X/Z movement
	var direction := Vector3.ZERO
	if input_dir != Vector2.ZERO:
		# Use the character's basis so movement is relative to character facing.
		var raw := transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)
		# zero out Y explicitly and normalize
		direction = Vector3(raw.x, 0.0, raw.z).normalized()

	# Horizontal movement (X and Z)
	if direction == Vector3.ZERO:
		# Apply friction to horizontal components
		var horizontal := Vector3(velocity.x, 0.0, velocity.z)
		if horizontal.length() > FRICTION * delta:
			horizontal -= horizontal.normalized() * (FRICTION * delta)
		else:
			horizontal = Vector3.ZERO
		velocity.x = horizontal.x
		velocity.z = horizontal.z
	else:
		var target_velocity := direction * MOVEMENT_SPEED
		velocity.x = move_toward(velocity.x, target_velocity.x, ACCELERATION * delta)
		velocity.z = move_toward(velocity.z, target_velocity.z, ACCELERATION * delta)

	# Gravity & jump (vertical)
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	else:
		if Input.is_action_just_pressed("jump"):
			velocity.y = JUMP_FORCE
		else:
			# ensure small downward/zero when grounded
			velocity.y = 0.0

	# Finally, move. Do NOT assign the result to velocity.
	move_and_slide()

func get_mouse_world_position() -> Vector3:
	var camera = get_viewport().get_camera_3d()
	if not camera:
		return global_position

	var mouse_pos = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * 1000.0

	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	var result = space_state.intersect_ray(query)

	if result:
		return result.position
	else:
		return global_position

func get_mouse_direction_relative_to_player() -> Vector2:
	var mouse_world_pos = get_mouse_world_position()
	var to_mouse = mouse_world_pos - global_position
	to_mouse.y = 0  # ignore vertical difference

	# Convert to local space (relative to player's facing)
	var local_dir = global_transform.basis.inverse() * to_mouse.normalized()
	
	# Return 2D vector (x = left/right, y = forward/back)
	return Vector2(local_dir.x, -local_dir.z)  # negative Z = forward



func select_animation():
	if velocity.length() < 0.1:
		playback.travel("Idle")
	else:
		playback.travel("Walk")

func update_animation_params():
	var mouse_dir = get_mouse_direction_relative_to_player()
	
	ANIMATION_TREE["parameters/Idle/blend_position"] = mouse_dir
	ANIMATION_TREE["parameters/Walk/blend_position"] = mouse_dir
