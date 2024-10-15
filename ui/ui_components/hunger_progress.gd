extends TextureProgressBar

const DANGER = preload("res://ui/progress_bar_over_warn.png")
const NORMAL = preload("res://ui/progress_bar_over.png")

func _on_gym_body_character_hunger_changed(_value: int) -> void:
	if _value <= 10:
		texture_over = DANGER
	else:
		texture_over = NORMAL
	value = _value
