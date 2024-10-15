class_name Tutorial extends ColorRect

signal tutorial_finished()

func _input(event: InputEvent):
	if visible && event.is_pressed():
		visible = false
		tutorial_finished.emit()
