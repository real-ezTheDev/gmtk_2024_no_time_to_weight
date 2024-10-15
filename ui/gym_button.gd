class_name GymButton extends TextureButton

func _ready():
	pressed.connect(_on_pressed)

func _on_pressed():
	$"../../../../ClickSound".play()
	
func hover():
	$AnimationPlayer.play("hover")
	$"../../../../HoverSound".play()
	
func unhover():
	$AnimationPlayer.play('unhover')
