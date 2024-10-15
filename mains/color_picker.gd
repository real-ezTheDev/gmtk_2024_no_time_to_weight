extends GridContainer

signal color_changed(color: Color)

@onready var color_buttons: Array = [
	$Color1,
	$Color2,
	$Color3,
	$Color4,
	$Color5,
	$Color6,
	$Color7,
	$Color8,
	$Color9,
]

func _is_left_mouse_button(event: InputEvent):
	return event is InputEventMouseButton && (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT

func _on_color_1_gui_input(event: InputEvent) -> void:
	if _is_left_mouse_button(event):
		$"../../PickSound".play()
		color_changed.emit(color_buttons[0].color)

func _on_color_2_gui_input(event: InputEvent) -> void:
	if _is_left_mouse_button(event):
		$"../../PickSound".play()
		color_changed.emit(color_buttons[1].color)

func _on_color_3_gui_input(event: InputEvent) -> void:
	if _is_left_mouse_button(event):
		$"../../PickSound".play()
		color_changed.emit(color_buttons[2].color)

func _on_color_4_gui_input(event: InputEvent) -> void:
	if _is_left_mouse_button(event):
		$"../../PickSound".play()
		color_changed.emit(color_buttons[3].color)

func _on_color_5_gui_input(event: InputEvent) -> void:
	if _is_left_mouse_button(event):
		$"../../PickSound".play()
		color_changed.emit(color_buttons[4].color)

func _on_color_6_gui_input(event: InputEvent) -> void:
	if _is_left_mouse_button(event):
		$"../../PickSound".play()
		color_changed.emit(color_buttons[5].color)

func _on_color_7_gui_input(event: InputEvent) -> void:
	if _is_left_mouse_button(event):
		$"../../PickSound".play()
		color_changed.emit(color_buttons[6].color)

func _on_color_8_gui_input(event: InputEvent) -> void:
	if _is_left_mouse_button(event):
		$"../../PickSound".play()
		color_changed.emit(color_buttons[7].color)

func _on_color_9_gui_input(event: InputEvent) -> void:
	
	if _is_left_mouse_button(event):
		$"../../PickSound".play()
		color_changed.emit(color_buttons[8].color)
	pass # Replace with function body.


func _on_gui_input(event: InputEvent) -> void:
	pass # Replace with function body.
