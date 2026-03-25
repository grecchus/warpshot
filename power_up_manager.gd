extends Node
var rng = RandomNumberGenerator.new()

var saved_power_up : PowerUp
var power_up_queue : Array[PowerUp]

func give_power_up(power_up : PowerUp):
	saved_power_up = power_up
	if(power_up.instant_effect):
		get_tree().set_group("player", "power_up", saved_power_up)
		get_tree().set_group("player", "power_up_expiration", saved_power_up.expiration)
		saved_power_up = null

func get_random_power_up() -> PowerUp:
	rng.randomize()
	return get_child(rng.randi() % get_child_count())


func _on_main_new_turn_signal() -> void:
	if(saved_power_up == null) : return
	get_tree().set_group("player", "power_up", saved_power_up)
	get_tree().set_group("player", "power_up_expiration", saved_power_up.expiration)
	saved_power_up = null
