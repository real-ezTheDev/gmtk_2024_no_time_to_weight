class_name GymBodyCharacter extends CharacterBody2D

signal energy_changed(value: float)
signal fat_changed(value: float)
signal muscle_changed(value: float)
signal hunger_changed(value: int)
signal name_changed(value: String)
signal satisfaction_changed(value: int)
signal satisfaction_lost()
signal satisfaction_gained()

signal target_reached(body: GymBodyCharacter)
signal energy_depleted(body: GymBodyCharacter)

@onready var gym_body: GymBody = $GymBody
@onready var character_animation_player: AnimationPlayer = $CharacterAnimationPlayer
@onready var navigation: NavigationAgent2D = $NavigationAgent2D as NavigationAgent2D

var search_limit = 12
var search_fail_count = 0

var is_extra_weight := false:
	set(value):
		is_extra_weight = value
		if is_extra_weight:
			$ExtraWeightIcon.visible = true
		else:
			$ExtraWeightIcon.visible = false

var target_position: Vector2:
	set(value):
		target_position = value
		navigation.target_position = target_position
		navigation.avoidance_enabled = true

var status: CustomerStatus:
	set(value):
		status = value
		if !is_node_ready():
			await ready 
		name_changed.emit(status.customer_name)
		energy_changed.emit(status.energy)
		fat_changed.emit(status.fat)
		hunger_changed.emit(status.hunger)
		muscle_changed.emit(status.muscle)
		satisfaction_changed.emit(status.satisfaction)

@export var is_member = false:
	set(value):
		is_member = value
		if !is_node_ready():
			await ready
		if is_member: 
			gym_body.set_to_member()
		else:
			gym_body.set_to_nonmember()
@export var is_working_out = false

var spot_being_used: GymSpot
var is_searching_spot = true
var is_leaving = false
var is_paused = false
var is_returning_weight = false
var target_returning_rack: WeightRack

var speed = 2500
var energy_spend_rate = 1 #per seconds

var beginning_status: CustomerStatus

func stop_everything():
	is_working_out = false
	is_leaving = false
	is_searching_spot = false
	is_paused = true

func _calculate_fat_by_bodyshape(shape: GymBody.BodyShape) :
	match(shape):
		GymBody.BodyShape.FAT:
			return randi_range(80, 100)
		GymBody.BodyShape.SKINNY:
			return randi_range(0, 20)
		GymBody.BodyShape.HEALTHY:
			return randi_range(30, 50)
		GymBody.BodyShape.BUILT:
			return randi_range(15, 25)
			
func _calculate_muscle_by_bodyshape(shape: GymBody.BodyShape):
	match(shape):
		GymBody.BodyShape.FAT:
			return randi_range(20, 60)
		GymBody.BodyShape.SKINNY:
			return randi_range(0, 20)
		GymBody.BodyShape.HEALTHY:
			return randi_range(30, 60)
		GymBody.BodyShape.BUILT:
			return randi_range(80, 100)

func randomize():
	gym_body.primary_color = Color(randf(), randf(), randf(),1)
	gym_body.randomize()
	
	var customer_status = CustomerStatus.new()
	customer_status.customer_name = NameGenerator.get_random_name()
	customer_status.energy = randi_range(5, 40)
	customer_status.hunger = randi_range(1, 40)
	
	var arm_fat: int = 0 
	var leg_fat: int = 0
	var torso_fat: int = 0
	var arm_muscle: int = 0 
	var leg_muscle: int = 0
	var torso_muscle: int = 0
	
	customer_status.fat = (_calculate_fat_by_bodyshape(gym_body.upper_body_shape)*0.4) + \
		_calculate_fat_by_bodyshape(gym_body.lower_body_shape)*0.5 + \
		_calculate_fat_by_bodyshape(gym_body.arm_shape)*0.1
	customer_status.muscle = (_calculate_muscle_by_bodyshape(gym_body.upper_body_shape)*0.3) + \
		_calculate_muscle_by_bodyshape(gym_body.lower_body_shape)*0.3 + \
		_calculate_muscle_by_bodyshape(gym_body.arm_shape)*0.1
	customer_status.satisfaction = randi_range(1,2)
	status = customer_status

func gain_hunger(amount: int):
	status.hunger = min(100 , status.hunger + amount)
	hunger_changed.emit(status.hunger)
	
func spend_hunger(amount: float):
	status.hunger = max(0 , status.hunger - amount)
	hunger_changed.emit(status.hunger)

func gain_energy(amount: float):
	status.energy = min(100 , status.energy + amount)
	energy_changed.emit(status.energy)

func spend_energy(amount: float):
	status.energy = max(0 , status.energy - amount)
	energy_changed.emit(status.energy)

