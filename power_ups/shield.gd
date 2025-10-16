extends PowerUp

func _ready():
	instant_effect = true
	main.new_turn_signal.connect(on_new_turn)
	expiration = 3
	sprite_sheet_frame = Vector2i(3, 0)


func on_contact(player : Player) -> bool:
	player.power_up = null
	explosion(player.global_position)
	return true

func on_new_turn():
	for player in get_tree().get_nodes_in_group("player"):
		if(player.power_up != self): continue
		_expire(player)
