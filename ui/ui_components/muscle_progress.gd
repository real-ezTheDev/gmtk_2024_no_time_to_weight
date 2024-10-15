extends TextureProgressBar

var current_bonus:int = 0

func _on_gym_body_character_muscle_changed(_value: float) -> void:
	value = round(_value)
	
func set_bonus(amount :int):
	current_bonus = amount
	
	$"../plus".visible = false
	$"../plus2".visible = false
	$"../minus".visible = false
	$"../minus2".visible = false
	
	if current_bonus >= 2:
		$"../plus".visible = true
		$"../plus2".visible = true
	elif current_bonus == 1:
		$"../plus".visible = true
	elif current_bonus == -1:
		$"../minus".visible = true
	elif current_bonus <= -2:
		$"../minus".visible = true
		$"../minus2".visible = true
