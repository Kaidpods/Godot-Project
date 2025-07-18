extends Weapon

var throw_velocity: Vector2 = Vector2.ZERO
var is_thrown: bool = false
var deceleration: float = 1000.0
@export var rotation_speed: float = 50


func throw_weapon():
	is_thrown = true
	var mouse_pos = get_global_mouse_position()
	throw_velocity = (mouse_pos - global_position).normalized() * 800.0
	$CollisionPolygon2D.disabled = false
	collision_layer = 2
	collision_mask = 2

func get_sprite():
	return $Weapon_Sprite

func _physics_process(delta):
	if is_thrown:
		var collision = move_and_collide(throw_velocity * delta)
		if collision:
			throw_velocity = Vector2.ZERO
			is_thrown = false
			collision_layer = 0
			collision_mask = 0
			return

		var speed = throw_velocity.length()
		speed = max(speed - deceleration * delta, 0)
		if speed == 0:
			is_thrown = false
			throw_velocity = Vector2.ZERO
			collision_layer = 0
			collision_mask = 0
		else:
			throw_velocity = throw_velocity.normalized() * speed

		rotation += rotation_speed * delta
