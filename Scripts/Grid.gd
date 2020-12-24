extends Sprite


onready var spawn_timer = $Timer

func _ready():
	spawn_timer.wait_time = Globals.START_SPAWN_RATE
	spawn_timer.connect("timeout", self, "spawn")
	spawn_timer.start()
	
func spawn():
	print("spawning")
	var Shape = preload("res://Scenes/Shape.tscn")
	var new_shape = Shape.instance()
	add_child(new_shape)
	new_shape.set_owner(self)
 
