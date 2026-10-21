extends CharacterBody3D

@export var base_speed:= 5.0
@export var jump_velocity:= 5.0
@export var base_friction:= 75
@export var steer_speed:= 1
var friction: float = base_friction
var speed: float = base_speed
var state:= "idle"
var jumps:= 0

func _physics_process(delta: float) -> void:
	var horizontal_velocity := Vector3(velocity.x, 0, velocity.z)
	var current_speed := horizontal_velocity.length()
	var current_dir := horizontal_velocity.normalized()
	speed = base_speed
	friction = base_friction
	if is_on_floor():
		jumps = 2
	else:
		velocity += get_gravity() * delta
		speed = speed/10
		friction /= 20
	if Input.is_action_just_pressed("move_jump") and jumps:
		if state == "slide" and is_on_floor():
			velocity.y = jump_velocity*1.5
		else:
			velocity.y = jump_velocity
		jumps -= 1
	if Input.is_action_pressed("move_sprint") and Input.is_action_pressed("move_forward"):
		state = "sprint"
		if is_on_floor():
			speed *= 2
		else:
			speed *= 1.5
	elif state == "sprint":
		state = "idle"
	if Input.is_action_pressed("move_crouch"):
		if Input.is_action_just_pressed("move_crouch"):
			velocity.y = -5 * jump_velocity
		scale.x = 0.5
		scale.y = 0.5
		scale.z = 0.5
		if current_speed > base_speed/1.5:
			state = "slide"
			speed = 0
			friction /= 100
		else:
			state = "crouch"
			speed /= 2
	else:
		if not state == "slide" or state == "crouch":
			state="idle"
		scale.x = 1
		scale.y = 1
		scale.z = 1
	var input_dir:=Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction:=(transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	velocity.x *= (100-friction)/100
	velocity.z *= (100-friction)/100
	velocity.x += direction.x * speed
	velocity.z += direction.z * speed 
	if state == "slide":
		var new_dir := current_dir.lerp(direction, steer_speed * delta).normalized()
		velocity.x = new_dir.x * current_speed
		velocity.z = new_dir.z * current_speed
	move_and_slide()
func _unhandled_input(event: InputEvent) -> void:
	if not($Camera.paused) and event is InputEventMouseMotion:
		rotation.y -= event.relative.x * $Camera.mouse_sens * 0.001
