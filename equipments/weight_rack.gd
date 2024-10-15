class_name WeightRack extends StaticBody2D

const MAX_COUNT = 8

var weight_count:
	set(value):
		weight_count = value
		$Sprite.region_rect.position = Vector2(weight_count * 64, 0)

var incoming_count = 0

func get_return_position() -> Vector2:
	return $ReturnPosition.global_position

func _ready():
	weight_count = 3
	
func highlight():
	$Sprite.material.set_shader_parameter("outline", true)

func unhighlight():
	$Sprite.material.set_shader_parameter("outline", false)
