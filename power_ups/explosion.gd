extends PowerUp

func _ready():
	main.new_turn_signal.connect(on_new_turn)
	expiration = 3
	sprite_sheet_frame = Vector2i(2, 0)

func on_shot_stopped(player : Player, shot : Shot):
	explosion(shot.global_position, 128.0)
	_expire(player)
