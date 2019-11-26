extends KinematicBody2D

var set_first_checkpoint = false

var jump_speed = 1200
var move_speed = 500
var gravity = 75
var velocity = Vector2()
var direction = 1 #Positive direction means right 
var floor_direction = Vector2(0, -1)
var health = 5
var vulnerable = true
var playing_running = false
var playing_standing = false
var playing_jumping = false
var playing_jumping_reverse = false

var fall = false

#mana costs and values
var mana = 100
var mana_restore = 10
var mana_bullet_cost = 3
var mana_teleport_cost = 7
var mana_reverse_gravity_cost = 9
var mana_time_freeze_cost = 20

#Active moves:
var teleportation_power = false
var teleported = false
var last_bullet_position = Vector2()
var gravity_power = true
var gravity_direction = 1 #Positive means gravity is pulling downward
var time_speed = 1 #Time ranges between 0 to 1
var teleport_time_speed = 1
var time_reload = true
var time_slowed = false

#Hands and shooting
var cur_rot = 0
var hand_rotation_speed = 100
var reloaded = true
onready var player_hand = $"BodyParts/RightForeArm"
onready var player_wrist = $"BodyParts/RightForeArm/RightWrist"


#Bullet Scene
onready var bullet_scene = preload("res://Levels/Level_0/Scenes/Player/PlayerBullet.tscn")

func _ready():
	global.script_player = self


func _process(delta):
	attacking()
	time_down(delta)
	teleportation_control()
	update_local_variables()
	update_global_variables()
	animation_control()
	after_acted_animation_control()
	update_mana(delta)


func _physics_process(delta):
	time_control()
	gravity_control()
	control_hands(delta)
	velocity_calculation()
	move_and_slide(velocity, floor_direction)

func velocity_calculation():
	moving()
	jumping()

func update_global_variables():
	global.player_direction = direction
	global.gravity_direction = gravity_direction
	global.player_gun_angle = cur_rot
	global.time_speed = time_speed
	global.player_position = global_position
	global.teleport_time_speed = teleport_time_speed
	global.player_health = health
	global.player_mana = mana

func update_local_variables():
	teleportation_power = global.teleportation_power
	last_bullet_position = global.last_bullet_position

func moving():
	velocity.x = 0
	if Input.is_action_pressed("A") :
		if direction == 1 :
			direction = -1
			scale.x *= -1
		velocity.x -= move_speed*teleport_time_speed
	if Input.is_action_pressed("D") :
		if direction == -1:
			direction = 1
			scale.x *= -1
		velocity.x += move_speed*teleport_time_speed

func jumping():
	if is_on_floor():
		velocity.y = 0
	if Input.is_action_just_pressed("W") or Input.is_action_just_pressed("S"):
		if is_on_floor():
			velocity.y = -1*jump_speed*gravity_direction*teleport_time_speed
	velocity.y += gravity*gravity_direction*teleport_time_speed*teleport_time_speed

func gravity_control():
	if gravity_power:
		if  ( Input.is_action_pressed("I") and Input.is_action_just_pressed("W") and gravity_direction==1 ) or ( Input.is_action_just_pressed("W") and not is_on_floor() ) :
			gravity_direction = -1
			scale.y = -1
			floor_direction.y = 1
			if direction==-1:
				scale.y *= -1
		if ( Input.is_action_pressed("I") and Input.is_action_pressed("S") or fall == true ) or ( Input.is_action_just_pressed("S") and not is_on_floor() ) :
			gravity_direction = 1
			scale.y = 1
			floor_direction.y = -1
			fall = false
			if direction==-1:
				scale.y *= -1
		if gravity_direction == -1:
			mana -= float(mana_reverse_gravity_cost)/50
		if mana <= 5:
			fall = true


func control_hands(delta):
	rotate_hands(delta)

func rotate_hands(delta):
	cur_rot = gravity_direction*direction*get_angle_to(get_global_mouse_position())*180/3.14
	player_hand.rotation_degrees = cur_rot
	if Input.is_action_pressed("U"):
		if cur_rot <= 0 and cur_rot > -75:
			cur_rot -= hand_rotation_speed*delta
			player_wrist.rotation_degrees -= hand_rotation_speed*delta
		elif cur_rot > 0 :
			cur_rot -= hand_rotation_speed*delta
			player_hand.rotation_degrees -= hand_rotation_speed*delta
	if Input.is_action_pressed("H"):
		if cur_rot < 75 and cur_rot >= 0:
			player_hand.rotation_degrees += hand_rotation_speed*delta
			cur_rot += hand_rotation_speed*delta
		if cur_rot < 0:
			player_wrist.rotation_degrees += hand_rotation_speed*delta
			cur_rot += hand_rotation_speed*delta

func attacking():
	if Input.is_action_pressed("K") or Input.is_mouse_button_pressed(1) :
		if reloaded and mana > mana_bullet_cost:
			mana -= mana_bullet_cost
			shoot()
			$"BodyParts/RightForeArm/RightWrist/RightPalm/Gun/ShootTimer".start()
			reloaded = false

func shoot():
	$"AudioShot".play()
	global.script_camera.shake(0.2,20, 12)
	var bullet = bullet_scene.instance()
	get_parent().add_child(bullet)
	bullet.z_index = -2
	bullet.global_position = get_node("BodyParts/RightForeArm/RightWrist/RightPalm/Gun").get_global_position()

func _on_ShootTimer_timeout():
	reloaded = true

