extends Camera3D

@export var mouse_sens: float = 5
@export var paused: bool

func _ready() -> void:
	paused = true
func _process(_delta):
	if paused:
		if Input.is_action_just_pressed("unpause"):
			paused = false
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		if Input.is_action_just_pressed("pause"):
			paused = true
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
func _unhandled_input(event: InputEvent) -> void:
	if not(paused) and event is InputEventMouseMotion:
		rotation.x -= event.relative.y * mouse_sens * 0.001
		rotation.x = min(rotation.x, 1)
		rotation.x = max(rotation.x, -1.5)
