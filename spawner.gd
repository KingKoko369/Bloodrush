extends Node3D

@export var radius: int = 0
@export var enemies: Array[PackedScene] = [null]
var done: bool = false
var spawned: Array[Node] = []
var has_spawned: bool = false

func spawn() -> void:
	if has_spawned == true:
		return
	has_spawned = true
	$Area3D.queue_free()
	for enemy in enemies:
			if enemy is PackedScene:
				var enemy_inst := enemy.instantiate()
				add_sibling(enemy_inst)
				spawned.append(enemy_inst)
				enemy_inst.global_position = global_position

func _ready() -> void:
	if radius <= 0:
		$Area3D/CollisionShape3D.queue_free()
	else:
		$Area3D/CollisionShape3D.shape.radius = radius


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if get_parent() is Node3D and get_parent().get("done") == true:
		spawn()
	spawned = spawned.filter(func(enemy): return is_instance_valid(enemy))
	if has_spawned and spawned.size() == 0:
		done = true
	if get_children().size() == 0:
		queue_free()

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		spawn()
