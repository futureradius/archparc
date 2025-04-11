extends CharacterBody3D


const WALK_speed = 3.0
const SLOW_WALK_speed = 1.0
const JUMP_VELOCITY = 3.50
const gravtiy = 9.8
var speed = 3.0
var mouse_sensitivity = 0.0025

#head bob properties
var headbob_frequency = 3.4
var headbob_amplitude = 0.04
var headbob_side_to_side_strength = .5
var headbob_time = 0.0

@onready var head = $"Head Pivot"
@onready var camera = $"Head Pivot/Camera3D"


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * mouse_sensitivity)
		camera.rotate_x(-event.relative.y * mouse_sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func _physics_process(delta) -> void:
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	#Handle Sprint
	if Input.is_action_pressed("sprint"):
		speed = SLOW_WALK_speed
	else:
		speed = WALK_speed

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 20)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 20)
	
	
		
	#Add headbob to the camera
	headbob_time = headbob_time + (delta * velocity.length() * float(is_on_floor()))
	camera.transform.origin = headbob(headbob_time)
	
	move_and_slide()

func headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * headbob_frequency) * headbob_amplitude
	#Side to side headbob: freq / 2 so that every second "step" is on the left, alternating from l to r
	pos.x = cos(time * headbob_frequency / 2) * headbob_amplitude * headbob_side_to_side_strength
	return pos
