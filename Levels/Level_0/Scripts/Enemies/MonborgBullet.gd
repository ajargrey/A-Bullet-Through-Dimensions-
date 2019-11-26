extends Node2D

var activated = false
var bullet_speed = 1000
var velocity = Vector2()
var net_time_speed = 1

func _ready():
	pass

func _process(delta):
	if not activated:
		return
	update_local_variables()

func update_local_variables():
	net_time_speed = global.teleport_time_speed*global.time_speed

func _physics_process(delta):
	if not activated:
		return
	travel(delta)

func activate_bullet(facing_right, d_angle):
	if (not d_angle):
		return
	var r_angle = d_angle*3.14/180
	if not facing_right:
		scale.x *= -1
	$"Sprite".rotation_degrees = d_angle
	velocity.x = cos(r_angle)*bullet_speed
	velocity.y = sin(r_angle)*bullet_speed
	activated = true

func travel(delta):
	$"Sprite".position.x += velocity.x*delta*net_time_speed
	$"Sprite".position.y += velocity.y*delta*net_time_speed

func _on_Area2D_area_entered(area):
	if area.get_parent().is_in_group("Player"):
		area.get_parent().player_hit(1)
		destroy()

func destroy():
	queue_free()

func _on_Area2D_body_entered(body):
	destroy()
