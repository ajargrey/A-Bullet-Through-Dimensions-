extends Node2D

var rock_boosted = false
var rock_blasted = false
var net_time_speed = 1

func _ready():
	pass

func _process(delta):
	update_local_variables()
	animation_control()

func update_local_variables():
	net_time_speed = global.time_speed*global.teleport_time_speed

func animation_control():
	$"AnimationPlayer".playback_speed = net_time_speed*1

func hit_by_player_bullet():
	if not rock_boosted:
		$"AnimationPlayer".play("BoostUp")
	if rock_boosted and not rock_blasted:
		$"AnimationPlayer".play("Blast")
		rock_blasted = true

func rock_in_mid_air():
	rock_boosted = true

func rock_on_ground():
	rock_boosted = false

func reset():
	$"AnimationPlayer".play("Default")
	rock_boosted = false
	rock_blasted = false