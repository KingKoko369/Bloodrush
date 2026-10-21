extends StaticBody3D

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@export var target_texture: Texture2D:
	set(value):
		target_texture = value
		if is_inside_tree(): # Ensure the node is active before changing textures
			_update_texture()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_update_texture()
	var material = mesh_instance.get_active_material(0) as StandardMaterial3D
	
	if material:
		# 2. Duplicate the material so individual scene instances don't share changes
		var unique_material = material.duplicate()
		
		# 3. Apply your custom texture to the Albedo channel
		unique_material.albedo_texture = target_texture
		
		# 4. Push the unique material back to the surface override slot
		mesh_instance.set_surface_override_material(0, unique_material)

func _update_texture() -> void:
	if not target_texture:
		return

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
