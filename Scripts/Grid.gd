extends Sprite


onready var spawn_timer = $Timer

var _grid = {}	
var _shapes = []
var _update = 0

func _ready():	
	empty_grid()
	
	spawn_timer.wait_time = Globals.START_SPAWN_RATE
	spawn_timer.connect("timeout", self, "spawn")
	spawn_timer.start()
	spawn()
	
func _process(delta):
	_update += delta
#
#	if _update > 1.0:
#		_update = 0
#		for i in range(_blocks.size()):
#			var b = _blocks[i]
#			if !is_instance_valid(b):
#				_blocks.remove(i)
#				i-= 1
#		print(_blocks)
#
#	if _update > 1:
#		_update = 0

	
	
func spawn():
	print("spawning")
	var Shape = preload("res://Scenes/Shape.tscn")
	var new_shape = Shape.instance()	
	add_child(new_shape)
	new_shape.set_owner(self)
	new_shape.connect("stopped_moving", self, "update_occupied_grid")
	new_shape.grid_ref = _grid
	
	_shapes.append(new_shape)
	#new_shape.position.x = Globals.BLOCK_SIZE * -2;
	#_blocks += new_shape.get_blocks()
 
func empty_grid():
	for r in range(Globals.GRID_BLOCK_ROWS):
		for c in range(Globals.GRID_BLOCK_COLS):
			_grid[Vector2(c, r)] = false


func clear_complete_rows(complete_rows):
	for s in _shapes:
		for r in complete_rows:
			s.clear_blocks_from_row(r)
	
func update_occupied_grid():
	_grid.clear()
	
	empty_grid()
			
	for s in _shapes:
		if s.moving:
			continue
		for grid_vector in s.get_block_grid_vectors():
			_grid[grid_vector] = true
		
	var complete_rows = []
	var map_str = ""
	for r in range(Globals.GRID_BLOCK_ROWS):
		var is_row_complete = true
		for c in range(Globals.GRID_BLOCK_COLS):
			map_str += "X " if _grid[Vector2(c, r)] else "o "
			is_row_complete = is_row_complete and _grid[Vector2(c, r)]
		if is_row_complete:
			complete_rows.append(r)
		map_str += "\n"
	$DebugLab.text = map_str
	
	clear_complete_rows(complete_rows)
		
	
