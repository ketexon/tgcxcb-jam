class_name GridNode
extends Node2D

@export var grid: Grid = null
@export var walkable: bool = true

var coord: Vector2i

func _ready() -> void:
	if grid == null:
		grid = get_parent() as Grid
	
	var grid_local_pos := grid.to_local(global_position) 
	coord = grid.local_to_map(grid_local_pos)
	global_position = grid.map_to_global(coord)
