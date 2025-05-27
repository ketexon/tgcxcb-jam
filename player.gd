class_name Player
extends CharacterBody2D

@export var tilemap_layer: TileMapLayer
@export var grid: Grid
@export var tile_highlight: TileHighlight
@export var move_speed: float = 1

var _tile_hover: Vector2i
var tile_hover: Vector2i:
	get: return _tile_hover
	set(v):
		if v != tile_hover:
			_tile_hover = v
			recalculate_tile_hover_end_point()
var tile_hover_path: Array[Vector2i] = []

var _cur_tile: Vector2i
var cur_tile: Vector2i:
	get: return _cur_tile
	set(v):
		if v != cur_tile:
			_cur_tile = v
			recalculate_tile_hover_end_point()

var path: Array[Vector2i] = []
var path_idx: float = 0

var tween: Tween

func map_to_global(map: Vector2i) -> Vector2:
	return tilemap_layer.to_global(tilemap_layer.map_to_local(map))

func _ready() -> void:
	var pos_local := tilemap_layer.to_local(global_position)
	cur_tile = tilemap_layer.local_to_map(pos_local)
	global_position = map_to_global(cur_tile)

func _process(delta: float) -> void:
	var mouse_pos_global := get_global_mouse_position()
	var mouse_pos_local := tilemap_layer.to_local(mouse_pos_global)
	var mouse_pos_map := tilemap_layer.local_to_map(mouse_pos_local)
	
	tile_hover = mouse_pos_map
	
	process_path(delta)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			calculate_path()

func calculate_path():
	if not grid.astar.is_in_boundsv(tile_hover):
		return
	
	if len(path) == 0:
		path_idx = 0
		path = tile_hover_path
	else:
		path = path.slice(0, ceili(path_idx)) + tile_hover_path

func process_path(delta: float):
	var idx := mini(floori(path_idx), len(path) - 1)
	if idx < 0:
		return
		
	var start_cell := path[idx]
	var start_point := map_to_global(start_cell)
	if idx + 1 >= len(path):
		global_position = start_point
		cur_tile = start_cell
		path.clear()
		return
		
	var end_cell := path[idx + 1]
	var end_point := map_to_global(end_cell)
	cur_tile = end_cell
	var t := fmod(path_idx, 1.0)
	global_position = lerp(start_point, end_point, t)
	
	path_idx += delta * move_speed

func recalculate_tile_hover_end_point():
	if not grid.astar.is_in_boundsv(tile_hover):
		tile_hover_path = []
		tile_highlight.highlighted = false
		return
	tile_hover_path = grid.astar.get_id_path(
		cur_tile,
		tile_hover,
		true # allow partial path
	)
	tile_highlight.highlight_pos = tile_hover_path[-1]
	tile_highlight.highlighted = true
