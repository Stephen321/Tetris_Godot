tool
extends Node2D

class_name TetrisShape


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
# 0,1
# 2,3
# 4,5
# 6,7
var enabled_blocks setget set_enabled_blocks


# Set when type is: set_type
var _color


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func set_type(new_type):
	type = new_type
	modulate = COLORS[type]
	
	if Engine.is_editor_hint():
		property_list_changed_notify()
	
	var new_enabled_blocks = []	
	match new_type:
		Type.I:
			self.enabled_blocks = [
				true, false,
				true, false,
				true, false,
				true, false,
			]
		Type.J:
			self.enabled_blocks = [
				false, true,
				false, true,
				false, true,
				true, true,
			]
		Type.L:
			self.enabled_blocks = [
				true, false,
				true, false,
				true, false,
				true, true,
			]
		Type.O:
			self.enabled_blocks = [
				true, true,
				true, true,
				false, false,
				false, false,
			]
		Type.Z:
			self.enabled_blocks = [
				false, true,
				true, true,
				true, false,
				false, false,
			]
		Type.T:
			self.enabled_blocks = [
				false, true,
				true, true,
				false, true,
				false, false,
			]
		Type.S:
			self.enabled_blocks = [
				true, false,
				true, true,
				false, true,
				false, false,
			]


func set_enabled_blocks(new_enabled_blocks):
	enabled_blocks = new_enabled_blocks
	
	for child in get_children():
		child.queue_free()
	
	for i in enabled_blocks.size():
		if !enabled_blocks[i]:
			continue
			
		var x = (i % 2) * Globals.BLOCK_SIZE
		var y = (i / 2) * Globals.BLOCK_SIZE
		
		var Block = preload("res://Scenes/Block.tscn")
		var new_block = Block.instance()
		new_block.position.x = x;
		new_block.position.y = y;
		
		add_child(new_block)
		new_block.set_owner(self)
