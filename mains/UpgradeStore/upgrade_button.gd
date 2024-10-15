@tool
class_name UpgradeButton extends HBoxContainer

signal pressed()

@export var normal_texture: Texture2D:
	set(value):
		normal_texture = value
		if !is_node_ready():
			await ready
		
		($TextureButton as TextureButton).texture_normal = value
@export var hover_texture: Texture2D:
	set(value):
		hover_texture = value
		if !is_node_ready():
			await ready
		
		($TextureButton as TextureButton).texture_hover = value
		
@export var pressed_texture: Texture2D:
	set(value):
		pressed_texture = value
		if !is_node_ready():
			await ready
		
		($TextureButton as TextureButton).texture_pressed = value
@export var disabled_texture: Texture2D:
	set(value):
		disabled_texture = value
		if !is_node_ready():
			await ready
		
		($TextureButton as TextureButton).texture_disabled = value

@export var is_locked = false
@export var is_purchased = false
@export var muscle_cost: int = 0:
	set(value):
		muscle_cost = value
		if value > 0:
			$VBoxContainer/Muscle.visible = true
			$VBoxContainer/Muscle/Label.text = str(value)
		else:
			$VBoxContainer/Muscle.visible = false
@export var burn_cost: int = 0:
	set(value):
		burn_cost = value
		if value > 0:
			$VBoxContainer/Fat.visible = true
			$VBoxContainer/Fat/Label.text = str(value)
		else:
			$VBoxContainer/Fat.visible = false
			
@export var title: String:
	set(value):
		title = value
		$VBoxContainer/Label.text = value

func _process(delta):
	$Purchased.visible = false
	$Locked.visible = false
	if is_locked:
		$TextureButton.disabled = true
		$Locked.visible = true
	elif is_purchased:
		$TextureButton.disabled = true
		$Purchased.visible = true
	else:
		$TextureButton.disabled = false


func _on_texture_button_pressed() -> void:
	pressed.emit()
