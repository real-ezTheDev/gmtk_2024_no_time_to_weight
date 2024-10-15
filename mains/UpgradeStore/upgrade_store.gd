class_name UpgradeStore extends CanvasLayer

signal upgrade_finished()

func _has_enough(gained: int, burnt: int) -> bool:
	return gained <= int($PlayerStatus/MuscleGained/Label.text) && burnt <= int($PlayerStatus/FatBurnt/Label.text)

func _reduce_amount(gained: int, burnt: int):
	$PlayerStatus/MuscleGained/Label.text = str(int($PlayerStatus/MuscleGained/Label.text) - gained)
	$PlayerStatus/FatBurnt/Label.text= str(int($PlayerStatus/FatBurnt/Label.text) - burnt)
	
func update_button_status():
	if PlayerUpgrade.is_4hour_fitness:
		$HBoxContainer/Hour/FourHour.is_purchased = true
		($HBoxContainer/Hour/EightHour as UpgradeButton).is_locked = false
	
	if PlayerUpgrade.is_8hour_fitness:
		$HBoxContainer/Hour/EightHour.is_purchased= true
		$HBoxContainer/Hour/TwelveHour.is_locked = false
		
	if PlayerUpgrade.is_12hour_fitness:
		$HBoxContainer/Hour/TwelveHour.is_purchased = true

	if PlayerUpgrade.is_word_of_mouth:
		$HBoxContainer/Ad/WordOfMouth.is_purchased = true
		$HBoxContainer/Ad/Marketing.is_locked = false
		
	if PlayerUpgrade.is_marketing_101:
		$HBoxContainer/Ad/Marketing.is_purchased = true
		
	if PlayerUpgrade.is_more_juice:
		$HBoxContainer/Juice/Juiced.is_purchased = true
		$HBoxContainer/Juice/MaxJuice.is_locked = false
		
	if PlayerUpgrade.is_even_more_juice:
		$HBoxContainer/Juice/MaxJuice.is_purchased = true
		
	if PlayerUpgrade.is_more_weight:
		$HBoxContainer/Weight/WeightTraining.is_purchased = true
		$HBoxContainer/Weight/MaxWeight.is_locked = false
		
	if PlayerUpgrade.is_even_more_weight:
		$HBoxContainer/Weight/MaxWeight.is_purchased = true

func start_upgrade(gained: int, burnt: int):
	$PlayerStatus/MuscleGained/Label.text = str(gained)
	$PlayerStatus/FatBurnt/Label.text = str(burnt)

func _on_button_pressed() -> void:
	upgrade_finished.emit()

func _on_four_hour_pressed() -> void:
	var button: UpgradeButton = $HBoxContainer/Hour/FourHour as UpgradeButton
	
	if _has_enough(button.muscle_cost, button.burn_cost):
		PlayerUpgrade.is_4hour_fitness = true
		_reduce_amount(button.muscle_cost, button.burn_cost)
	update_button_status()

func _on_eight_hour_pressed() -> void:
	var button: UpgradeButton = $HBoxContainer/Hour/EightHour as UpgradeButton
	
	if _has_enough(button.muscle_cost, button.burn_cost):
		PlayerUpgrade.is_8hour_fitness = true
		_reduce_amount(button.muscle_cost, button.burn_cost)
	update_button_status()

func _on_twelve_hour_pressed() -> void:
	var button: UpgradeButton = $HBoxContainer/Hour/TwelveHour as UpgradeButton
	
	if _has_enough(button.muscle_cost, button.burn_cost):
		PlayerUpgrade.is_12hour_fitness = true
		_reduce_amount(button.muscle_cost, button.burn_cost)
	update_button_status()

func _on_word_of_mouth_pressed() -> void:
	var button: UpgradeButton = $HBoxContainer/Ad/WordOfMouth as UpgradeButton
	
	if _has_enough(button.muscle_cost, button.burn_cost):
		PlayerUpgrade.is_word_of_mouth = true
		_reduce_amount(button.muscle_cost, button.burn_cost)
	update_button_status()


func _on_marketing_pressed() -> void:
	var button: UpgradeButton = $HBoxContainer/Ad/Marketing as UpgradeButton
	
	if _has_enough(button.muscle_cost, button.burn_cost):
		PlayerUpgrade.is_marketing_101 = true
		_reduce_amount(button.muscle_cost, button.burn_cost)
	update_button_status()

func _on_juiced_pressed() -> void:
	var button: UpgradeButton = $HBoxContainer/Juice/Juiced as UpgradeButton
	
	if _has_enough(button.muscle_cost, button.burn_cost):
		PlayerUpgrade.is_more_juice = true
		_reduce_amount(button.muscle_cost, button.burn_cost)
	update_button_status()

func _on_max_juice_pressed() -> void:
	var button: UpgradeButton = $HBoxContainer/Juice/MaxJuice as UpgradeButton
	
	if _has_enough(button.muscle_cost, button.burn_cost):
		PlayerUpgrade.is_even_more_juice = true
		_reduce_amount(button.muscle_cost, button.burn_cost)
	update_button_status()

func _on_weight_training_pressed() -> void:
	var button: UpgradeButton = $HBoxContainer/Weight/WeightTraining as UpgradeButton
	
	if _has_enough(button.muscle_cost, button.burn_cost):
		PlayerUpgrade.is_more_weight = true
		_reduce_amount(button.muscle_cost, button.burn_cost)
	update_button_status()


func _on_max_weight_pressed() -> void:
	var button: UpgradeButton = $HBoxContainer/Weight/MaxWeight as UpgradeButton
	
	if _has_enough(button.muscle_cost, button.burn_cost):
		PlayerUpgrade.is_even_more_weight = true
		_reduce_amount(button.muscle_cost, button.burn_cost)
	update_button_status()
