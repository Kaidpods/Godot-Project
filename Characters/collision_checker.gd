extends Area2D

@export var Sprite: Sprite2D

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("CollisionMasking"):
		print("Area entered")
		Sprite.z_index = 1
		

func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("CollisionMasking"):
		print("Area Exited")
		Sprite.z_index = 2
		
