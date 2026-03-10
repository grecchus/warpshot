extends Node
class_name PowerUp

@onready var main = get_node("/root/Main")

var expiration := 1
var instant_effect := false
const ADDITIONAL_SHOT := false

var sprite_sheet_frame := Vector2i(0, 0)


func _expire(player : Player):
	player.power_up_expiration -= 1
	if(player.power_up_expiration == 0):
		player.power_up = null

func on_shot(player : Player, shot : Shot):
	pass

func on_shot_stopped(player : Player, shot : Shot):
	pass

func on_contact(player : Player) -> bool:
	return false

func on_new_turn():
	pass

func explosion(position : Vector2, radius : float = 32.0):
	var animation = load("res://explosion.tscn").instantiate()
	self.add_child(animation)
	animation.global_position = position
	animation.set_explosion(radius * 2.0)
	
	var space = get_node("/root/Main").get_world_2d().direct_space_state
	var intersected_objects : Array
	var query = PhysicsShapeQueryParameters2D.new()
	query.shape = CircleShape2D.new()
	query.shape.radius = radius
	query.transform = query.transform.translated(position)
	intersected_objects = space.intersect_shape(query)
	for object in intersected_objects:
		if object["collider"] is Enemy:
			var dist = (object["collider"].global_position - position).length()
			object["collider"].queue_for_deletion(dist / radius)
