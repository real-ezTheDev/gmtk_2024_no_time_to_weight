extends Node2D

@onready var transition_animation: AnimationPlayer = $TransitionAnimation as AnimationPlayer

@onready var character_creation: Node2D = $CharacterCreation
@onready var gym: Gym = $Gym as Gym
@onready var scoring: Scoring = $Scoring as Scoring
@onready var upgrade: UpgradeStore = $UpgradeStore as UpgradeStore
@onready var victory_royale: VictoryRoyale = $VictoryRoyale as VictoryRoyale


const CAMERA_RESET_VECTOR:= Vector2(576,324)

func _ready():
	remove_child(gym)
	remove_child(scoring)
	remove_child(victory_royale)
	remove_child(upgrade)

func _on_character_creation_character_created(gym_body: GymBody) -> void:
	transition_animation.play("transition_out")
	await transition_animation.animation_finished
	$Creepy.play()
	character_creation.visible = false
	remove_child(character_creation)
	
	add_child(gym)
	gym.visible = true
	gym.customize_player_character(
		gym_body.primary_color, gym_body.upper_body_shape, gym_body.lower_body_shape, gym_body.arm_shape, gym_body.hair.index, gym_body.accessory.index)
	transition_animation.play("transition_in")
	gym.camera = $Camera2D
	gym.start()
	await transition_animation.animation_finished

func _on_gym_gym_closed() -> void:
	transition_animation.play("transition_out")
	$Creepy.stop()
	$BackgroundMusic.play()
	await transition_animation.animation_finished
	
	gym.visible = false
	remove_child(gym)
	
	$Camera2D.position_smoothing_enabled = false
	$Camera2D.drag_horizontal_enabled = false
	$Camera2D.drag_vertical_enabled = false
	$Camera2D.position = CAMERA_RESET_VECTOR
	
	add_child(scoring)
	scoring.visible = true

	scoring.add_customers(gym.end_of_day_customers)
	
	transition_animation.play("transition_in")
	await transition_animation.animation_finished
	scoring.start_scoring()

func _on_scoring_score_finished(muscle_gained: int, fat_burnt: int, cash_gained: int) -> void:
	transition_animation.play("transition_out")
	await transition_animation.animation_finished

	scoring.visible = false
	scoring.clean_up()
	remove_child(scoring)
	
	if muscle_gained >= 4500 && fat_burnt >= 8000:
		#victory
		victory_royale.visible = true
		add_child(victory_royale)
		victory_royale.start()
		transition_animation.play("transition_in")
	else:
		add_child(upgrade)
		upgrade.visible = true
		transition_animation.play("transition_in")
		upgrade.start_upgrade(muscle_gained, fat_burnt)

func _on_upgrade_store_upgrade_finished() -> void:
	transition_animation.play("transition_out")
	await transition_animation.animation_finished
	remove_child(upgrade)
	
	add_child(gym)
	gym.visible = true
	$BackgroundMusic.stop()
	$Creepy.play()
	gym.start()
	$Camera2D.position_smoothing_enabled = true
	$Camera2D.position_smoothing_enabled = false
	$Camera2D.drag_horizontal_enabled = true
	$Camera2D.drag_vertical_enabled = true
	transition_animation.play("transition_in")
