class_name Grid
extends TileMapLayer

@export var layers: Array[TileMapLayer]

var astar: AStarGrid2D

func _ready() -> void:
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
			var coords := astar.region.position + Vector2i(x, y)
			var walkable := false
			var blocked := false
			# check all layers
			# if there is a tile at that point
			#	if it is walkable on all layers, then the cell is walkable
			#	if one layer has walkable false, it is blocked (an obstacle)
			for layer in layers:
				var data := layer.get_cell_tile_data(coords)
				if data != null:
					if data.get_custom_data("walkable") as bool:
						walkable = true
					else:
						blocked = true
			astar.set_point_solid(coords, blocked or not walkable)
	
	astar.update()
