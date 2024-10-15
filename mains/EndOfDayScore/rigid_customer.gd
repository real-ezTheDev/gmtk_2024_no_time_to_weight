class_name RigidCustomer extends RigidBody2D

@onready var body: GymBody = $GymBody
var beginning_status: CustomerStatus
var final_status: CustomerStatus
var is_member: bool

func set_customer_details(customer_character: GymBodyCharacter):
	var new_body = customer_character.gym_body.copy_body()
	if customer_character.is_member:
		new_body.set_to_member()
	new_body.scale = Vector2(2,2)
	add_child(new_body)
	beginning_status = customer_character.beginning_status.duplicate()
	final_status = customer_character.status.duplicate()
	is_member =  customer_character.is_member

func get_muscle_gained() -> float:
	return final_status.muscle - beginning_status.muscle
	
func get_fat_lost() -> float:
	return beginning_status.fat - final_status.fat
