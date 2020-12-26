extends Sprite

signal completed_rows

var _grid = {}	
var _shapes = []
var _update = 0

func _ready():	
	_empty_grid()
	_spawn()
	
func _process(delta):
	pass
	#_update += delta
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

	
	
func _spawn():
	print("_spawning")
	var Shape = preload("res://Scenes/Shape.tscn")
	var new_shape = Shape.instance()	
	add_child(new_shape)
	new_shape.set_owner(self)
	new_shape.connect("stopped_moving", self, "_on_Shape_stopped_moving", [new_shape])
	new_shape.grid_ref = _grid
	
	_shapes.append(new_shape)
	#new_shape.position.x = Globals.BLOCK_SIZE * -2;
	#_blocks += new_shape.get_blocks()
 
func _empty_grid():
	for r in range(Globals.GRID_BLOCK_ROWS):
		for c in range(Globals.GRID_BLOCK_COLS):
			_grid[Vector2(c, r)] = false


func _clear_complete_rows(complete_rows):
	for s in _shapes:
		for r in complete_rows:
			s.clear_blocks_from_row(r)
			for c in range(Globals.GRID_BLOCK_COLS):
				_grid[Vector2(c, r)] = false

func _move_blocks_down(above, by):
	for s in _shapes:
		# only check shapes that are above the completed rows
		if s.position.y < above * Globals.BLOCK_SIZE:
			s.move_blocks_down(above, by)
			
func _update_grid_occupied():	
	_grid.clear()
	_empty_grid()			
	# fill in where all the blocks are
	for s in _shapes:
		if s.moving:
			continue
		for grid_vector in s.get_block_grid_vectors():
			_grid[grid_vector] = true
			
	
func _on_Shape_stopped_moving(shape):		
	_update_grid_occupied()
		
	# see if any rows have been compeleted
	var complete_rows = []
	for r in range(Globals.GRID_BLOCK_ROWS):
		var is_row_complete = true
		for c in range(Globals.GRID_BLOCK_COLS):
			is_row_complete = is_row_complete and _grid[Vector2(c, r)]
		if is_row_complete:
			complete_rows.append(r)
	
	# clear those blocks
	_clear_complete_rows(complete_rows)
	emit_signal("completed_rows", complete_rows.size())
	
	# remove empty shapes
	# copied from Shape._clear_complete_rows
	var shapes_to_delete = []
	for i in range(_shapes.size()):
		if _shapes[i].get_children().size() == 0:
			shapes_to_delete.append(i)
		
	var shapes_deleted = 0
	for s_i in shapes_to_delete:
		var i = s_i - shapes_deleted
		var s = _shapes[i]
		_shapes.remove(i)
		s.queue_free()
		shapes_deleted += 1
		
	# move blocks down 
	if complete_rows.size() > 0:
		_move_blocks_down(complete_rows[0], complete_rows.size())
	
	# update the grid
	_update_grid_occupied()
		
	# set controlled shape
		
	# _spawn new shape
	_spawn()
	
	_print_grid()
	

func _print_grid():
	
	var map_str = ""
	for r in range(Globals.GRID_BLOCK_ROWS):
		for c in range(Globals.GRID_BLOCK_COLS):
			map_str += "X " if _grid[Vector2(c, r)] else "o "
		map_str += "\n"
	$DebugLab.text = map_str
