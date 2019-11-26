extends Sprite

func _ready():
	pass


func _on_Area2D_body_entered(body):
	destroy()

func destroy():
	queue_free()