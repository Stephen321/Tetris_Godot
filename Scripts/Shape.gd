extends Node2D

class_name TetrisShape

signal stopped_moving
signal game_over


enum Type { I, J, L, O, Z, T, S }
const FAST_DOWN_SPEED_MULT = 8
const ENABLED_BLOCKS_SIZE = 4
const MAX_BLOCKS = 8
const COLORS = {
	Type.I: Color("#30c7ef"),
	Type.J: Color("#5866af"),
	Type.L: Color("#f17922"),
	Type.O: Color("#f7d407"),
	Type.Z: Color("#40b73f"),
	Type.T: Color("#ad4e9e"),
	Type.S: Color("#f12029"),
}


export (Type) var type = Type.I setget set_type
export (bool) var enabled = true


# Blocks enabled. Applies in the following positions:
# 0,1,2,3
# 4,5,6,7
var enabled_blocks setget set_enabled_blocks
var moving = true
var grid_ref
var being_controlled = true

# Set when type is: set_type
var _color
var _last_input_event_time = 1.0 / Globals.HBLOCKS_PER_SEC
var _blocks = [] setget , get_blocks
var _rotation = 0
var _fast_down = false


# Called when the node enters the scene tree for the first time.
func _ready():
	if not enabled:
		return
	position.y = Globals.BLOCK_SIZE * -ENABLED_BLOCKS_SIZE;

func _input(event):
	if not enabled:
		return
	if being_controlled:
		if event.is_action_pressed("ui_up"):
			_rotation += 1
			if _rotation > 3:
				_rotation = 0
			_update_enabled_blocks()
		if event.is_action_pressed("ui_down"):
			_fast_down = true
		
		# TODO: check if going to rotate into a wall or another block
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not enabled:
		return
		
	if not moving:
		return
		
	var speed_mult = FAST_DOWN_SPEED_MULT if _fast_down else 1
	var y_change = Globals.BLOCK_SIZE * Globals.BLOCK_PER_SECOND * delta * speed_mult	
	
	var collision = false
	for b in _blocks:
		var c = _get_col_from_block(b, y_change)
		var r = _get_row_from_block(b)
		var key = Vector2(c, r + 1)
		
		# check if it would go off the screen or if any block would collide with another below 
		if key.y >= Globals.GRID_BLOCK_ROWS or (grid_ref.has(key) and grid_ref[key]):
			collision = true
			break
			
		
	if not collision:
		position.y += y_change
	else:
		position.y = ((position.y / Globals.BLOCK_SIZE) as int) * Globals.BLOCK_SIZE
		
		var game_has_ended = false
		for b in _blocks:
			var r = _get_row_from_block(b)
			if r < 0:
				game_has_ended = true
				emit_signal("game_over")
				break
			
		set_moving(false, not game_has_ended)
	
	var dir = 0
	if being_controlled:
		if Input.is_action_pressed("ui_left"):
			dir = -1
		elif Input.is_action_pressed("ui_right"):
			dir = 1

		_last_input_event_time += delta

	if dir != 0:
		if _last_input_event_time > 1.0 / Globals.HBLOCKS_PER_SEC:
			_last_input_event_time = 0
			
			var new_x = position.x + (dir * Globals.BLOCK_SIZE)
			
			var can_move = true
			for b in _blocks:
				var c = _get_col_from_block(b)
				var r = _get_row_from_block(b)
				
				var new_c = c + dir
				
				if new_c < 0 or new_c > Globals.GRID_BLOCK_COLS - 1:
					can_move = false
					break
				var key1 = Vector2(new_c, r)
				var key2 = Vector2(new_c, r + 1)
				if (grid_ref.has(key1) and grid_ref[key1] or
					grid_ref.has(key2) and grid_ref[key2]):
					can_move = false
					break
					

			if can_move:
				position.x = new_x

func clear_blocks_from_row(row):
	var blocks_to_delete = []
	for i in range(_blocks.size()):
		var r = _get_row_from_block(_blocks[i])
		if r == row:
			blocks_to_delete.append(i)
		
	var blocks_deleted = 0
	for b_i in blocks_to_delete:
		var i = b_i - blocks_deleted
		var b = _blocks[i]
		_blocks.remove(i)
		b.queue_free()
		blocks_deleted += 1

func move_blocks_down(above, by):
	for b in _blocks:
		var r = _get_row_from_block(b)
		if r < above:
			b.position.y += Globals.BLOCK_SIZE * by
	
	
func get_block_grid_vectors():
	var grid_vectors = []
	for b in _blocks:
		var c = _get_col_from_block(b)
		var r = _get_row_from_block(b)
		grid_vectors.append(Vector2(c, r))
	return grid_vectors
	
func _get_row_from_block(block, offset = 0):
	return ((position.y + block.position.y + offset) / Globals.BLOCK_SIZE)  as int

