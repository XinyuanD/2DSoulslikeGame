extends Node2D
var spirit_amt: int = 0

func _on_area_2d_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if body.name == "Player":
		body.update_spirit(spirit_amt)
		queue_free()

func update_spirit_amt(amt: int):
	spirit_amt = amt
	print("spirit amount updated!")
