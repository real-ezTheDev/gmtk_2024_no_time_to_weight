@tool
extends ColorRect

@export var transition_progress: float = 0:
	set(value):
		transition_progress = value
		(material as ShaderMaterial).set_shader_parameter("progress", transition_progress)
@export var is_swipe_out = true:
	set(value):
		is_swipe_out = value
		(material as ShaderMaterial).set_shader_parameter("fill", is_swipe_out)
