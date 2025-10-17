extends CanvasLayer

func _process(delta: float) -> void:
	$UI/Highscore.text = "HIGHSCORE: " + str(GV.highscore)
	$UI/PowerUp.text = "Power Up: NONE"
	var players = get_tree().get_nodes_in_group("player")
	if(players == null): return
	if(players[0].power_up != null):
		$UI/PowerUp.text = "Power Up: " + str(players[0].power_up.name)
