extends Node2D

const DEFAULT_RADIUS := 64.0

func set_explosion(radius := DEFAULT_RADIUS):
	var scalar = radius / DEFAULT_RADIUS
	self.scale = self.scale * scalar
	
	$FirstExplosion.emitting = true
	$SecondExplosion.emitting = true


func _on_second_explosion_finished() -> void:
	queue_free()
