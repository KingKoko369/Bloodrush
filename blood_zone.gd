extends Area3D


func _on_body_entered(body: Node3D) -> void:
	print("touched" + str(body))
	if body.is_in_group("player"):
		print("touch")
		body.health.health += 10
 a		get_parent().get_parent().remove_child(get_parent())
