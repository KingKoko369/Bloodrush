@tool
extends StaticBody3D

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var collider: CollisionShape3D = $CollisionShape3D

@export var target_texture: Texture2D = preload("res://icon.svg"):
	set(value):
		target_texture = value
		_update_texture()

@export_custom(PROPERTY_HINT_LINK, "")
var size: Vector2 = Vector2(1,1):
	set(value):
		size = value
		_update_texture()

@export_custom(PROPERTY_HINT_LINK, "")
var tile: Vector2 = Vector2(1,1):
	set(value):
		tile = value
		_update_texture()

func _ready() -> void:
	_update_texture()

func _update_texture() -> void:
	if not is_inside_tree() or not mesh_instance or not collider:
		return
	
	var material = mesh_instance.get_active_material(0) as StandardMaterial3D
	if material:
		var unique_material = material.duplicate()
		unique_material.albedo_texture = target_texture
		unique_material.uv1_scale.x = tile.x
		unique_material.uv1_scale.y = tile.y
		mesh_instance.set_surface_override_material(0, unique_material)
	
	if collider.shape:
		var shape = collider.shape
		var unique_shape = shape.duplicate()
		if unique_shape.has_method("set_size"):
			unique_shape.set("size", Vector3(size.x, 0, size.y))
		collider.shape = unique_shape
	
	if mesh_instance.mesh:
		var mesh = mesh_instance.mesh
		var unique_mesh = mesh.duplicate()
		if unique_mesh.has_method("set_size"):
			unique_mesh.set("size", size)
		mesh_instance.mesh = unique_mesh
