extends CharacterBody3D


@export var speed: float = 5.0
@export var JUMP_VELOCITY: float = 4.5


func _physics_process(delta: float) -> void:
	rotation.y += $Camera.rotation.y
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("move_jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
func _unhandled_input(event: InputEvent) -> void:
	if not($Camera.paused) and event is InputEventMouseMotion:
		rotation.y -= event.relative.x * $Camera.mouse_sens * 0.001

	move_and_slide()
