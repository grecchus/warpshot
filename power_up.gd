extends Area2D

var pu_node : PowerUp
@onready var sprite := $Sprite2D

func _on_body_entered(body: Node2D) -> void:
	if(body is Shot):
		GV.pu_manager.give_power_up(pu_node)
		GV.main.free_pu_spawnpoint(position)
		self.queue_free()

#DO POWER UPS
#CREATE PLAYER GROUP AND PLAYER SCENE
