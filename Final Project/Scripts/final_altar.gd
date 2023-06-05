extends Altar

@onready var anim_player = $AnimationPlayer
var played: bool = false

func _process(delta):
	if !played:
		for body in area.get_overlapping_bodies():
			if body.name == "Player" and Input.is_action_just_pressed("set_checkpoint"):
				body.update_spirit(-body.spirits)
				anim_player.play("spirit_anim")
				await anim_player.animation_finished
				played = true
