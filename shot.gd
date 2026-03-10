extends RigidBody2D
class_name Shot

var prev_velocity_val : float
var prev_pos : Vector2
var shot_stop_val = 30.0 #the lower the value the longer it takes for a shot to stop
var main_shot := false

signal stopped
signal enemy_hit(enemy : Enemy)

func _init():
	contact_monitor = true
	max_contacts_reported = 32

func _physics_process(delta: float) -> void:
	var velocity_val = linear_velocity.length()
	if(velocity_val != 0):
		if(roundf(velocity_val) == roundf(prev_velocity_val) and roundf(velocity_val) < shot_stop_val):
			linear_velocity = Vector2.ZERO
			emit_signal("stopped")
	prev_velocity_val = velocity_val
	prev_pos = self.global_position
	



func _on_body_entered(body: Node) -> void:
	$BounceParticles.emitting
	
	if(body is Enemy):
		emit_signal("enemy_hit", body)
