@tool
class_name GymBody extends CanvasGroup

const GYM_BODY_SCN = preload("res://members/body/GymBody.tscn")

var _is_dirty = true

@export var primary_color: Color:
	set(value):
		primary_color = value
		_is_dirty = true
@export var upper_body_shape: BodyShape = BodyShape.BUILT:
	set(value):
		upper_body_shape = value
		_is_dirty = true
@export var lower_body_shape: BodyShape = BodyShape.BUILT:
	set(value):
		lower_body_shape = value
		_is_dirty = true
@export var arm_shape: BodyShape = BodyShape.BUILT:
	set(value):
		arm_shape = value
		_is_dirty = true

@onready var hair = $Hair
@onready var accessory =  $Accessory
@onready var arm: BodyPartSprite = $Arm as BodyPartSprite
@onready var legs: BodyPartSprite= $Legs as BodyPartSprite
@onready var upper: BodyPartSprite = $Upper as BodyPartSprite

@export var is_carry: bool:
	set(value):
		is_carry = value
		if is_carry:
			$AnimationPlayer.play("carry")
		else:
			$AnimationPlayer.play("RESET")

enum BodyShape {
	BUILT,
	HEALTHY,
	SKINNY,
	FAT
}

const HAIR_LIMIT = 14
const ACC_LIMIT = 8
const BODY_PART_LIMIT = 4

func copy_body() -> GymBody:
	var new_body = GYM_BODY_SCN.instantiate()
	new_body.primary_color = primary_color
	new_body.arm_shape = arm_shape
	new_body.upper_body_shape = upper_body_shape
	new_body.lower_body_shape = lower_body_shape
	
	return new_body

func set_to_member():
	legs.part = 16
	upper.part =  15
	
func set_to_nonmember():
	legs.part = 2
	upper.part =  1
	
func set_to_trainer():
	legs.part= 18
	upper.part = 17

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if _is_dirty && is_node_ready():
		hair.self_modulate = primary_color
		accessory.self_modulate = primary_color
		
		arm.index = arm_shape
		legs.index = lower_body_shape
		upper.index = upper_body_shape
		_is_dirty = false
	pass

func _get_body_type_string(shape: GymBody.BodyShape):
	match shape:
		GymBody.BodyShape.FAT:
			return "Fat"
			pass
		GymBody.BodyShape.HEALTHY:
			return "Fit"
			pass
		GymBody.BodyShape.SKINNY:
			return "Thin"
			pass
		GymBody.BodyShape.BUILT:
			return "Buff"
			pass
	pass

func cycle_upper_up():
	upper_body_shape = posmod(upper_body_shape+1, 4)
	$"../CharacterControl/GridContainer/OptionLbl2".text = _get_body_type_string(upper_body_shape)
	
func cycle_upper_down():
	upper_body_shape = posmod(upper_body_shape-1, 4)
	$"../CharacterControl/GridContainer/OptionLbl2".text = _get_body_type_string(upper_body_shape)

func cycle_arm_up():
	arm_shape = posmod(arm_shape+1, 4)
	$"../CharacterControl/GridContainer/OptionLbl1".text = _get_body_type_string(arm_shape)

func cycle_arm_down():
	arm_shape = posmod(arm_shape-1, 4)
	$"../CharacterControl/GridContainer/OptionLbl1".text = _get_body_type_string(arm_shape)

func cycle_legs_up():
	lower_body_shape = posmod(lower_body_shape+1, 4)
	$"../CharacterControl/GridContainer/OptionLbl3".text = _get_body_type_string(lower_body_shape)

func cycle_legs_down():
	lower_body_shape = posmod(lower_body_shape-1, 4)
	$"../CharacterControl/GridContainer/OptionLbl3".text = _get_body_type_string(lower_body_shape)

func cycle_hair_up():
	hair.index = posmod(hair.index+1, HAIR_LIMIT)
	$"../FaceControl/GridContainer/HairOptionLbl".text = "Hair " + str(hair.index+1)
	
func cycle_hair_down():
	hair.index = posmod(hair.index-1, HAIR_LIMIT)
	$"../FaceControl/GridContainer/HairOptionLbl".text = "Hair " + str(hair.index+1)
	
func cycle_acc_up():
	accessory.index = posmod(accessory.index+1, ACC_LIMIT)
	$"../FaceControl/GridContainer/AccOptionLbl".text = "Accessory " + str(accessory.index+1)
	
func cycle_acc_down():
	accessory.index = posmod(accessory.index-1, ACC_LIMIT)
	$"../FaceControl/GridContainer/AccOptionLbl".text = "Accessory " + str(accessory.index+1)

func update_labels():
	$"../FaceControl/GridContainer/AccOptionLbl".text = "Accessory " + str(accessory.index+1)
	$"../FaceControl/GridContainer/HairOptionLbl".text = "Hair " + str(hair.index+1)
	$"../CharacterControl/GridContainer/OptionLbl3".text = _get_body_type_string(lower_body_shape)
	$"../CharacterControl/GridContainer/OptionLbl1".text = _get_body_type_string(arm_shape)
	$"../CharacterControl/GridContainer/OptionLbl2".text = _get_body_type_string(upper_body_shape)

func update_hair_color(color: Color):
	primary_color = color
	
func randomize() -> void:
	hair.index = randi_range(0, HAIR_LIMIT-1)
	accessory.index = randi_range(0, ACC_LIMIT-1)
	arm_shape = randi_range(0, BODY_PART_LIMIT-1)
	upper_body_shape = randi_range(0, BODY_PART_LIMIT-1)
	lower_body_shape = randi_range(0, BODY_PART_LIMIT-1)
