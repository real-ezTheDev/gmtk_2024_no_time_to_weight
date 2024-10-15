extends Node2D

signal character_created(gym_body: GymBody)
@onready var gym_body: GymBody = $GymBody

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	gym_body.set_to_trainer()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_confirm_pressed() -> void:
	$DoneSound.play()
	$AnimationPlayer.play("transition_to_face")

func _on_randomize_pressed() -> void:
	$DoneSound.play()
	$GymBody.randomize()
	$GymBody.update_labels()

func _on_button_pressed() -> void:
	#play some end of character creation animation
	$DoneSound.play()
	$AnimationPlayer.play("character_complete")
	await $AnimationPlayer.animation_finished
	character_created.emit(gym_body)

func _on_click_sound() -> void:
	$ClickSound.play()
	pass # Replace with function body.
