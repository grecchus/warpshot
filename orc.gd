extends StaticBody2D
class_name Enemy
#basic enemy - orc
#he will mindlesly charge towards player
#he might do two shorter charges
#or single long one
var MAX_MOVEMENT : int = 10
var movement_speed : float = 1.0
enum EnemyType{
	ORC,
	CATCHER,
	WIZARD,
	BRUTE
}
var type := EnemyType.ORC
var queued_for_deletion := false #queued for deletion
var assigned_tween : Tween

signal game_over(player_body : Player)

func set_type(val : int):
	type = val
	$Sprite.frame_coords.x = type

func _on_player_detection_body_entered(body: Node2D) -> void:
	if(body is Player and not queued_for_deletion):
		emit_signal("game_over", body)

func queue_for_deletion(wait : float = 0.0):
	var enemy_tm_pos := GV.tilemap.local_to_map(position) - GV.offset_in_tiles
	GV.astar_grid.set_point_solid(enemy_tm_pos, false)
	queued_for_deletion = true
	await get_tree().create_timer(wait).timeout
	queue_free()
