extends CharacterBody3D


@export var start_speed: float = 5.0
@export var JUMP_VELOCITY: float = 4.5
@export var slide_friction: float = 1
@export var steer_speed: float = 5
var speed = start_speed
var sprint:bool = false
var slide:bool = false
var crouch:bool = false
var jumps:int = 0

func _physics_process(delta: float) -> void:
	var horizontal_velocity := Vector3(velocity.x, 0, velocity.z)
	var current_speed := horizontal_velocity.length()
	var current_dir := horizontal_velocity.normalized()
	speed = start_speed
	if is_on_floor():
		jumps = 2
	else:
		velocity += get_gravity() * delta
		speed /= 2
	if Input.is_action_just_pressed("move_jump") and jumps:
		if slide and is_on_floor():
			velocity.y = JUMP_VELOCITY*1.5
		else:
			velocity.y = JUMP_VELOCITY
		jumps -= 1
	if Input.is_action_pressed("move_sprint") and Input.is_action_pressed("move_forward"):
		sprint = true
		speed *= 2
	else:
		sprint = false
	if Input.is_action_pressed("move_crouch"):
		if Input.is_action_just_pressed("move_crouch"):
			velocity.y = -5 * JUMP_VELOCITY
		scale.x = 0.5
		scale.y = 0.5
		scale.z = 0.5
		if current_speed > start_speed/1.5:
			slide = true
		else:
			crouch = true
			speed /= 2
	else:
		crouch = false
		slide = false
		scale.x = 1
		scale.y = 1
		scale.z = 1
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction and not slide:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		if slide:
			current_speed = move_toward(current_speed, 0, slide_friction * delta)
			if current_speed < start_speed / 1.5:
				slide = false
				crouch = true
			if not is_on_floor():
				slide = false
				crouch = true
				current_speed * 5
			if direction: 
				var target_dir := direction
				var new_dir := current_dir.lerp(target_dir, steer_speed * delta).normalized()
				velocity.x = new_dir.x * current_speed
				velocity.z = new_dir.z * current_speed
			else:
				velocity.x = current_dir.x * current_speed
				velocity.z = current_dir.z * current_speed

		else:
			velocity.x = move_toward(velocity.x, 0, speed / 2)
			velocity.z = move_toward(velocity.z, 0, speed / 2)
	move_and_slide()
func _unhandled_input(event: InputEvent) -> void:
	if not($Camera.paused) and event is InputEventMouseMotion:
		rotation.y -= event.relative.x * $Camera.mouse_sens * 0.001
