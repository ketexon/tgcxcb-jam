class_name Grid
extends TileMapLayer

@export var layers: Array[TileMapLayer]

var astar: AStarGrid2D

var grid_nodes: Dictionary[Vector2i, Array] = {}

func map_to_global(map: Vector2i) -> Vector2:
	return to_global(map_to_local(map))

func _ready() -> void:
	_bake_gridnode_positions()
	
	astar = AStarGrid2D.new()
		
	astar.cell_shape = AStarGrid2D.CELL_SHAPE_ISOMETRIC_DOWN
	astar.cell_size = tile_set.tile_size
	var rect := get_used_rect()
	# grow the region so that we can click on tiles outside the region
	astar.region = get_used_rect()
	rect.grow(maxi(rect.size.x, rect.size.y))
	
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	
	astar.update()
	
	for x in astar.region.size.x:
		for y in astar.region.size.y:
			var coord := astar.region.position + Vector2i(x, y)
			update_coord_solid(coord)
	
	astar.update()

func update_coord_solid(coord: Vector2i):
	# check if any gridnodes are not walkable
	var walkable := false
	var blocked := false
	for grid_node in grid_nodes.get(coord, []) as Array[GridNode]:
		if not grid_node.walkable:
			blocked = true
	
	# short circuit so we dont need to check layers
	if blocked:
		astar.set_point_solid(coord, blocked or not walkable)
		return
	# check all layers
	# if there is a tile at that point
	#	if it is walkable on all layers, then the cell is walkable
	#	if one layer has walkable false, it is blocked (an obstacle)
	for layer in layers:
		var data := layer.get_cell_tile_data(coord)
		if data != null:
			if data.get_custom_data("walkable") as bool:
				walkable = true
			else:
				blocked = true
	astar.set_point_solid(coord, blocked or not walkable)

func _bake_gridnode_positions():
	for child in get_children():
		if child is GridNode:
			var grid_node := child as GridNode
			(
				grid_nodes.get_or_add(grid_node.coord, []) as Array[GridNode]
			).push_back(grid_node)
