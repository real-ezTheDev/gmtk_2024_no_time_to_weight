class_name Gym extends Node2D

signal gym_closed()

signal cash_changed(amount: int)
signal gains_changed(amount: int)
signal burn_changed(amount: int)

@export var camera: Camera2D

@onready var player_character: PlayerCharacter = $PlayerCharacter as PlayerCharacter
@onready var player_body: GymBody = $PlayerCharacter/GymBody as GymBody
@onready var spawn: Node2D = $SpawnPoint
@onready var exit: Node2D = $ExitPoint
@onready var exercise_spots = $ExerciseSpot

var has_tutorial_shown = false

var cash: int = 0:
	set(value):
		cash = value
		cash_changed.emit(cash)
		
var gains: int = 0:
	set(value):
		gains = value
		gains_changed.emit(gains)
	
var burns: int = 0:
	set(value):
		burns = value
		burn_changed.emit(burns)

var starting_weight_count = 1
var starting_juice_count = 5
var _count = 4
var spawn_rate: float = 10 #per min
var time_since_last_spawn:float = 0

const GYM_SIZE = Rect2(0, 0, 1152, 648)
const CHARACTER_SCN: PackedScene = preload("res://members/gym_body_character.tscn")

#group names
const group_customers := "customer"
const group_members := "member"
const group_weights := "weight"
const group_player := "player"

var is_gym_open = false	

var known_customers: Array[GymBodyCharacter] = []
var end_of_day_customers: Array[GymBodyCharacter] = []

var spot_used: Dictionary = {}

var gym_hour: float = 2
var current_hour: float = 0

var customer_target_spot_index: Dictionary = {}

func customize_player_character(
	color: Color,\
	upper: GymBody.BodyShape,\
	lower: GymBody.BodyShape,\
	arms: GymBody.BodyShape,\
	hair_index: int,\
	accessory_index: int):
	
	player_body.primary_color = color
	player_body.arm_shape = arms
	player_body.upper_body_shape = upper
	player_body.lower_body_shape = lower
	player_body.accessory.index = accessory_index
	player_body.hair.index= hair_index
	player_body.set_to_trainer()

func send_customer_home(body: GymBodyCharacter):
	body.target_position = exit.global_position
	
func return_weight_to_rack(body: GymBodyCharacter):
	body.is_returning_weight = true
	var closest_empty_weight_rack
	var current_shortest_distance = 0
	for child in get_tree().get_nodes_in_group("weight_rack"):
		if (child as WeightRack).weight_count + (child as WeightRack).incoming_count  >= (child as WeightRack).MAX_COUNT:
			continue

		var distance_to_rack = child.global_position.distance_to(body.global_position)
		if closest_empty_weight_rack == null || distance_to_rack <= current_shortest_distance:
			closest_empty_weight_rack = child
			current_shortest_distance = distance_to_rack

	closest_empty_weight_rack.incoming_count += 1 
	body.target_returning_rack = closest_empty_weight_rack
	body.target_position = closest_empty_weight_rack.get_return_position()
	
func spawn_character_body(pos: Vector2):
	if known_customers.is_empty():
		var character_body: GymBodyCharacter = CHARACTER_SCN.instantiate() as GymBodyCharacter
		character_body.target_reached.connect(_customer_target_reached)
		character_body.energy_depleted.connect(_custom_energy_depleted)
		character_body.add_to_group(group_customers)
		character_body.position = pos

		add_child(character_body)
		
		character_body.randomize()
		character_body.start_day()

		#navigation setup
		var target_spot_index = randi_range(0, exercise_spots.get_children().size()-1)
		character_body.target_position = exercise_spots.get_child(target_spot_index).global_position
		character_body.is_searching_spot = true
		customer_target_spot_index[character_body] = target_spot_index
	else:
		var return_customer = known_customers.filter(func (character: GymBodyCharacter):
			return character.status.satisfaction > 0).pick_random()
		known_customers.remove_at(known_customers.find(return_customer))
		return_customer.start_day()
		return_customer.position = pos

		add_child(return_customer)
		
		#navigation setup
		var target_spot_index = randi_range(0, exercise_spots.get_children().size())
		return_customer.target_position = exercise_spots.get_child(target_spot_index).global_position
		return_customer.is_searching_spot = true
		customer_target_spot_index[return_customer] = target_spot_index

