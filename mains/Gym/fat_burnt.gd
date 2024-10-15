extends HBoxContainer


func _on_gym_burn_changed(amount: int) -> void:
	$Label.text= str(amount)
	pass # Replace with function body.
