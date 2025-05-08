extends CharacterBody3D


const WALK_speed = 3.0
const SLOW_WALK_speed = 6.0
const JUMP_VELOCITY = 3.50
const gravtiy = 9.8
var speed = 3.0
var mouse_sensitivity = 0.15
var touch_sensitivity = 0.15

#head bob properties
var headbob_frequency = 3.4
var headbob_amplitude = 0.04
var headbob_side_to_side_strength = .5
var headbob_time = 0.0

@onready var head = $Node3D
@onready var camera = $Node3D/Camera3D


#trying to call the joystick
#@export var joystick : virtual_joystick
var move_vector := Vector2.ZERO

#variable on how deep the camera drag is allowed to be registered. in here because of bug with touchscreen indices mixing up. godot 4.41
var screenBlock := 0.75

var touchscreenAvailable := true


func _ready() -> void:
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if not DisplayServer.is_touchscreen_available():
		touchscreenAvailable = false


#func _input(event):
#	if event is InputEventScreenDrag and touchscreenAvailable == true:
#		# Check if the touch event is pressed and in the right half of the screen
#		
#		if event.position.y <= get_viewport().size.y * screenBlock and touchscreenAvailable == true:
#				head.rotate_y(-deg_to_rad(event.relative.x * touch_sensitivity))
#				camera.rotate_x(-deg_to_rad(event.relative.y * touch_sensitivity))
#				camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))
#
#	elif event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and touchscreenAvailable == false:
#				head.rotate_y(-deg_to_rad(event.relative.x * mouse_sensitivity))
#				camera.rotate_x(-deg_to_rad(event.relative.y * mouse_sensitivity))
#				camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))

var last_position := Vector2(0, 0)
var is_dragging := false
var relative


func _input(event):
	if event is InputEventScreenDrag:
		# Check if the touch event is pressed and in the right half of the screen
		if event.position.y <= get_viewport().size.y * screenBlock:
			if is_dragging:
				relative = event.position - last_position
				#rotate_y(deg_to_rad(-event.relative.x * 0.1))
				camera.rotate_x(-deg_to_rad(relative.y * touch_sensitivity))
				camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))
				head.rotate_y(-deg_to_rad(relative.x * touch_sensitivity))
				
			last_position = event.position
			is_dragging = true
	elif event is InputEventScreenTouch:
		if not event.pressed:
			is_dragging = false
			
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and touchscreenAvailable == false:
		head.rotate_y(-deg_to_rad(event.relative.x * mouse_sensitivity))
		camera.rotate_x(-deg_to_rad(event.relative.y * mouse_sensitivity))
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
	#var input_dir = Input.get_vector("l", "r", "up", "b")
	#var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	## Movement using the joystick output:
	#if joystick and joystick.is_pressed:
	#	position += joystick.output * speed * delta
	
	## Movement using Input functions:
	move_vector = Vector2.ZERO
	move_vector = Input.get_vector("left","right","forward","backward")
	#position += move_vector * speed * delta
	var direction = (head.transform.basis * Vector3(move_vector.x, 0, move_vector.y)).normalized()
	
	
	
	
	
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
