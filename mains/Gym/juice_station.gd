class_name JuiceStation extends StaticBody2D

const MAX_COUNt = 12
@onready var juice_station = $JuiceStation

var current_juice_count = 4:
	set(value):
		current_juice_count = value
		for i in juice_station.get_children().size():
			if i < current_juice_count:
				juice_station.get_child(i).visible = true
			else:
				juice_station.get_child(i).visible = false
 
func highlight():
	juice_station.material.set_shader_parameter("line_thickness", 2)

func unhighlight():
	juice_station.material.set_shader_parameter("line_thickness", 0)
