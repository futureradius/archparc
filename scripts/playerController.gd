extends CharacterBody3D


var current_speed: float

@export var sprinting_speed: float = 5
@export var walking_speed: float = 3
@export var crouching_speed: float = 1

@export var jump_velocity: float = 4.5

# get gravity from project settings
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _physics_process(delta: float):
	
	
	# add the gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# Handle jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity
	
	# get input direction and handle the input/ decelleration
	# as good practice you should replace ui actions with custom gameplay actions
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)
		
	move_and_slide()
