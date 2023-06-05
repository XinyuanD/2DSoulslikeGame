class_name Altar extends Node2D
@onready var area: Area2D = $Area2D

func _process(delta):
	for body in area.get_overlapping_bodies():
		if body.name == "Player" and Input.is_action_just_pressed("set_checkpoint"):
			if body.can_move:
				body.update_checkpoint()


