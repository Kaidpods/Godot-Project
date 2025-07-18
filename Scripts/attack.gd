extends Node2D
class_name Attack

var ATTACK_DAMAGE : float = 1.0
var TWO_HAND: bool = false
var RANGE: float = 0
var KNOCKBACK: float = 20

var weapon: Weapon = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func damage(weapon):
	if weapon != null:
		pass
	else:
		pass
