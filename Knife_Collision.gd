class_name Knife extends Area2D

@onready var Clickable: CollisionShape2D = $Clickable_Area

@export var prompt_ui: CanvasLayer

var hand_area : bool = false
var target_alpha := 0.0
var held := false
var player = null

#Label and panel for editing
var panel : Panel
var label : Label
# Speed of fade (higher = faster)
var fade_speed := 5.0

func _ready():
	var players = get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		player = players[0]
	else:
		print("Something has happened!")
		
	
	panel = prompt_ui.get_node("Panel")
	label = panel.get_node("Label")
	panel.modulate.a = 0.0
	prompt_ui.hide()
	panel.rotation = 0.0

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pickup") and hand_area == true:
		if not held and player.has_weapon() == false:
			player.pickup_weapon(get_parent(), 0)
			held = true



func _on_mouse_entered() -> void:
	target_alpha = 1.0
	prompt_ui.show()


func _on_mouse_exited() -> void:
	target_alpha = 0.0

func _process(delta):
	if prompt_ui.visible:
		var mouse_pos = get_viewport().get_mouse_position()
		# Move slightly above the cursor
		panel.position = mouse_pos + Vector2(-56, -60)
		
		# Fade logic
	var current_alpha = panel.modulate.a
	current_alpha = lerp(current_alpha, target_alpha, fade_speed * delta)
	panel.modulate.a = current_alpha

	# Optionally hide when fully transparent
	if target_alpha == 0.0 and current_alpha < 0.01:
		prompt_ui.hide()


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Hand_Binding"):
		label.text = "Press F to pick up"
		hand_area = true


func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("Hand_Binding"):
		label.text = "Not close enough"
		hand_area = false
		
