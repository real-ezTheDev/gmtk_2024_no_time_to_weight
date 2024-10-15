class_name PlayerCharacter extends CharacterBody2D

const SPEED = 200
const JUMP_VELOCITY = -400.0

@onready var character_animation_player: AnimationPlayer = $CharacterAnimationPlayer
@onready var body: GymBody = $GymBody as GymBody

var currently_interacting_body: Node2D
var touched_bodies: Array[GymBodyCharacter] = []


var carrying_item
@onready var weight = $Items/Weight
@onready var juice = $Items/Juice

func _ready():
	add_to_group(Gym.group_player)
	
func _input(event: InputEvent):
	if event.is_action_pressed("ui_accept") && currently_interacting_body:
		if currently_interacting_body.is_in_group("weight_rack") \
			&& (currently_interacting_body as WeightRack).weight_count > 0\
			&& !carrying_item:
			
			(currently_interacting_body as WeightRack).weight_count -= 1
			carry_item("weight")
		elif currently_interacting_body.is_in_group("weight_rack") \
			&& (currently_interacting_body as WeightRack).weight_count < (currently_interacting_body as WeightRack).MAX_COUNT\
			&& carrying_item && carrying_item == weight:
			(currently_interacting_body as WeightRack).weight_count += 1
			drop_item()
		elif currently_interacting_body.is_in_group(Gym.group_customers):
			interact_with_customer()
		elif currently_interacting_body.is_in_group("juice_station") \
			&& (currently_interacting_body as JuiceStation).current_juice_count > 0\
			&& !carrying_item:
			(currently_interacting_body as JuiceStation).current_juice_count -= 1
			carry_item("juice")
		elif currently_interacting_body.is_in_group("juice_station") \
			&& carrying_item && carrying_item == juice:
			(currently_interacting_body as JuiceStation).current_juice_count += 1
			drop_item()

func drop_item():
	weight.visible = false
	juice.visible = false
	carrying_item = null
	body.is_carry = false
	$"../PutbackSound".play()

func carry_item(item: String):
	$"../PickupSound".play()
	if item == "weight":
		weight.visible = true
		body.is_carry = true
		carrying_item = weight
	elif item == "juice":
		juice.visible = true
		body.is_carry = true
		carrying_item = juice

func interact_with_customer():
	var customer: GymBodyCharacter = currently_interacting_body as GymBodyCharacter
	if carrying_item && carrying_item == weight:
		$"../GiveSound".play()
		if !customer.is_extra_weight && !customer.is_leaving:
			customer.is_extra_weight = true
			drop_item()
	elif carrying_item && carrying_item == juice:
		$"../GiveSound".play()
		customer.gain_hunger(50)
		customer.gain_fat(15)
		customer.gain_energy(20)
		drop_item()
	
func _physics_process(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	var up_down_direction := Input.get_axis("ui_up", "ui_down")

	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	if up_down_direction:
		velocity.y = up_down_direction * SPEED 
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED)

	move_and_slide()

func _process(delta):
	if !velocity.is_zero_approx() && character_animation_player.current_animation != "walk":
		character_animation_player.play("walk")
		character_animation_player.speed_scale = SPEED / 150
	elif velocity.is_zero_approx():
		character_animation_player.play("RESET")

func focus_body(body: Node2D):
	if body.is_in_group(Gym.group_customers):
		(body as GymBodyCharacter).display_status()
	elif body.is_in_group("weight_rack") || body.is_in_group("juice_station"):
		body.highlight()
	
func unfocus_body(body: Node2D):
	if body.is_in_group(Gym.group_customers):
		(body as GymBodyCharacter).close_status()
	elif body.is_in_group("weight_rack") || body.is_in_group("juice_station"):
		body.unhighlight()

func _on_feelers_body_entered(body: Node2D) -> void:
	if !body.is_in_group(Gym.group_customers) && !body.is_in_group("weight_rack") && !body.is_in_group("juice_station"):
		return
		
	if currently_interacting_body:
		if abs(global_position.distance_to(currently_interacting_body.global_position) - position.distance_to(body.global_position)) > 0:
			unfocus_body(currently_interacting_body)
			currently_interacting_body = body
			focus_body(body)
	else:
		currently_interacting_body = body
		focus_body(body)

	touched_bodies.push_back(body)
	
func victory_royale():
	body.is_carry = true
	weight.visible= true
	$CharacterAnimationPlayer.play("work")

func _on_feelers_body_exited(body: Node2D) -> void:
	touched_bodies.remove_at(touched_bodies.find(body))

	if currently_interacting_body == body:
		unfocus_body(currently_interacting_body)
		
		if touched_bodies.is_empty():
			currently_interacting_body = null
		else:
			currently_interacting_body = touched_bodies.pick_random()
