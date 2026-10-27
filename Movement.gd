extends CharacterBody3D

@export var dead:= false
@export_group("Jump")
@export var jump_velocity:= 5.0
@export var max_jumps:=2
@export_group("Movement")
@export var base_speed:= 5.0
@export_range(0,100,1,"suffix:%","prefer_slider") var base_friction:= 75
@export_group("Slide")
@export_range(0,100,1,"suffix:%","prefer_slider") var friction_mult:= 1
@export var steer_speed:= 1
@export var slope_influence:= 15.0
var friction: float = base_friction
var speed: float = base_speed
var current_state:= "idle"
var jumps:= 0

func _physics_process(delta: float) -> void:
	var horizontal_velocity := Vector3(velocity.x, 0, velocity.z)
	var current_speed := horizontal_velocity.length()
	var current_dir := horizontal_velocity.normalized()
	speed = base_speed
	friction = base_friction
	if is_on_floor():
		jumps = max_jumps
	else:
		velocity += get_gravity() * delta
		speed = speed/10
		friction /= 20
	if Input.is_action_just_pressed("move_jump") and jumps:
		if current_state == "slide" and is_on_floor():
			velocity.y += jump_velocity*(1+0.05*current_speed)
			floor_snap_length = 0.1 
		else:
			velocity.y += jump_velocity
		jumps -= 1
	if Input.is_action_pressed("move_sprint") and Input.is_action_pressed("move_forward") and current_state != "crouch":
		current_state = "sprint"
		if is_on_floor():
			speed *= 2
		else:
			speed *= 1.5
	elif current_state == "sprint":
		current_state = "idle"
	if Input.is_action_pressed("move_crouch"):
		if Input.is_action_just_pressed("move_crouch"):
			velocity.y = -5 * jump_velocity
		scale.x = 0.5
		scale.y = 0.5
		scale.z = 0.5
		if current_speed > base_speed/1.5 and current_state != "crouch":
			current_state = "slide"
			speed = 0
			friction *= friction_mult/100
		else:
			current_state = "crouch"
			speed /= 2
	else:
		if current_state == "slide" or current_state == "crouch":
			current_state="idle"
		scale.x = 1
		scale.y = 1
		scale.z = 1
	var direction:= Vector3(0,0,0)
	if dead:
		current_state = "slide"
		scale.x = 0.25
		scale.y = 0.25
		scale.z = 0.25
		$Camera.paused = false
		if current_speed > 0.1:
			rotation.y = atan2(-current_dir.x, -current_dir.z)
		if is_on_floor():
			friction = 100
			var normal := get_floor_normal()
			var slope_angle := acos(normal.dot(Vector3.UP))
			$Camera.rotation.x = -current_dir.dot(Vector3(normal.x, 0, normal.z).normalized()) * slope_angle
	else:
		var input_dir:=Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
		direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	velocity.x *= (100-friction)/100
	velocity.z *= (100-friction)/100
	velocity.x += direction.x * speed
	velocity.z += direction.z * speed 
	if current_state == "slide":
		var new_dir := current_dir.lerp(direction, steer_speed * delta).normalized()
		if is_on_floor():
			var floor_normal := get_floor_normal()
			var real_slope := new_dir.dot(Vector3(floor_normal.x, 0, floor_normal.z))
			current_speed += real_slope * slope_influence * delta
			if not Input.is_action_just_pressed("move_jump"):
				var flat_target_velocity = new_dir * current_speed
				var sloped_velocity = flat_target_velocity.slide(floor_normal)
				floor_snap_length = 0.5
				velocity.x = sloped_velocity.x
				velocity.y = sloped_velocity.y
				velocity.z = sloped_velocity.z
		velocity.x = new_dir.x * current_speed
		velocity.z = new_dir.z * current_speed
	move_and_slide()
func _unhandled_input(event: InputEvent) -> void:
	if not($Camera.paused) and event is InputEventMouseMotion:
		rotation.y -= event.relative.x * $Camera.mouse_sens * 0.001
