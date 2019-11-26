extends Node2D

var player_health = 5
var player_mana = 100
var net_time_speed = 1
var first_checkpoint_set = false
var last_checkpoint = Vector2()
var current_position = Vector2()
var progress = 0
var easy_completed = false
var hint 
var hint_toggle = false


func _ready():
	global.script_level_1 = self
	hint = $"CanvasLayer2/Hints/RichTextLabel"

func _process(delta):
	if not first_checkpoint_set:
		set_last_checkpoint_in_beginning(global.player_position)
	update_local_variables()
	manage_bar()
	manage_puzzle5()
	check_respawn_requests()
	update_scoreboard()
	hint_control()

func update_local_variables():
	player_health = global.player_health
	player_mana = global.player_mana
	net_time_speed = global.time_speed*global.teleport_time_speed
	current_position = global.player_position
	if progress > 100:
		easy_completed = true
	if not easy_completed:
		progress = int(float(current_position.x)/($"OrbNode2/Area2D/Sprite".global_position.x)*100)
	else:
		progress = int(float(current_position.x)/($"OrbNode/Area2D/Sprite".global_position.x)*100)

func manage_bar():
	if player_health >= 0:
		$"CanvasLayer/Bar/HealthBar".scale.x = float(player_health)/5
	if player_mana >= 0:
		$"CanvasLayer/Bar/ManaBar".scale.x = float(player_mana)/100

func player_hit():
	$"CanvasLayer/Bar/BarAnimationPlayer".play("PlayerHit")

func manage_puzzle5():
	$"WallPuzzles/Type5Puzzles/Puzzle1/AnimationPlayer".playback_speed = 0.9*net_time_speed
	$"WallPuzzles/Type5Puzzles/Puzzle2/AnimationPlayer".playback_speed = 0.9*net_time_speed
	$"WallPuzzles/Type5Puzzles/Puzzle3/AnimationPlayer".playback_speed = 0.9*net_time_speed


func _on_Area2D_body_entered(body):
	if body.is_in_group("Player"):
		savepoint()

func savepoint():
	global.script_player.savepoint()
	last_checkpoint = global.player_position

func check_respawn_requests():
	if Input.is_action_just_released("T"):
		respawn()

func respawn():
	global.script_player.respawn(last_checkpoint)
	$"Interactables/RockCover/Rock".reset()

func set_last_checkpoint_in_beginning(player_position):
	if player_position:
		last_checkpoint = player_position
		first_checkpoint_set = true

func update_scoreboard():
	$"CanvasLayer2/Node2D/RichTextLabel".text = str(progress) + " % completed"

func hint_control():
	if hint_toggle == true:
		if Input.is_action_pressed("?"):
			$"CanvasLayer2/Hints/RichTextLabel".visible = true
		else:
			$"CanvasLayer2/Hints/RichTextLabel".visible = false
	else:
		$"CanvasLayer2/Hints/RichTextLabel".visible = true
	if not easy_completed and progress > 58 and progress < 98:
		hint_toggle = true
	else:
		hint_toggle = false
	if progress == 0:
		hint.text = "Press A and D to move"
	if progress ==3:
			hint.text = "Press W to Jump"
	if progress ==6:
			hint.text = "These Gems are checkpoints and restore your health and mana"
	if progress ==8:
		hint.text = "Press Left Mouse Button to shoot"
	if progress ==9:
		hint.text = "Mana is used for nearly every power you use"
	if progress ==10:
		hint.text = "If you f**k up while playing, press T to restore game to last checkpoint"
	if progress ==16:
		hint.text = "Shoot a bullet and press Right Mouse Button to teleport at its location... If you face difficulty, pass your arm through the gap"
	if progress ==19:
		hint.text = "Double press W or S to revert gravity"
	if progress ==25:
		hint.text = "Controls remain same during reverse gravity, you can still jumo, change gun direction etc"
	if progress ==27:
		hint.text = "Remember double press S or W to revert gravity"
	if progress ==30:
		hint.text = "Be careful that there is surface before you revert gravity, else use teleportation"
	if progress ==31:
		hint.text = "You can press O to stop/slow down time for a short time :P"
	if progress ==34:
		hint.text = "Press P to restore time, else your time and mana will drain away too quickly"
	if progress ==35:
		hint.text = "There is a cyborg ape ahead, he shoots, be sure to constantly change your place, teleport and shoot mid air, revert gravity etc in battle"
	if progress ==39:
		hint.text = "Activate reverse gravity, and teleport through the hole"
	if progress ==41:
		hint.text = "Show me what you have got... PS: teleporting and shooting in mid air is the coolest thing ever"
	if progress ==55:
		hint.text = "Try finding correct angle, or jumping or teleporting, and then teleporting, anything can come in handy"
	if progress ==57:
		hint.text = "That's all, now you are at your own, remember to use every power you own... However, if you still need hints in future just press ? "
	if progress ==59:
		hint.text = "Try slowing down time and shoot at correct moment and then... teleport, duh"
	if progress ==62:
		hint.text = "Just run, teleport, revert gravity, freeze time and gun"
	if progress ==84:
		hint.text = "Shoot stone to propel it in air, shoot it in mid air again to blast it, slow down time and teleport over the rock pieces to reach the other end"
	if progress ==91:
		hint.text = "Just go on"
	if progress ==98:
		hint_toggle = false
		$"CanvasLayer2/Hints/RichTextLabel".visible = true
		hint.text = "You have obtained the orb, that will restore balnce of the universe"
	if progress ==99:
		hint.text = "However, if you plan to mingle with dangers, there is a more powerful red orb ahead"
	if progress > 100:
		easy_completed = true
		hint.text = ""
	if easy_completed and progress > 97 and progress <= 100:
		hint.text = "Thanks for playing. A game by team iotabang i.e Ajay and Vikas"































