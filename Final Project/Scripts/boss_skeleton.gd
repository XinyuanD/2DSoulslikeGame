extends Skeleton

signal is_dead

func _ready():
	player = get_tree().get_root().find_child("Player", true, false)
	switch_to(State.WALK)
	health = 50
	attack_dmg = 25
	detect_distance = 1500
	attack_range = 500
	chase_speed = 400
	idle_time = randf_range(3, 6)
	walk_time = randf_range(5, 8)


func _physics_process(delta):
	velocity.y += gravity * delta
	
	var player_distance: float = player.position.x - position.x
	if abs(player_distance) < detect_distance:
		player_detected = true
	else:
		#print("player NOT detected")
		player_detected = false
	
	if !player.can_move:
		player_detected = false
	
	if health <= 0:
		velocity.x = 0
		switch_to(State.DYING)
	elif player_detected:
		# chase & attack logic
		if player_distance > 0:
			if player_distance > (attack_range - 200):
				dir = 1
			elif player_distance < (attack_range - 200):
				dir = -1
		else:
			if player_distance < (-attack_range + 200):
				dir = -1
			elif player_distance > (-attack_range + 200):
				dir = 1
		
		if player_distance > 0 and player_distance < attack_range and player_distance > attack_range - 200:
			#print("player in attack range")
			dir = 1
			in_attack_range = true
		elif player_distance < 0 and player_distance > -attack_range and player_distance < -attack_range + 200:
			dir = -1
			in_attack_range = true
		else:
			#print("player NOT in attack range")
			in_attack_range = false
		
		if in_attack_range or curstate == State.ATTACK:
			switch_to(State.ATTACK)
			velocity.x = 0
			
			if animated_sprite.animation == "attack":
				if animated_sprite.frame == 7:
					attackArea.monitoring = true
				else:
					attackArea.monitoring = false
		else:
			switch_to(State.WALK)
			velocity.x = chase_speed * dir
		
	else:
		switch_to(State.IDLE)
	
	
	last_position = position
	move_and_slide()
	
	if dir == 1:
		animated_sprite.flip_h = false
	else:
		animated_sprite.flip_h = true


func hit(damage: int):
	if curstate != State.DYING and curstate != State.DEAD:
		health -= damage
		player.update_spirit(5)


func _on_animated_sprite_2d_animation_finished():
	if curstate == State.ATTACK:
		attackArea.monitoring = false
		switch_to(State.IDLE)
	elif curstate == State.DYING:
		player.update_spirit(2000)
		emit_signal("is_dead")
		switch_to(State.DEAD)


