tool
extends Node2D

class_name TetrisShape

signal stopped_moving


enum Type { I, J, L, O, Z, T, S }
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


# Blocks enabled. Applies in the following positions:
# 0,1,2,3
# 4,5,6,7
var enabled_blocks setget set_enabled_blocks
var moving = true setget set_moving
var grid_ref

# Set when type is: set_type
var _color
var _last_input_event_time = 1.0 / Globals.HBLOCKS_PER_SEC
var _blocks = [] setget , get_blocks
var _rotation_pos_offset = Vector2()


# Called when the node enters the scene tree for the first time.
func _ready():
	self.type = randi() % Globals.SHAPE_COUNT
	position.y = Globals.BLOCK_SIZE * -2;
	print(self.type)

func _input(event):
	if event.is_action_pressed("ui_select"):
		rotation_degrees += 90
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not moving:
		return
		
	var new_y = position.y + Globals.BLOCK_SIZE * Globals.BLOCK_PER_SECOND * delta	
	# check bottom of screen
	if position.y > Globals.BLOCK_SIZE * (Globals.GRID_BLOCK_ROWS - 2):
		position.y = Globals.BLOCK_SIZE * (Globals.GRID_BLOCK_ROWS - 2)
		self.moving = false
	else:
		# check if any block would collide with another below
		var collision = false
		for b in _blocks:
			var c = _get_col_from_block(b)
			var r = _get_row_from_block(b)
			var key = Vector2(c, r + 1)
			if grid_ref && grid_ref.has(key) and grid_ref[key]:
				collision = true
				self.moving = false
				break
			
		if not collision:
			position.y = new_y
	
	var dir = 0
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
				var b_x = new_x + b.position.x
				if b_x < 0 or b_x + Globals.BLOCK_SIZE > Globals.BLOCK_SIZE * Globals.GRID_BLOCK_COLS:
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

func get_block_grid_vectors():
	var grid_vectors = []
	for b in _blocks:
		var c = _get_col_from_block(b)
		var r = _get_row_from_block(b)
		grid_vectors.append(Vector2(c, r))
	return grid_vectors
	
func _get_row_from_block(block):
	return ((position.y + block.position.y) / Globals.BLOCK_SIZE)  as int

func _get_col_from_block(block):
	return ((position.x + block.position.x) / Globals.BLOCK_SIZE)  as int
	
func set_moving(new_moving):
	moving = new_moving
	if not moving:
		emit_signal("stopped_moving")
		print("stopped moving")

func set_type(new_type):
	type = new_type
	modulate = COLORS[type]
	
	if Engine.is_editor_hint():
		property_list_changed_notify()
	
	var new_enabled_blocks = []	
	match new_type:
		Type.I:
			self.enabled_blocks = [
				false, false, false, false,
				true, true, true, true,
			]
		Type.J:
			self.enabled_blocks = [
				true, false, false, false,
				true, true, true, false,
			]
		Type.L:
			self.enabled_blocks = [
				false, false, true, false,
				true, true, true, false,
			]
		Type.O:
			self.enabled_blocks = [
				true, true, false, false,
				true, true, false, false,
			]
		Type.Z:
			self.enabled_blocks = [
				true, true, false, false,
				false, true, true, false,
			]
		Type.T:
			self.enabled_blocks = [
				false, true, false, false,
				true, true, true, false,
			]
		Type.S:
			self.enabled_blocks = [
				false, true, true, false,
				true, true, false, false,
			]


func set_enabled_blocks(new_enabled_blocks):
	enabled_blocks = new_enabled_blocks
	
	for child in get_children():
		child.queue_free()
		
	_blocks.clear()
	
	for i in enabled_blocks.size():
		if !enabled_blocks[i]:
			continue
			
		var x = (i % 4) * Globals.BLOCK_SIZE
		var y = (i / 4) * Globals.BLOCK_SIZE
		
		var Block = preload("res://Scenes/Block.tscn")
		var new_block = Block.instance()
		new_block.position.x = x;
		new_block.position.y = y;
		
		add_child(new_block)
		new_block.set_owner(self)
		
		_blocks.append(new_block)		
		
func get_blocks():
	return _blocks

