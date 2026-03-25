extends Control

var game_scene = preload("res://main.tscn")

func _ready() -> void:
	load_highscore()
	$Highscore.text = "Highscore: " + str(GV.highscore)

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_packed(game_scene)

func load_highscore():
	var file = FileAccess.open("user://highscore.dat", FileAccess.READ)
	if(file):
		GV.highscore = file.get_64()
		file.close()
