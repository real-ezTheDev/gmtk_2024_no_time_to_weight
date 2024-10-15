extends TextureProgressBar

const DANGER = preload("res://ui/progress_bar_over_warn.png")
const NORMAL = preload("res://ui/progress_bar_over.png")

func _on_gym_body_character_fat_changed(_value: float) -> void:
	if _value <= 5:
		texture_over = DANGER
		$"../../Hunger/minus".visible = true
	else:
		texture_over = NORMAL
		$"../../Hunger/minus".visible = false
	value = round(_value)
