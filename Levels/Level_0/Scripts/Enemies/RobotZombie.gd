extends KinematicBody2D

var activated = false
var player_position = Vector2()
var speed
var velocity = Vector2()
var net_time_speed
var walking = false
var facing_right = true
var playing_walking = false
var playing_standing = false
var resting = false
var gravity = 100
var health = 2
var cur_playback_speed = 1

func _ready():
	speed = rand_range(50, 400)
	cur_playback_speed = float($"AnimationPlayer".playback_speed*speed)/200
	$"HitAnimationPlayer".play("Default")

func _process(delta):
	if not activated:
		return
	update_local_variables()
	manage_velocity(delta)
	move_and_slide(velocity)
	animation_control()
	collision_control()
	gravity_control(delta)

func update_local_variables():
	player_position = global.player_position
	net_time_speed = global.teleport_time_speed*global.time_speed

func update_variables():
	pass

func _on_Area2D_area_entered(area):
	if area.get_parent().is_in_group("Player"):
		area.get_parent().player_hit(1)

func manage_velocity(delta):
	velocity.x = 0
	if walking == true:
		if player_position.x - global_position.x > 20:
			if not facing_right:
				scale.x *= -1
				facing_right = true
			velocity.x += speed*net_time_speed
		elif player_position.x - global_position.x < -20:
			if facing_right:
				scale.x *= -1
				facing_right = false
			velocity.x -= speed*net_time_speed

func destroy():
	global.script_player.enemy_destroyed()
	$"Area2D".queue_free()
	$"../Sprite".global_position = global_position
	$"../ComicAnimationPlayer".play("Bam")

func _on_WalkTimer_timeout():
	if walking == true:
		$"WalkTimer".wait_time = 0.25
		resting = true
	else:
		$"WalkTimer".wait_time = 1
		resting = false
	walking = !walking
	$"WalkTimer".start()

func _on_VisibilityNotifier2D_screen_entered():
	$WalkTimer.wait_time = rand_range(0,3)
	walking = true
	$"WalkTimer".start()
	activated = true

func hit_by_player_bullet():
	health -= 1
	$"HitAnimationPlayer".play("HitRedFlash")
	if health <= 0:
		destroy()

func animation_control():
	$"AnimationPlayer".playback_speed = 1*net_time_speed
	if velocity.x != 0:
		if not playing_walking:
			$"AnimationPlayer".play("Walking")
			playing_walking = true
			playing_standing = false
	elif velocity.x == 0 and not resting:
		if not playing_standing:
			$"AnimationPlayer".play("Standing")
			playing_standing = true
			playing_walking = false

func collision_control():
	if $"RayCast2D".is_colliding():
		velocity.x = 0
		resting = false

func gravity_control(delta):
	velocity.y += gravity*delta

func destroy_animation_mid():
	global.script_camera.shake(0.4,10, 16)
	queue_free()






