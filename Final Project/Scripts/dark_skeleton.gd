extends Skeleton

func _ready():
	player = get_tree().get_root().find_child("Player", true, false)
	switch_to(State.WALK)
	health = 8
	detect_distance = 500
	idle_time = randf_range(3, 6)
	walk_time = randf_range(5, 8)

func hit(damage: int):
	if curstate != State.HIT and curstate != State.DYING and curstate != State.DEAD:
		#switch_to(State.HIT)
		health -= damage
		var knockbackdir: Vector2 = (self.position - player.position).normalized()
		move_and_collide(knockbackdir * player.enemy_knockback_force)

func _on_animated_sprite_2d_animation_finished():
	if curstate == State.ATTACK:
		attackArea.monitoring = false
		switch_to(State.IDLE)
	elif curstate == State.HIT:
		switch_to(State.IDLE)
	elif curstate == State.DYING:
		player.update_spirit(randi_range(30, 40))
		switch_to(State.DEAD)
