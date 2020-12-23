tool
extends Node2D

class_name TetrisShape

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

const MAX_BLOCKS = 8
enum Type { I, J, L, O, Z, T, S }

export (Type) var type setget set_type;

var Block = preload("res://Scenes/Block.tscn")

# Rotation offset in increments of 90 degrees (PI / 2)
var rotation_offset = 0

# Blocks enabled. Applies in the following positions:
# 0,1
# 2,3
# 4,5
# 6,7
var enabled_blocks setget set_enabled_blocks

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func set_type(new_type):
	type = new_type
	
	var new_enabled_blocks = []	
	match new_type:
		Type.I:
			new_enabled_blocks = [
				true, false,
				true, false,
				true, false,
				true, false,
			]
		Type.J:
			new_enabled_blocks = [
				false, true,
				false, true,
				false, true,
				true, true,
			]
		Type.L:
			new_enabled_blocks = [
				true, false,
				true, false,
				true, false,
				true, true,
			]
		Type.O:
			new_enabled_blocks = [
				true, true,
				true, true,
				false, false,
				false, false,
			]
		Type.Z:
			new_enabled_blocks = [
				false, true,
				true, true,
				true, false,
				false, false,
			]
			rotation_offset = 1
		Type.T:
			new_enabled_blocks = [
				false, true,
				true, true,
				false, true,
				false, false,
			]
			rotation_offset = 1
		Type.S:
			new_enabled_blocks = [
				true, false,
				true, true,
				false, true,
				false, false,
			]
			rotation_offset = 1

	self.enabled_blocks = new_enabled_blocks
 

func set_enabled_blocks(new_enabled_blocks):
	enabled_blocks = new_enabled_blocks
	
	for child in get_children():
		child.queue_free()
	
	for i in enabled_blocks.size():
		if !enabled_blocks[i]:
			continue
			
		var x = (i % 2) * Globals.BLOCK_SIZE
		var y = (i / 2) * Globals.BLOCK_SIZE
		
		var new_block = Block.instance()
		new_block.position.x = x;
		new_block.position.y = y;
		
		add_child(new_block)
		new_block.set_owner(self)
