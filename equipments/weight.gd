class_name weight extends CharacterBody2D

@export var weight_value: int = 1

func _ready():
	add_to_group(Gym.group_weights)

func highlight():
	$Sprite.material.set_shader_parameter("line_thickness", 2.)
	
func unhighlight():
	$Sprite.material.set_shader_parameter("line_thickness", 0. )
