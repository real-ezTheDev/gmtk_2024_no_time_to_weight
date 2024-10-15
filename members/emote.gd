class_name EmoteBox extends Sprite2D

var time_since_shown = 0

const SHOW_LIMIT = 5

func _process(delta):
	if !visible:
		return
		
	time_since_shown += delta
	
	if time_since_shown >= 5:
		clear_box()

func clear_box():
	visible = false
	for child in get_children():
		child.visible = false

func show_happy():
	clear_box()
	time_since_shown = 0
	visible = true
	$Happy.visible = true

func show_angry():
	clear_box()
	time_since_shown = 0
	visible = true
	$Angry.visible = true

func _on_gym_body_character_satisfaction_lost() -> void:
	show_angry()


func _on_gym_body_character_satisfaction_gained() -> void:
	show_happy()
