extends Node2D
@onready var enemy_scene = preload("res://orc.tscn")
@onready var powerup_scene = preload("res://power_up.tscn")
@onready var player_scene = preload("res://player.tscn")

enum SPECIAL{
	SPAWNPOINT,
	POWERUP
}
enum TILEMAP_SOURCE{
	WALLS,
	SPECIAL
}
var rng = RandomNumberGenerator.new()
var turn : int = 1
var tt_starting_value : float = 8.0 #turn time starting value
var turn_time : float = 4.0
var score := 0 
var player_start_pos : Vector2
var signals_recieved : int = 0

const FIRST_TURN := true

var enemy_spawnpoints : Array[Vector2i] = []
var powerups_spawnpoints : Array[Vector2i] = []

var astar_grid : AStarGrid2D
var grid_offset : Vector2

var draw_callables : Array[Callable]
signal new_turn_signal #emitted on every new turn except first turn


func _ready() -> void:
	astar_grid = _setup_astar()
	GV.tilemap = $Level/Tilemap
	GV.pu_manager = $PowerUpManager
	GV.main = self
	GV.astar_grid = astar_grid
	GV.tilemap_offset = $Level/Tilemap.global_position
	GV.offset_in_tiles = Vector2i(GV.tilemap_offset / GV.TILE_SIZE)
	GV.map_border = Vector2($Level/Tilemap.get_used_rect().end)*GV.TILE_SIZE + GV.tilemap_offset
	player_start_pos = $Player.position
	new_game()
	
func _process(delta: float) -> void:
	var tl_to_tt : float = $TurnTimer.time_left / turn_time
	$UI_Canvas/UI/TurnLabel.text = "TURN: " + str(turn)
	$UI_Canvas/UI/Score.text = "SCORE: " + str(score)
	$UI_Canvas/UI/TurnTime.scale.x = tl_to_tt
	$UI_Canvas/UI/TurnTime.position.x = $UI_Canvas/UI/TurnTime.size.x * (1.0 - $UI_Canvas/UI/TurnTime.scale.x) / 2.0

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
			$TurnTimer.paused = !$TurnTimer.paused
			#print($Level/Tilemap.local_to_map($Player.position))
			#print(astar_grid.is_point_solid($Level/Tilemap.local_to_map(get_local_mouse_position())))
			print("mouse pos: "+str($Level/Tilemap.local_to_map(get_local_mouse_position())))
			print(get_global_mouse_position())
			#print(GV.tilemap_offset)
			#print(GV.map_border)




########################################################
#	Turn Management
########################################################

func _on_turn_timer_timeout() -> void:
	$TurnTimer.paused = true
	enemy_turn()

func _on_player_shot_released() -> void:
	signals_recieved += 1
	$TurnTimer.paused = true

func _on_shot_stopped() -> void:
	#print(get_tree().get_node_count_in_group("shot"))
	signals_recieved -= 1
	if(signals_recieved > 0): return
	await get_tree().create_timer(0.5).timeout
	$TurnTimer.stop()
	enemy_turn()

func enemy_turn():
	#get_tree().set_group("player", "has_shot", true)
	if($Enemies.get_child_count() > 0):
		await $Enemies.enemy_turn()
	new_turn()

func new_turn(is_first_turn := false):
	signals_recieved = 0
	if(is_first_turn):
		turn_time = tt_starting_value
		turn = 1
		score = 0
	else:
		turn += 1
		score += 50
	if(turn%3 == 1):
		spawn_enemies()
		spawn_powerups()
	$UI_Canvas/UI/TurnTime.scale.x = 1.0
	get_tree().set_group("player", "has_shot", false)
	get_tree().call_group("player", "reset_collision")
	$TurnTimer.paused = false
	$TurnTimer.start(turn_time)
	if(not is_first_turn): emit_signal("new_turn_signal")

func new_game():
	get_tree().get_node_count_in_group("player")
	get_tree().call_group("player", "queue_free")
	spawn_player()
	
	$UI_Canvas/UI/GameOver.hide()
	get_tree().paused = false
	get_tree().call_group("enemies", "queue_for_deletion")
	get_tree().call_group("power_ups", "queue_free")
	
	_setup_astar()
	get_special_tiles() #will be used for map generation
	new_turn(FIRST_TURN)

