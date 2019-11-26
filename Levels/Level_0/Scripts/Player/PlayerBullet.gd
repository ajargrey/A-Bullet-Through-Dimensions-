extends Node2D

var bullet_speed = 1500
var player_direction
var gravity_direction
var time_speed = 1
var teleport_time_speed = 1
var tele_active = true
var teleportation_power = true
var player_position = Vector2()
var hit_once = false


func _ready():
	global.script_player_bullet = self
	set_local_variables()

func set_local_variables():
	player_position = global.player_position
	player_direction = global.player_direction
	gravity_direction = global.gravity_direction
	rotation_degrees = global.player_gun_angle*player_direction*gravity_direction

func _process(delta):
	update_local_variables()
	update_global_variables()
	check_for_teleportation()

func update_local_variables():
	time_speed = global.time_speed
	teleport_time_speed = global.teleport_time_speed

func update_global_variables():
	if tele_active:
		global.last_bullet_position = $"Sprite".global_position
	global.teleportation_power = teleportation_power

func _physics_process(delta):
	$"Sprite".position.x += bullet_speed*delta*player_direction*time_speed*teleport_time_speed

func shot():
	$"Sprite/TelepositionNode".queue_free()
	tele_active = false

func destroy():
	teleportation_power = false
	global.teleportation_power = false
	tele_active = false
	queue_free()

func check_for_teleportation():
	 pass

func _on_VisibilityNotifier2D_screen_exited():
	destroy()

func _on_Area2D_area_entered(area):
	if not hit_once:
		hit_once = true
		area.get_parent().hit_by_player_bullet()
	destroy()


func _on_Area2D_body_entered(body):
	destroy()
