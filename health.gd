extends CanvasLayer

@export_group("Health")
@export_range(0,100,1,"or_greater") var health:= 100.0
@export_range(0,100,1,"or_greater") var max_health:= 100.0
@export_group("Overheal")
@export_range(0,100,1,"suffix:%","prefer_slider") var overheal_decay:= 10
@onready var label: Label = $Label
@onready var death: ColorRect = $Death
@onready var player: CharacterBody3D = get_parent().get_parent()
var timer = 1
var wasshown := false

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if get_parent().current:
		show()
	else:
		hide()
	var checkpoint: bool = player.checkpoint
	if health > max_health and not checkpoint:
		health -= ceil((health-max_health)*(overheal_decay/100.0))
	if health <= 0:
		get_parent().current = false
		death.show()
		label.hide()
		player.set("dead",true)
		Engine.time_scale = max(Engine.time_scale,1)
	else:
		death.hide()
		label.show()
		label.set("text",str(int(health*10)/10.0)+"/"+str(int(max_health)))
		#label.set("text",str(health)+"/"+str(max_health))
		if not checkpoint:
			health -= delta
		Engine.time_scale = min(0.5+(health/max_health*2),1)
