extends Node3D

var start_rotation = rotation
var start_pos = position

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("attack_main"):
		position.z -= 1
		rotation.z = 0
	position.z = (start_pos.z+position.z)/2
	rotation.z = (start_rotation.z+rotation.z)/2
