extends Node

var player_position = Vector2()
var player_direction = 1
var gravity_direction = 1
var player_gun_angle = 0
var time_speed = 1
var teleport_time_speed = 1
var last_bullet_position = Vector2()
var teleportation_power = false
var player_health = 5
var player_mana = 100


var script_player_bullet
var script_camera
var script_level_1
var script_player