func _on_game_over(player_body):
	if(get_tree().get_node_count_in_group("player") > 1):
		if(player_body.die()): player_body.queue_free()
		return
	if(not player_body.die()): return
	$UI_Canvas/UI/GameOver.show()
	var tweens = get_tree().get_processed_tweens()
	for tween in tweens:
		tween.kill()
	get_tree().paused = true
	GV.save_highscore(score)

func _on_enemy_hit(enemy : Enemy):
	enemy.queue_free()
	score += 100




########################################################
#	Map setup
########################################################

func get_special_tiles():
	enemy_spawnpoints = []
	powerups_spawnpoints = []
	
	var tiles : Array[Vector2i] = $Level/Tilemap.get_used_cells_by_id(TILEMAP_SOURCE.SPECIAL)
	for tile in tiles:
		var atl_coords : int = $Level/Tilemap.get_cell_atlas_coords(tile).y
		match atl_coords:
			SPECIAL.SPAWNPOINT:
				enemy_spawnpoints.append(tile)
			SPECIAL.POWERUP:
				powerups_spawnpoints.append(tile)
		$Level/Tilemap.set_cell(tile, 1, Vector2i(0,atl_coords), 1) #sets special tiles to alternative, invisible variant
		#set_cell(layer: int, coords: Vector2i, source_id: int = -1, atlas_coords: Vector2i = Vector2i(-1, -1), alternative_tile: int = 0)

func _setup_astar() -> AStarGrid2D:
	var new_astar = AStarGrid2D.new()
	var tiles = $Level/Tilemap.get_used_cells()
	new_astar.region = $Level/Tilemap.get_used_rect()
	new_astar.cell_size = GV.TILE_SIZE
	new_astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	new_astar.update()
	#setting solid points - eg. walls
	for tile in tiles:
		new_astar.set_point_solid(tile)
	return new_astar

########################################################
#	Misc
########################################################

func _draw() -> void:
	for callable in draw_callables:
		callable.call()
	draw_callables.clear()


########################################################
#	Spawning
########################################################

func spawn_enemies():
	if(enemy_spawnpoints.is_empty()): return
	var temp_es = enemy_spawnpoints.duplicate()
	var new_enemies_nr = clamp(temp_es.size() / 3, 1, temp_es.size())
	#new_enemies_nr = 0
	for ne in new_enemies_nr:
		var enemy_pos = temp_es.pick_random()
		temp_es.erase(enemy_pos)
		#spawning
#		set solid on spawn
		astar_grid.set_point_solid(enemy_pos)
		enemy_pos = $Level/Tilemap.map_to_local(enemy_pos)
		var new_enemy = enemy_scene.instantiate()
		$Enemies.add_child(new_enemy)
		new_enemy.position = enemy_pos + GV.tilemap_offset
		new_enemy.game_over.connect(_on_game_over)
		new_enemy.add_to_group("enemies")

func spawn_powerups():
#	THEY CAN SPAWN ON TOP OF EACH OTHER - FIX THIS
	if(powerups_spawnpoints.is_empty()): return
	var temp_ps = powerups_spawnpoints.duplicate()
	var new_powerups_nr = clamp(temp_ps.size() / 4, 1, temp_ps.size())
	for np in new_powerups_nr:
		var powerup_pos = temp_ps.pick_random()
		temp_ps.erase(powerup_pos)
		#spawning
#		set solid on spawn
		powerup_pos = $Level/Tilemap.map_to_local(powerup_pos)
		var new_powerup = powerup_scene.instantiate()
		$PowerUps.add_child(new_powerup)
		new_powerup.position = powerup_pos + GV.tilemap_offset
		new_powerup.pu_node = $PowerUpManager.get_random_power_up()
		new_powerup.sprite.frame_coords = new_powerup.pu_node.sprite_sheet_frame

func spawn_player(player_pos := player_start_pos):
	var player : Player = player_scene.instantiate()
	player.position = player_pos
	player.power_up = null
	player.shot_released.connect(_on_player_shot_released)
	player.shot_stopped.connect(_on_shot_stopped)
	self.add_child(player)