func start():
	if !has_tutorial_shown:
		$CanvasLayer/HungerTutorial.visible = true
		await $CanvasLayer/HungerTutorial.tutorial_finished
		
		$CanvasLayer/MuscleTutorial.visible = true
		await $CanvasLayer/MuscleTutorial.tutorial_finished
		has_tutorial_shown = true
		
	#known_customers.append(end_of_day_customers)
	for customer in end_of_day_customers:
		customer.queue_free()
	end_of_day_customers = []
	spawn_character_body(spawn.position)
	is_gym_open = true
	
	#upgrades
	if PlayerUpgrade.is_4hour_fitness:
		gym_hour = 4
	if PlayerUpgrade.is_8hour_fitness:
		gym_hour = 8
	if PlayerUpgrade.is_12hour_fitness:
		gym_hour = 12
		
	if PlayerUpgrade.is_word_of_mouth:
		spawn_rate = 15
	if PlayerUpgrade.is_marketing_101:
		spawn_rate = 30
		pass
		
	if PlayerUpgrade.is_more_juice:
		starting_juice_count = 9
	if PlayerUpgrade.is_even_more_juice:
		starting_juice_count = 14
		
	if PlayerUpgrade.is_more_weight:
		starting_weight_count = 4
	if PlayerUpgrade.is_even_more_weight:
		starting_weight_count = 8

	for rack in get_tree().get_nodes_in_group("weight_rack"):
		(rack as WeightRack).weight_count = starting_weight_count
		
	for juice in get_tree().get_nodes_in_group("juice_station"):
		(juice as JuiceStation).current_juice_count = starting_juice_count

	current_hour = gym_hour
	$CanvasLayer.visible = true

func gym_close_clean_up():
	is_gym_open = false
	for customer in get_tree().get_nodes_in_group(group_customers):
		remove_child(customer)
		end_of_day_customers.push_back(customer)
	gym_closed.emit()
	customer_target_spot_index = {}
	player_character.drop_item()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !is_gym_open:
		return
		
	if camera:
		camera.position = player_character.global_position
		
	current_hour -= ((delta/60) * 2)
	$CanvasLayer/GymHourProgress.value = current_hour
	if current_hour <= 0:
		gym_close_clean_up()
		return
		
	time_since_last_spawn += delta
	
	if (spawn_rate/60) * time_since_last_spawn >= 1:
		time_since_last_spawn = 0
		spawn_character_body(spawn.position)

func _customer_target_reached(reached_body: GymBodyCharacter):
	if !reached_body.is_working_out:
		if reached_body.search_fail_count >= reached_body.search_limit:
			reached_body.decrease_satisfaction(1)
			send_customer_home(reached_body)
			return
		
		var current_spot_index = customer_target_spot_index.get(reached_body)
		var next_spot_index =  posmod(current_spot_index+1,exercise_spots.get_children().size())
		reached_body.target_position = exercise_spots.get_children()[next_spot_index].global_position
		customer_target_spot_index[reached_body] = next_spot_index
	elif reached_body.is_returning_weight:
		reached_body.is_returning_weight = false
		reached_body.target_returning_rack.weight_count += 1
		reached_body.target_returning_rack.incoming_count -= 1
		reached_body.is_extra_weight = false
		reached_body.target_returning_rack = null
		send_customer_home(reached_body)
	elif reached_body.is_leaving:
		reached_body.is_leaving = false
		remove_child(reached_body)
		end_of_day_customers.push_back(reached_body)

func _custom_energy_depleted(body: GymBodyCharacter):
	if body.is_leaving && body.is_extra_weight:
		return_weight_to_rack(body)
	else:
		send_customer_home(body)
