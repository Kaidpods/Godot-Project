class_name Player extends CharacterBody2D

@onready var _silhouette_sprite : Sprite2D = $Silhouette
@onready var attack:= $Attack

@export var ANIMATION_TREE : AnimationTree
@export var MOVEMENT_SPEED : float = 60
@export var VERTICAL_SPEED : float = 30
@export var ACCELERATION := 400
@export var FRICTION := 600
@export var THROW_SPEED:= 300

#For weapons assignment
var weapon_in_hand : Node2D = null
@onready var weapon_holder = $Bone2D2/Hands/WeaponAttach
var flipped_weapon: bool = false
var input
var playback: AnimationNodeStateMachinePlayback

func _ready():
	playback = ANIMATION_TREE["parameters/playback"]
	

func _physics_process(delta: float) -> void:
	ANIMATION_TREE["parameters/Idle/blend_position"] = get_local_mouse_position()
	ANIMATION_TREE["parameters/Walk/blend_position"] = get_local_mouse_position()
	
	player_movement(delta)
	
	if has_weapon():
		flip_weapon()
	select_animation()
	update_animation_params()

func player_movement(delta):
	input = Input.get_vector("left", "right", "up", "down")
	input.normalized()
	
	if input == Vector2.ZERO:
		if velocity.length() > (FRICTION * delta):
			velocity -= velocity.normalized() * (FRICTION * delta)
		else:
			velocity = Vector2.ZERO
	else:
		var target_velocity = Vector2.ZERO
		target_velocity.x = input.x * MOVEMENT_SPEED
		target_velocity.y = input.y * VERTICAL_SPEED
		
		velocity.x = move_toward(velocity.x, target_velocity.x, ACCELERATION * delta)
		velocity.y = move_toward(velocity.y, target_velocity.y, ACCELERATION * delta)
	move_and_slide()

func flip_weapon():
	var sprite: Sprite2D = weapon_in_hand.get_node("Sprite2D")
	var mouse_pos = get_global_mouse_position()
	var to_mouse = mouse_pos - global_position
	var target_angle = to_mouse.angle()
	if target_angle > -1.57 and target_angle < 1.4 and flipped_weapon == false:
		weapon_rotation(weapon_in_hand, 3.14159)
		flipped_weapon = true
		print("test")
	elif target_angle < -1.57 and flipped_weapon == true or target_angle > 1.4 and flipped_weapon == true:
		weapon_rotation(weapon_in_hand, -3.14159)
		flipped_weapon = false
		print("test2")

func select_animation():
	if velocity == Vector2.ZERO:
		playback.travel("Idle")
	else:
		playback.travel("Walk")

func update_animation_params():
	if input == Vector2.ZERO:
		return
		
	ANIMATION_TREE["parameters/Idle/blend_position"] = get_local_mouse_position()
	ANIMATION_TREE["parameters/Walk/blend_position"] = get_local_mouse_position()

func has_weapon():
	if weapon_in_hand != null:
		return true
	else:
		return false

func pickup_weapon(weapon, excess_rotation):
	weapon_in_hand = weapon
	attack.weapon = weapon_in_hand
	weapon.get_node("Area2D").held = true
	weapon.get_node("Area2D/Clickable_Area").disabled = true
	
	var hold_point = weapon.get_node("Hold_Point")
	
	# Get the Rotation
	var hold_point_global_rotation = hold_point.global_rotation
	# Get the knife rotation
	var knife_global_rotation = weapon.global_rotation
	# Reparent
	weapon.get_parent().remove_child(weapon)
	weapon_holder.add_child(weapon)
	

	var new_weapon_global_rotation = knife_global_rotation
	# Compute new transform so HoldPoint matches WeaponHolder

	new_weapon_global_rotation += weapon_holder.global_rotation - hold_point_global_rotation

	# Apply
	weapon.global_rotation = new_weapon_global_rotation
	weapon.position = hold_point.position
	

	# Fix scale
	weapon.scale = Vector2.ONE
	

func weapon_rotation(weapon, rotation):
	weapon.rotate(rotation)
	var hold_point = weapon.get_node("Hold_Point")

	
	# Get the Rotation
	var hold_point_global_rotation = hold_point.global_rotation

	# Get the knife rotation
	var knife_global_rotation = weapon.global_rotation

	var new_weapon_global_rotation = knife_global_rotation
	# Compute new transform so HoldPoint matches WeaponHolder
	
	new_weapon_global_rotation += weapon_holder.global_rotation - hold_point_global_rotation

	# Apply
	weapon.global_rotation = new_weapon_global_rotation
	weapon.position = hold_point.position
	

	# Fix scale
	weapon.scale = Vector2.ONE
	



func drop_weapon():
	if weapon_in_hand:
		var weapon = weapon_in_hand
		weapon_holder.remove_child(weapon)
		get_parent().add_child(weapon) # Drop back to scene root or parent
		weapon.global_position = weapon_holder.global_position
		weapon.get_node("Area2D/Clickable_Area").disabled = false
		
		# Optional: apply throw velocity
		if weapon.has_method("throw_weapon"):
			weapon.throw_weapon()
			
		weapon.get_node("Area2D").held = false
		weapon_in_hand = null
		attack.weapon = null

func throw_weapon():
	pass

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("drop_weapon") and has_weapon():
		var weapon = weapon_in_hand
		drop_weapon()
		weapon.get_node("Area2D").held = false
		print("Something?")
