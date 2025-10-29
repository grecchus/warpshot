extends PowerUp

var set_to_expire := false

func _ready():
	main.new_turn_signal.connect(on_new_turn)
	expiration = 1
	sprite_sheet_frame = Vector2i(1, 0)


func on_shot(player : Player, shot : Shot):
	var dir = (player.global_position - get_node("/root/Main").get_global_mouse_position()).normalized()
	var angle_fix = float(dir.x < 0)*deg_to_rad(90.0) * sign(dir.x) * sign(dir.y)
	var angle_sub = asin(dir.y) - deg_to_rad(30.0) - angle_fix
	var angle_add = asin(dir.y) + deg_to_rad(30.0) - angle_fix
	var ndir1 = Vector2(cos(angle_sub), sin(angle_sub))
	var ndir2 = Vector2(cos(angle_add), sin(angle_add))
	player.shoot(ndir1, ADDITIONAL_SHOT)
	player.shoot(ndir2, ADDITIONAL_SHOT)

func on_shot_stopped(player : Player, shot : Shot):
	if(not shot.main_shot and get_tree().get_node_count_in_group("player") < 3):
		set_to_expire = true
		get_node("/root/Main").spawn_player(shot.global_position - GV.tilemap_offset)

func on_new_turn():
	if(not set_to_expire): return
	for player in get_tree().get_nodes_in_group("player"):
		_expire(player)
	set_to_expire = false
