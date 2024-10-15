extends TextureProgressBar

func _on_gym_body_character_energy_changed(_value: float) -> void:
	value = round(_value)
