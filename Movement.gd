extends CharacterBody3D

enum state {idle, slide, crouch, sprint}

@export_group("Jump")
@export var jump_velocity:= 5.0
@export var max_jumps:=2
@export_group("Movement")
@export var base_speed:= 5.0
@export_range(0,100,1,"suffix:%","prefer_slider") var base_friction:= 75.0
@export_group("Sprint")
@export_range(0,100,1,"suffix:%","prefer_slider") var friction_mult:= 1
@export var steer_speed:= 1
@export var slope_influence:= 15.0
var friction: float = 0.0
var speed: float = 0.0
var dead:= false
var current_state:= state.idle
var jumps:= 0
var safe:= []
var checkpoint:= false
var respawn:=[Vector3(0,0,0),Vector3(0,0,0),100,0]
var fall := 0.0
@onready var health:=$Camera/Health

func shrink(size:float):
	var collider:CollisionShape3D = $CollisionShape3D
	var mesh:MeshInstance3D = $MeshInstance3D
	var cam:Camera3D = $Camera
	var uniqueshape = collider.shape
	var uniquemesh = mesh.mesh
	var uniquecam = cam
	uniqueshape.set("height",size*2)
	uniquemesh.set("height",size*2)
	uniquecam.position.y = size/2
	collider.shape = uniqueshape
	mesh.mesh = uniquemesh
	cam = uniquecam

func _physics_process(delta: float) -> void:
	var horizontal_velocity := Vector3(velocity.x, 0, velocity.z)
	var current_speed := horizontal_velocity.length()
	var current_dir := horizontal_velocity.normalized()
	speed = base_speed
	friction = base_friction
	if checkpoint and not dead:
		respawn = []
		respawn.append(position)
		respawn.append(velocity)
		respawn.append(health.health)
		respawn.append(jumps)
	if is_on_floor():
		if fall < 0:
			var floor_normal := get_floor_normal()
			if floor_normal.dot(Vector3.UP) < 0.99:
				var slope_down_dir := Vector3(floor_normal.x, 0, floor_normal.z).normalized()
				if Input.is_action_pressed("move_crouch"):
					var slam_energy = abs(fall)/2
					velocity.x += slope_down_dir.x * slam_energy
					velocity.z += slope_down_dir.z * slam_energy
					horizontal_velocity = Vector3(velocity.x, 0, velocity.z)
					current_speed = horizontal_velocity.length()
					current_dir = horizontal_velocity.normalized()
		jumps = max_jumps
		fall = 0
		safe.append([position,Vector2($Camera.rotation.x,rotation.y)])
		if len(safe) > 50:
			safe.pop_front()
	else:
		fall = velocity.y
		velocity += get_gravity() * delta
		speed = speed/10
		friction /= 20
	if position.y < -5:
		position = safe[0][0]
		rotation.y = safe[0][1].y
		$Camera.rotation.x = safe[0][1].x
		velocity = Vector3(0,0,0)
		health.health *= 0.9
	if Input.is_action_just_pressed("move_jump") and jumps and not dead:
		if current_state == state.slide and is_on_floor():
			velocity.y += jump_velocity*(1+0.05*current_speed)
			floor_snap_length = 0.1 
		else:
			velocity.y += jump_velocity
		jumps -= 1
	if Input.is_action_pressed("move_sprint") and Input.is_action_pressed("move_forward") and current_state != state.crouch:
		current_state = state.sprint
		if is_on_floor():
			speed *= 2
		else:
			speed *= 1.5
	elif current_state == state.sprint:
		current_state = state.idle
	if Input.is_action_pressed("move_crouch"):
		if Input.is_action_just_pressed("move_crouch"):
			velocity.y = -5 * jump_velocity
		shrink(0.5)
		if current_speed > base_speed/1.5 and current_state != state.crouch:
			current_state = state.slide
			speed = 0
			friction *= friction_mult/100.0
		else:
			current_state = state.crouch
			speed /= 2
	else:
		if current_state == state.slide or current_state == state.crouch:
			current_state=state.idle
		shrink(1)
	var direction:= Vector3(0,0,0)
	if dead:
		$Camera.set("current",false)
		velocity = Vector3(0,0,0)
		shrink(0.25)
		if Input.is_action_just_pressed("respawn"):
			position = respawn[0]
			velocity = respawn[1]
			health.health = respawn[2]
			jumps = respawn[3]
			dead = false
	else:
		$Camera.set("current",true)
		var input_dir:=Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
		direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		velocity.x *= (100-friction)/100
		velocity.z *= (100-friction)/100
		velocity.x += direction.x * speed
		velocity.z += direction.z * speed 
		if current_state == state.slide:
			var new_dir := current_dir.lerp(direction, steer_speed * delta).normalized()
			if is_on_floor():
				var floor_normal := get_floor_normal()
				var real_slope := new_dir.dot(Vector3(floor_normal.x, 0, floor_normal.z))
				current_speed += real_slope * slope_influence * delta
				if not Input.is_action_just_pressed("move_jump"):
					var flat_target_velocity = new_dir * current_speed
					var sloped_velocity = flat_target_velocity.slide(floor_normal)
					floor_snap_length = 0.5
					velocity = sloped_velocity
			velocity.x = new_dir.x * current_speed
			velocity.z = new_dir.z * current_speed
	move_and_slide()
func _unhandled_input(event: InputEvent) -> void:
	if not($Camera.paused) and event is InputEventMouseMotion:
		rotation.y -= event.relative.x * $Camera.mouse_sens * 0.001