func time_control():
	if Input.is_action_just_pressed("P") or Input.is_action_just_pressed('wheel_up') and time_slowed:
		if time_slowed == true:
			time_speed = 1
			time_reload = true
			play_untime()
			time_slowed = false
	if time_reload==true and mana > mana_time_freeze_cost:
		if Input.is_action_just_pressed("O") or Input.is_action_just_released('wheel_up') or Input.is_action_just_pressed('wheel_down') and not time_slowed:
			if time_slowed == false:
				$"../TimeEffect".global_position = global_position
				$"../TimeEffect/AnimationPlayer".play("FreezeTime")
				mana -= mana_time_freeze_cost
				time_reload = false
				time_slowed = true
				time_speed = 0

func time_down(delta):
	if time_speed >= 1 and time_slowed == true:
		time_slowed = false
		time_speed = 1
		time_reload = true
		play_untime()
	if time_slowed == true:
		if time_speed < 1:
			time_speed += pow(delta, 2.5)

func _on_TimeTimer_timeout():
	time_reload = true

func teleportation_control():
	if Input.is_action_just_pressed("J") or Input.is_mouse_button_pressed(2):
		if teleportation_power == true and not teleported and mana > mana_teleport_cost:
			mana -= mana_teleport_cost
			teleport()

func teleport():
	$"AudioTeleport".play()
	$"TimerAudioTeleport".start()
	$"../TeleportationRemains/AnimatedSprite".global_position = global_position
	$"../TeleportationRemains/AnimatedSprite".visible = true
	$"../TeleportationRemains/AnimatedSprite".frame = 0
	$"../TeleportationRemains/AnimatedSprite".play()
	global_position = last_bullet_position
	$"BodyParts/TeleDischarge".visible = true
	$"BodyParts/TeleDischarge".frame = 0
	$"BodyParts/TeleDischarge".play()
	teleported = true
	teleport_time_speed = 0.1
	$"TeleportTimeTimer".start()

func _on_TeleportTimeTimer_timeout():
	teleported = false
	teleport_time_speed = 1

func player_hit(damage):
	if vulnerable:
		health -= damage
		vulnerable = false
		$"VulnerableTimer".start()
		$"HitAnimationPlayer".play("HitFlickering")
		global.script_level_1.player_hit()
	if health <= 0:
		destroy()

func destroy():
	$"AudioSave".play()
	global.script_level_1.respawn()

func _on_VulnerableTimer_timeout():
	vulnerable = true
	$"HitAnimationPlayer".stop()

func animation_control():
	$"BodyAnimationPlayer".playback_speed = teleport_time_speed
	if is_on_floor():
		if velocity.x == 0:
			if not playing_standing:
				$"BodyAnimationPlayer".play("Standing")
				playing_standing = true
				playing_jumping = false
				playing_jumping_reverse =false
				playing_running = false
		elif velocity.x != 0:
			$"BodyAnimationPlayer".play("Running")
			playing_running = true
			playing_jumping = false
			playing_jumping_reverse =false
			playing_standing = false
	if not is_on_floor():
		if gravity_direction == 1:
			if velocity.y < 0:
				if not playing_jumping:
					$"BodyAnimationPlayer".play_backwards("JumpingUp")
					playing_jumping = true
					playing_running = false
					playing_jumping_reverse =false
					playing_standing = false
			elif velocity.y > 0:
				if not playing_jumping_reverse:
					$"BodyAnimationPlayer".play("JumpingUp")
					playing_jumping_reverse = true
					playing_running = false
					playing_jumping =false
					playing_standing = false
		elif gravity_direction == -1:
			if velocity.y > 0:
				if not playing_jumping:
					$"BodyAnimationPlayer".play_backwards("JumpingUp")
					playing_jumping = true
					playing_running = false
					playing_jumping_reverse =false
					playing_standing = false
			elif velocity.y < 0:
				if not playing_jumping_reverse:
					$"BodyAnimationPlayer".play("JumpingUp")
					playing_jumping_reverse = true
					playing_running = false
					playing_jumping =false
					playing_standing = false

func toggle_other_animations():
	if playing_standing == true:
		playing_jumping = false
		playing_jumping_reverse =false
		playing_running = false
	if playing_running == true:
		playing_jumping = false
		playing_jumping_reverse =false
		playing_standing = false
	if playing_jumping == true:
		playing_running = false
		playing_jumping_reverse =false
		playing_standing = false
	if playing_jumping_reverse == true:
		playing_running = false
		playing_jumping =false
		playing_standing = false

func after_acted_animation_control():
	if $"../TeleportationRemains/AnimatedSprite".frame == 11:
		$"../TeleportationRemains/AnimatedSprite".visible = false
	if $"BodyParts/TeleDischarge".frame == 11:
		$"BodyParts/TeleDischarge".visible = false

func update_mana(delta):
	if mana < 100:
		mana += mana_restore*delta*time_speed*teleport_time_speed
	if mana < 0:
		mana = 0

func play_untime():
	$"../TimeEffect".global_position = global_position
	$"../TimeEffect/AnimationPlayer".play_backwards("FreezeTime")

func savepoint():
	$"AudioSave".play()
	health = 5
	mana = 100
	$"../TimeEffect".global_position = global_position
	$"../TimeEffect/AnimationPlayer".play("FreezeTime")

func respawn(last_checkpoint):
	global_position = last_checkpoint
	health = 5
	mana = 100
	if time_slowed == true:
		time_speed = 1
		time_slowed = false
		time_reload = true
	play_untime()

func stop_teleportation_sound():
	$"AudioTeleport".stop()

func _on_VisibilityNotifier2D_screen_exited():
	destroy()

func _on_Area2D_area_entered(area):
	if area.is_in_group("KillerArea"):
		destroy()

func enemy_destroyed():
	$"AudioEnemyHit".play()

func _on_TimerAudioTeleport_timeout():
	stop_teleportation_sound()
