extends CanvasLayer

@export_group("Health")
@export_range(0,100,1,"or_greater") var health:= 100
@export_range(0,100,1,"or_greater") var max_health:= 100
@export_group("Overheal")
@export_range(0,100,1,"suffix:%","prefer_slider") var overheal_decay:= 10
@onready var label = $Label
@onready var death = $Death
var timer = 1

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if health > max_health:
		health -= ceil((health-max_health)*(overheal_decay/100.0))
	if health <= 0:
		death.show()
		label.hide()
		print(get_parent().get_parent())
	label.set("text",str(health)+"/"+str(max_health))
	
	timer -= delta
	if timer <= 0:
		timer += 1
		health -= 1
