class_name Scoring extends Node2D

signal scale_spawn_finished()
signal score_finished(muscle_gained, fat_burnt, cash_gained)

var has_tutorial_shown = false
var has_goal_shown = false
var customers_to_score: Array[RigidCustomer]
var is_scoring := false


@export var spawn_rate = 8 #per second
var time_since_last_spawn:float = 0

const RIGID_CUSTOMER_SCN = preload("res://mains/EndOfDayScore/RigidCustomer.tscn")
func add_customers(customers: Array[GymBodyCharacter]):
	customers_to_score = []
	for customer_character in customers:
		var rigid_customer: RigidCustomer = RIGID_CUSTOMER_SCN.instantiate() as RigidCustomer
		rigid_customer.set_customer_details(customer_character)
		customers_to_score.push_back(rigid_customer)

func clean_up():
	# remove spawned bodies from previous scoring
	for child in $DropSpawn.get_children():
		child.queue_free()
	$ScoreResult/MuscleGain/plus.text = "0"
	$ScoreResult/MuscleGain/minus.text = "0"
	$ScoreResult/MuscleGain/total.text = "0"
	$ScoreResult/FatBurn/plus.text = "0"
	$ScoreResult/FatBurn/minus.text = "0"
	$ScoreResult/FatBurn/total.text = "0"
	$ScoreResult/HBoxContainer/total.text = "0"

func start_scoring():
	if !has_tutorial_shown:
		$CanvasLayer/ScoringTutorial.visible = true
		await $CanvasLayer/ScoringTutorial.tutorial_finished
		has_tutorial_shown = true
	is_scoring = true
	
func spawn_next_rigid_customer():
	var rigid_customer: RigidCustomer = customers_to_score.pop_front() as RigidCustomer
	rigid_customer.rotation = randf_range(0, PI)
	
	var muscle_diff: float = round(rigid_customer.get_muscle_gained()*10)
	if muscle_diff  >= 0:
		$ScoreResult/MuscleGain/plus.text = str(int($ScoreResult/MuscleGain/plus.text) + muscle_diff)
	else:
		$ScoreResult/MuscleGain/minus.text = str(int($ScoreResult/MuscleGain/minus.text) + abs(muscle_diff))
	
	$ScoreResult/MuscleGain/total.text = str(max(0, \
		int($ScoreResult/MuscleGain/plus.text) - int($ScoreResult/MuscleGain/minus.text)))
	
	var fat_burnt: float = round(rigid_customer.get_fat_lost() * 10)
	if fat_burnt  >= 0:
		$ScoreResult/FatBurn/plus.text = str(int($ScoreResult/FatBurn/plus.text) + fat_burnt)
	else:
		$ScoreResult/FatBurn/minus.text = str(int($ScoreResult/FatBurn/minus.text) + abs(fat_burnt))
	$ScoreResult/FatBurn/total.text = str(max(0,\
		int($ScoreResult/FatBurn/plus.text) - int($ScoreResult/FatBurn/minus.text)))
		
	if rigid_customer.is_member:
		$ScoreResult/HBoxContainer/total.text = str(int($ScoreResult/HBoxContainer/total.text) + 10)
		
	$DropSpawn.add_child(rigid_customer)
	
func _process(delta: float):
	if !is_scoring:
		return
	
	if customers_to_score.is_empty():
		is_scoring = false
		var muscle_gain_total = int($ScoreResult/MuscleGain/total.text)
		var fat_burnt = int($ScoreResult/FatBurn/total.text)
		var cash_gained = int($ScoreResult/HBoxContainer/total.text )
		await get_tree().create_timer(4).timeout 
		scale_spawn_finished.emit()
		score_finished.emit(muscle_gain_total, fat_burnt, cash_gained)
		return

	time_since_last_spawn += delta
	var multiples = min(floor(time_since_last_spawn*spawn_rate), customers_to_score.size())
	
	if multiples >= 1:
		$DropSound.play()
		time_since_last_spawn -= (multiples/spawn_rate)
		
		for i in multiples:
			spawn_next_rigid_customer()
			
