class_name TileHighlight
extends TileMapLayer

@export var tile_source_id: int = 1
@export var tile_atlas_coord: Vector2i
@export var tile_alternative: int = 0 

var _highlighted: bool = false
var highlighted: bool:
	get: return _highlighted
	set(v):
		_highlighted = v
		_update_highlight()

var _highlight_pos: Vector2i
var highlight_pos: Vector2i:
	set(v):
		_highlight_pos = v
		_update_highlight()
	get:
		return _highlight_pos

var _last_highlight_pos: Vector2i = Vector2.ZERO

func _update_highlight():
	# clear previous highligh, if exists (might be redundant)
	set_cell(_last_highlight_pos, -1)
	if highlighted:
		_last_highlight_pos = highlight_pos
		set_cell(_last_highlight_pos, tile_source_id, tile_atlas_coord, tile_alternative)
