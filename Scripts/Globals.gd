extends Node2D

const BLOCK_SIZE = 32
const GRID_BLOCK_COLS = 10
const GRID_BLOCK_ROWS = 20
const SHAPE_COUNT = 7

const START__spawn_RATE = 5
const BLOCK_PER_SECOND = 2
const HBLOCKS_PER_SEC = 6 # How many blocks we can move horizontally while holding key down

func _ready():
	randomize()