func gain_muscle(amount: float):
	status.muscle = min(100 , status.muscle + amount)
	muscle_changed.emit(status.muscle)

func reduce_muscle(amount: float):
	status.muscle = max(0 , status.muscle - amount)
	muscle_changed.emit(status.muscle)

func gain_fat(amount: int):
	status.fat = min(100 , status.fat + amount)
	fat_changed.emit(status.fat)

func reduce_fat(amount: float):
	status.fat = max(0 , status.fat - amount)
	fat_changed.emit(status.fat)
	
func increase_satisfaction(amount: int):
	status.satisfaction = min(3, status.satisfaction + amount)
	satisfaction_changed.emit(status.satisfaction)
	satisfaction_gained.emit()
		
func decrease_satisfaction(amount: int):
	status.satisfaction = max(0, status.satisfaction - amount)
	satisfaction_changed.emit(status.satisfaction)
	satisfaction_lost.emit()

func highlight():
	(gym_body.material as ShaderMaterial).set_shader_parameter("line_thickness", 2.)
	
func unhighlight():
	(gym_body.material as ShaderMaterial).set_shader_parameter("line_thickness", 0.)

func display_status():
	$Name.visible = true
	$StatusWindow.visible = true
	highlight()
	
func close_status():
	$Name.visible = false
	$StatusWindow.visible = false
	unhighlight()
	
func start_day():
	beginning_status = status.duplicate()
	target_returning_rack = null
	search_fail_count = 0
	is_extra_weight = false
	is_paused = false

func _ready():
	close_status()

func _physics_process(delta: float) -> void:
	if is_paused:
		return

	if !navigation.is_target_reachable():
		target_reached.emit(self)
		
	if !navigation.is_navigation_finished():
		var direction = global_position.direction_to(navigation.get_next_path_position())
		velocity = direction * speed * delta
		navigation.velocity = velocity
		move_and_slide()
	
	if navigation.is_target_reached():
		navigation.avoidance_enabled = false
		is_working_out = true
		target_reached.emit(self)

func _process(delta):
	if is_paused:
		return
	
	if is_extra_weight && status.hunger <= 10:
		$StatusWindow/VBoxContainer/Muscle/TextureProgressBar.set_bonus(-2)
	elif is_extra_weight:
		$StatusWindow/VBoxContainer/Muscle/TextureProgressBar.set_bonus(1)
	elif status.hunger <= 10:
		$StatusWindow/VBoxContainer/Muscle/TextureProgressBar.set_bonus(-1)
	else:
		$StatusWindow/VBoxContainer/Muscle/TextureProgressBar.set_bonus(0)

	if is_working_out:
		var workout_multiplier = 1
		var muscle_multiplier = 1
		if is_extra_weight:
			muscle_multiplier += 3
			workout_multiplier += 2
			
		var energy_amount = delta * energy_spend_rate * workout_multiplier

		spend_energy(energy_amount)
		
		if status.fat <= 5:
			spend_hunger(0.005 * workout_multiplier)
		
		var muscle_gain_rate: float = (status.hunger-9)/200.
		if status.hunger <= 10:
			reduce_muscle(0.0005 * muscle_multiplier)
		else:
			gain_muscle(muscle_gain_rate * delta * muscle_multiplier)
		
		var fat_reduce_rate: float = status.muscle/100.
		reduce_fat(fat_reduce_rate * delta * workout_multiplier)
	
	if !is_working_out && character_animation_player.current_animation != "walk":
		character_animation_player.play("walk")
		character_animation_player.speed_scale = speed / 1500
	elif is_working_out && character_animation_player.current_animation != "work":
		character_animation_player.play("work")

func _on_character_animation_player_animation_changed(old_name: StringName, new_name: StringName) -> void:
	if old_name == "walk":
		character_animation_player.speed_scale = 1

func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	set_velocity(safe_velocity)
	move_and_slide()

func _on_interaction_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("exercise_spot") && area.global_position == target_position:
		if (area as GymSpot).is_used:
			search_fail_count += 1
			target_reached.emit(self)
		else:
			is_searching_spot = false
			(area as GymSpot).is_used = true
			spot_being_used = area

func _on_energy_changed(value: float) -> void:
	if value == 0:
		is_leaving = true
		if spot_being_used:
			spot_being_used.is_useds = false
		is_working_out = false
		if status.muscle - beginning_status.muscle > 0:
			increase_satisfaction(1)
		else:
			decrease_satisfaction(1)
		energy_depleted.emit(self)

func _change_shape_per_body_fat_ratio():
	pass

func _on_fat_changed(value: float) -> void:
	_change_shape_per_body_fat_ratio()

func _on_muscle_changed(value: float) -> void:
	_change_shape_per_body_fat_ratio()
