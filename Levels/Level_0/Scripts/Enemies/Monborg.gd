extends KinematicBody2D

var health = 5
var slowed_down = false
var net_time_speed = 1
var real_wait_time
var activated = false
var player_position = Vector2()
var facing_right = true
var gravity = 100
var angle 
var bullet_scene = preload("res://Levels/Level_0/Scenes/Enemies/MonborgBullet.tscn")

func _ready():
	real_wait_time = $"ShootTimer".wait_time
	$"../HitAnimationPlayer".play("Default")

func _process(delta):
	if not activated:
		return
	update_local_variables()
	decide_position()
	aim_at_player()
	control_timing()
	gravity_control(delta)

func update_local_variables():
	player_position = global.player_position
	net_time_speed = global.teleport_time_speed*global.time_speed

func decide_position():
	if player_position.x - global_position.x >= 0 :
		if facing_right == false:
			scale.x *= -1
			facing_right = true
	elif player_position.x - global_position.x < 0 :
		if facing_right == true:
			scale.x *= -1
			facing_right = false

func aim_at_player():
	if health <= 0:
		return
	if $"VisibilityNotifier2D".is_on_screen():
		angle = atan ( (player_position.y - global_position.y) /abs (player_position.x - global_position.x)  )*180/3.14
		$"BodySprites/Hand".rotation_degrees = angle

func _on_VisibilityNotifier2D_screen_entered():
	activated = true

func shoot():
	if health <= 0:
		return
	var bullet = bullet_scene.instance()
	get_parent().add_child(bullet)
	bullet.global_position = $"BodySprites/Hand/Gun".global_position
	bullet.activate_bullet(facing_right, angle)

func _on_ShootTimer_timeout():
	if health <= 0:
		return
	$"ShootTimer".wait_time = float(real_wait_time)/net_time_speed
	if activated:
		if $"VisibilityNotifier2D".is_on_screen():
			$"ShootTimer".start()
			shoot()

func control_timing():
	if net_time_speed < 1:
		slowed_down = true
	if slowed_down:
		if net_time_speed >= 1:
			$"ShootTimer".wait_time = float(real_wait_time)/net_time_speed
			$"ShootTimer".start()
			slowed_down = false

func hit_by_player_bullet():
	health -= 1
	$"../HitAnimationPlayer".play("HitRedFlash")
	if health <= 0:
		destroy()

func destroy():
	$"../HitAnimationPlayer2".play("Wham")
	global.script_player.enemy_destroyed()

func gravity_control(delta):
	pass

func destroy_animation_mid():
	global.script_camera.shake(0.4,10, 16)
	queue_free()