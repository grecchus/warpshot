extends CharacterBody2D
class_name Player
@onready var shot_scene = preload("res://shot.tscn")

const COL_LAYER = 2

var sc : float = 10.0 #spring contestant
var max_tension := 100.0
var has_shot := false
var shot : RigidBody2D
var prev_pressed := false
var indicator_length := 100.0

var power_up : PowerUp = null
var power_up_expiration := 0

signal shot_released()
signal shot_stopped()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			prev_pressed = true
		elif(prev_pressed):
			if(not has_shot):
				var dir = (global_position - get_global_mouse_position()).normalized()
				
				shoot(dir)
				has_shot = true
				prev_pressed = false

func shoot(direction : Vector2, main_shot := true):
	direction = direction.normalized()
	var diff = global_position - get_global_mouse_position()
	var force_clamped = clamp(diff.length(), 0.0, max_tension)
	shot = shot_scene.instantiate()
	GV.main.add_child(shot)
	shot.main_shot = main_shot
	shot.global_position = self.global_position
	shot.show_behind_parent = true
	shot.stopped.connect(_on_shot_stopped.bind(shot))
	shot.enemy_hit.connect(get_parent()._on_enemy_hit)
	emit_signal("shot_released")
	shot.apply_impulse(direction*force_clamped*sc)
	if(power_up != null and main_shot): power_up.on_shot(self, shot)

func _process(delta: float) -> void:
	if Input.is_action_pressed("left_click"):
		circle()
	dashed_line()
	get_parent().queue_redraw()
	if(power_up != null):
		$Label.text = str(power_up) + ": " + str(power_up_expiration)
	else:
		$Label.text = ""

func _on_shot_stopped(shot):
	if(power_up != null): power_up.on_shot_stopped(self, shot)
	if(shot.main_shot): 
		warp(shot.global_position)
	emit_signal("shot_stopped")
	shot.queue_free()
	

func warp(new_pos : Vector2i):
	global_position = new_pos
	$GPUParticles2D.emitting = true

func dashed_line():
	var diff = -(get_parent().get_local_mouse_position() - self.position).normalized()
	get_parent().draw_callables.append(
		Callable.create(get_parent(), "draw_dashed_line")
			.bind(position, position + diff * indicator_length, Color(1.0, 1.0, 1.0), 2.0, 10.0))

func circle():
	var diff = get_parent().get_local_mouse_position() - self.position
	var radius := 10.0
	if(diff.length() > max_tension):
		diff = diff.normalized() * max_tension
	get_parent().draw_callables.append(
		Callable.create(get_parent(), "draw_circle")
			.bind(position+diff, radius, Color(0.33, 1.0, 1.0), false, 2.0))
	
	var fill = radius * diff.length()/max_tension
	get_parent().draw_callables.append(
		Callable.create(get_parent(), "draw_circle")
			.bind(position+diff, fill, Color(0.0, 0.0, 1.0), true))

func die() -> bool:
	if(power_up != null):
		if(power_up.on_contact(self)):
			self.set_collision_layer_value(COL_LAYER, false)
			return false
	return true

func reset_collision():
	self.set_collision_layer_value(COL_LAYER, true)