func _get_col_from_block(block, offset = 0):
	return ((position.x + block.position.x + offset) / Globals.BLOCK_SIZE)  as int
	
	
func _update_enabled_blocks():
	var new_enabled_blocks = []

	match type:
		Type.I:
			new_enabled_blocks =  [
					[
						false, false, false, false,
						true, true, true, true,
						false, false, false, false,
						false, false, false, false,
					],
					[
						false, false, true, false,
						false, false, true, false,
						false, false, true, false,
						false, false, true, false,
					],
					[
						false, false, false, false,
						true, true, true, true,
						false, false, false, false,
						false, false, false, false,
					],
					[
						false, true, false, false,
						false, true, false, false,
						false, true, false, false,
						false, true, false, false,
					],
				][_rotation]
		Type.J:
			new_enabled_blocks =  [
					[
						true, false, false, false,
						true, true, true, false,
						false, false, false, false,
						false, false, false, false,
					],
					[
						false, true, true, false,
						false, true, false, false,
						false, true, false, false,
						false, false, false, false,
					],
					[
						false, false, false, false,
						true, true, true, false,
						false, false, true, false,
						false, false, false, false,
					],
					[
						false, true, false, false,
						false, true, false, false,
						true, true, false, false,
						false, false, false, false,
					],
				][_rotation]
		Type.L:
			new_enabled_blocks =  [
					[
						false, false, true, false,
						true, true, true, false,
						false, false, false, false,
						false, false, false, false,
					],
					[
						false, true, false, false,
						false, true, false, false,
						false, true, true, false,
						false, false, false, false,
					],
					[
						false, false, false, false,
						true, true, true, false,
						true, false, false, false,
						false, false, false, false,
					],
					[
						true, true, false, false,
						false, true, false, false,
						false, true, false, false,
						false, false, false, false,
					],
				][_rotation]
		Type.O:
			new_enabled_blocks =  [
				true, true, false, false,
				true, true, false, false,
				false, false, false, false,
				false, false, false, false,
			]
		Type.Z:
			new_enabled_blocks =  [
					[
						true, true, false, false,
						false, true, true, false,
						false, false, false, false,
						false, false, false, false,
					],
					[
						false, true, false, false,
						true, true, false, false,
						true, false, false, false,
						false, false, false, false,
					],
					[
						true, true, false, false,
						false, true, true, false,
						false, false, false, false,
						false, false, false, false,
					],
					[
						false, false, true, false,
						false, true, true, false,
						false, true, false, false,
						false, false, false, false,
					],
				][_rotation]
		Type.T:
			new_enabled_blocks =  [
					[
						false, true, false, false,
						true, true, true, false,
						false, false, false, false,
						false, false, false, false,
					],
					[
						false, true, false, false,
						false, true, true, false,
						false, true, false, false,
						false, false, false, false,
					],
					[
						false, false, false, false,
						true, true, true, false,
						false, true, false, false,
						false, false, false, false,
					],
					[
						false, true, false, false,
						true, true, false, false,
						false, true, false, false,
						false, false, false, false,
					],
				][_rotation]
		Type.S:
			new_enabled_blocks =  [
					[
						false, true, true, false,
						true, true, false, false,
						false, false, false, false,
						false, false, false, false,
					],
					[
						false, true, false, false,
						false, true, true, false,
						false, false, true, false,
						false, false, false, false,
					],
					[
						false, true, true, false,
						true, true, false, false,
						false, false, false, false,
						false, false, false, false,
					],
					[
						true, false, false, false,
						true, true, false, false,
						false, true, false, false,
						false, false, false, false,
					],
				][_rotation]
	self.enabled_blocks = new_enabled_blocks

func set_moving(new_moving, can_emit):
	moving = new_moving
	if not moving:
		being_controlled = false
		if can_emit:
			emit_signal("stopped_moving")

func set_type(new_type):
	type = new_type
	modulate = COLORS[type]
	
	if Engine.is_editor_hint():
		property_list_changed_notify()

	_update_enabled_blocks()


func set_enabled_blocks(new_enabled_blocks):
	enabled_blocks = new_enabled_blocks
	
	for child in get_children():
		child.queue_free()
		
	_blocks.clear()
	
	for i in enabled_blocks.size():
		if !enabled_blocks[i]:
			continue
			
		var x = (i % ENABLED_BLOCKS_SIZE) * Globals.BLOCK_SIZE
		var y = (i / ENABLED_BLOCKS_SIZE) * Globals.BLOCK_SIZE
		
		var Block = preload("res://Scenes/Block.tscn")
		var new_block = Block.instance()
		new_block.position.x = x
		new_block.position.y = y
		
		add_child(new_block)
		new_block.set_owner(self)
		
		_blocks.append(new_block)		
		
func get_blocks():
	return _blocks
	
func get_default_col_width():
	match type:
		Type.I:
			return 4
		Type.O:
			return 2
		_:
			return 3

