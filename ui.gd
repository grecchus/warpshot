extends CanvasLayer

func _process(delta: float) -> void:
	$UI/Highscore.text = "HIGHSCORE: " + str(GV.highscore)
