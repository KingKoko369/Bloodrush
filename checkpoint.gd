@tool
extends StaticBody3D

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var collider: CollisionShape3D = $CollisionShape3D
@onready var zone: Area3D = $"Checkpoint Zone"
@onready var zone_mesh: MeshInstance3D = $"Checkpoint Zone/MeshInstance3D"
@onready var zone_collider: CollisionShape3D = $"Checkpoint Zone/CollisionShape3D"

@export_custom(PROPERTY_HINT_LINK, "")
var size: Vector3 = Vector3(1,2,1):
	set(value):
		size = value
		_update_texture()

@export_custom(PROPERTY_HINT_LINK, "")
var radius: float = 5:
	set(value):
		radius = value
		_update_texture()

func _ready() -> void:
	_update_texture()

func _update_texture() -> void:
	if not is_inside_tree() or not mesh_instance or not collider:
		return
	
	if collider.shape:
		var shape = collider.shape
		var unique_shape = shape.duplicate()
		if unique_shape.has_method("set_size"):
			unique_shape.set("size", size)
		collider.shape = unique_shape
	
	if mesh_instance.mesh:
		var mesh = mesh_instance.mesh
		var unique_mesh = mesh.duplicate()
		if unique_mesh.has_method("set_size"):
			unique_mesh.set("size", size)
		mesh_instance.mesh = unique_mesh
		
	if zone_collider.shape:
		var shape = zone_collider.shape
		var unique_shape = shape.duplicate()
		if unique_shape.has_method("set_radius"):
			unique_shape.set("radius", radius)
		zone_collider.shape = unique_shape
	
	if zone_mesh.mesh:
		var mesh = zone_mesh.mesh
		var unique_mesh = mesh.duplicate()
		if unique_mesh.has_method("set_radius"):
			unique_mesh.set("radius", radius)
		if unique_mesh.has_method("set_height"):
			unique_mesh.set("height", radius*2)
		zone_mesh.mesh = unique_mesh
