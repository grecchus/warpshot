extends Node

var main : Node2D
var tilemap : TileMapLayer
var astar_grid : AStarGrid2D
const TILE_SIZE := Vector2(16.0, 16.0)
var tilemap_offset : Vector2
var offset_in_tiles : Vector2i
var map_border : Vector2
var pu_manager : Node
var highscore : int = 0

func save_highscore(score : int):
	if(score <= highscore):
		return
	var file = FileAccess.open("user://highscore.dat", FileAccess.WRITE)
	highscore = score
	file.store_64(score)
	file.close()
