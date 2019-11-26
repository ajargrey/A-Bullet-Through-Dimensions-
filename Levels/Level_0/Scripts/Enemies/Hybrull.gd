extends KinematicBody2D

var activated = false
var dash = false
var playing_moving = false
var playing_dashing = false
var health = 3
var net_time_speed = 1

func _ready():
	pass

func _process(delta):
	if not activated:
		return
	update_local_variables()
	update_variables()
	check_for_player()
	attacking()
	moving()

func update_local_variables():
	net_time_speed = global.teleport_time_speed*global.time_speed

func update_variables():
	$"AnimationTree/MoveAnimationPlayer".playback_speed = 1*net_time_speed

func check_for_player():
	if $"RayCast2D".is_colliding():
		if not playing_dashing:
			$"..".position.x = global_position.x
			position.x = 0
		dash = true

func attacking():
	if dash == false:
		return
	if not playing_dashing:
		$"AnimationTree/MoveAnimationPlayer".play("Dash")
		playing_dashing = true
		playing_moving = false

func moving():
	if dash == true:
		return
	if not playing_moving:
		$"AnimationTree/MoveAnimationPlayer".play("Moving")
		playing_moving = true
		playing_dashing = false

func dash_complete():
	dash = false
	$"..".position.x = global_position.x
	position.x = 0
	playing_dashing = false
	playing_moving = false
	$"AnimationTree/MoveAnimationPlayer".play("Moving")


func reached_end():
	$"..".position.x = global_position.x
	position.x = 0
	$"..".scale.x *= -1
	$"AnimationTree/MoveAnimationPlayer".play("Moving")

func hit_by_player_bullet():
	health -= 1
	if health <= 0:
		destroy()

func destroy():
	get_parent().queue_free()

func _on_Area2D_area_entered(area):
	if area.get_parent().is_in_group("Player"):
		area.get_parent().player_hit(1)
		dash_complete()


func _on_VisibilityNotifier2D_screen_entered():
	activated = true
