extends Node2D
class_name HealthComponent

@export var MAX_HEALTH : float = 10.0
var health : float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health = MAX_HEALTH

func damage(attack: Attack):
	health += attack.DAMAGE
