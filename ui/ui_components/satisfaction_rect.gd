extends TextureRect

const SATISFACTORY_TEXTURES: Array[Texture2D] = [
	preload("res://ui/angry.png"),
	preload("res://ui/unsatisfied.png"),
	preload("res://ui/ok.png"),
	preload("res://ui/happy.png")
]

func _on_gym_body_character_satisfaction_changed(value: int) -> void:
	texture = SATISFACTORY_TEXTURES[value]
