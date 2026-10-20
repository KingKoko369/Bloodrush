extends CharacterBody3D


@export var start_speed: float = 5.0
@export var JUMP_VELOCITY: float = 4.5
@export var slide_friction: float = 0.01
var speed = start_speed
var sprint = false
var slide = false
var crouch = false

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	if Input.is_action_just_pressed("move_jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	if Input.is_action_pressed("move_sprint") and Input.is_action_pressed("move_forward"):
		sprint = true
		speed = start_speed * 2
	else:
		sprint = false
		speed = start_speed
	if Input.is_action_pressed("move_crouch"):
		position.y -= scale.y - 1
		scale.x = 0.5
		scale.y = 0.5
		scale.z = 0.5
		if sprint:
			slide = true
			speed = velocity.x
		else:
			crouch = true
			speed = start_speed / 2
	else:
		crouch = false
		slide = false
		scale.x = 1
		scale.y = 1
		scale.z = 1
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		if slide:
			velocity.x = move_toward(velocity.x, 0, abs(velocity.x * slide_friction))
			velocity.z = move_toward(velocity.z, 0, abs(velocity.z * slide_friction))
		else:
			velocity.x = move_toward(velocity.x, 0, speed / 2)
			velocity.z = move_toward(velocity.z, 0, speed / 2)
	move_and_slide()
func _unhandled_input(event: InputEvent) -> void:
	if not($Camera.paused) and event is InputEventMouseMotion:
		rotation.y -= event.relative.x * $Camera.mouse_sens * 0.001
