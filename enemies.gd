extends Node

var current_enemy : Enemy
const ALLOW_PARTIAL = true
const adjecent := [
	Vector2i(0,-1),
	Vector2i(1,0),
	Vector2i(0,1),
	Vector2i(-1,0)
]

func enemy_turn():
#	FIND CLOSEST PLAYER
	var enemy_array := get_children()
	var last_tween : Tween = null
	var target_offset
	var player_array : Array = get_tree().get_nodes_in_group("player")
	for enemy in enemy_array:
		var enemy_tm_pos := GV.tilemap.local_to_map(enemy.position) - GV.offset_in_tiles
		var target_pos : Vector2i
		var id_path : Array[Vector2i]
		var tween = get_tree().create_tween()
		enemy.assigned_tween = tween
		current_enemy = enemy
		GV.astar_grid.set_point_solid(enemy_tm_pos, false)
		player_array.sort_custom(comp_dist_path)
		var player_tm_pos := GV.tilemap.local_to_map(player_array.front().position)
		last_tween = tween
		
		
		target_pos = find_free_tile(player_tm_pos)
		id_path = GV.astar_grid.get_id_path(enemy_tm_pos, target_pos, ALLOW_PARTIAL)
		id_path.pop_front()
		id_path.resize(clamp(enemy.MAX_MOVEMENT, 0, id_path.size()))
		if(not id_path.is_empty()):
			GV.astar_grid.set_point_solid(id_path.back(), true)
		else: GV.astar_grid.set_point_solid(enemy_tm_pos, true)
		
		while(not id_path.is_empty()):
			var new_pos = GV.tilemap.map_to_local(id_path.pop_front()) + GV.tilemap_offset
			tween.tween_property(enemy, "position", new_pos, 0.1)
	if(last_tween == null):
		return
	if(last_tween.is_running()):
		await last_tween.finished

func find_free_tile(pos : Vector2i, multiplier := 1) -> Vector2i:
	var free_tile := pos
	if(not GV.astar_grid.is_point_solid(free_tile)):
		return free_tile
	else:
		for ad in adjecent:
			if(not GV.astar_grid.is_point_solid(free_tile + ad*multiplier) and GV.astar_grid.is_in_boundsv(free_tile + ad*multiplier)):
				return free_tile + ad*multiplier
		return find_free_tile(pos, multiplier+1)


func comp_dist_path(p1 : Player, p2 : Player) -> bool:
	var id_path_1
	var id_path_2
	id_path_1 = GV.astar_grid.get_id_path(
		GV.tilemap.local_to_map(current_enemy.position),
		GV.tilemap.local_to_map(p1.position)
		)
	id_path_2 = GV.astar_grid.get_id_path(
		GV.tilemap.local_to_map(current_enemy.position),
		GV.tilemap.local_to_map(p2.position)
		)
	return id_path_1.size() < id_path_2.size()
