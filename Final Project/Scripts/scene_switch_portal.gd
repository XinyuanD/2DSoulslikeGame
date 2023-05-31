extends Node2D

signal switch_scene

func _on_area_2d_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if body.name == "Player":
		emit_signal("switch_scene")
