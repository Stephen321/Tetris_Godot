extends Node2D

const BLOCK_SIZE = 32
const MAP_WIDTH = 12
const SHAPE_COUNT = 7

const START_SPAWN_RATE = 1
const BLOCK_PER_SECOND = 2

func _ready():
	randomize()
