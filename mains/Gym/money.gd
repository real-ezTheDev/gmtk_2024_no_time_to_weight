extends HBoxContainer


func _on_gym_cash_changed(amount: int) -> void:
	$Label.text= str(amount)
	pass # Replace with function body.
