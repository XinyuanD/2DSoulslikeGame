class_name Skeleton extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attackArea: Area2D = $AttackArea
enum State {IDLE, WALK, ATTACK, HIT, DYING, DEAD}
var curstate
var state_time: float = 0.0
var dir = 1
var health: int = 3
var attack_dmg: int = 10

var idle_time: float = 0
var walk_time: float = 0
var walk_speed = 100
var chase_speed = 200
var gravity = 450

var player
var last_position: Vector2 = Vector2.ZERO
var detect_distance: float = 400
var player_detected: bool = false
var attack_range: float = 70
var in_attack_range: bool = false

func _ready():
	player = get_tree().get_root().find_child("Player", true, false)
	switch_to(State.WALK)
	idle_time = randf_range(3, 6)
	walk_time = randf_range(5, 8)

func switch_to(new_state: State):
	curstate = new_state
	state_time = 0.0
	
	if curstate == State.IDLE:
		animated_sprite.play("idle")
	elif curstate == State.WALK:
		animated_sprite.play("walk")
	elif curstate == State.ATTACK:
		animated_sprite.play("attack")
	elif curstate == State.HIT:
		animated_sprite.play("hit")
	elif curstate == State.DYING:
		animated_sprite.play("die")
	elif curstate == State.DEAD:
		queue_free()

func _physics_process(delta):
	velocity.y += gravity * delta
	
	var player_distance: Vector2 = player.position - position
	if player_distance.length() < detect_distance:
		player_detected = true
	else:
		#print("player NOT detected")
		player_detected = false
	
	if health <= 0:
		velocity.x = 0
		switch_to(State.DYING)
	elif curstate == State.HIT:
		velocity.x = 0
	elif player_detected:
		# chase & attack logic
		if player_distance.x > 0:
			dir = 1
		elif player_distance.x < 0:
			dir = -1
		
		if abs(player_distance.x) < attack_range:
			#print("player in attack range")
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
		# patrol logic
		state_time += delta
		if curstate == State.IDLE:
			velocity.x = 0
			if state_time > idle_time:
				switch_to(State.WALK)
				dir *= -1
				idle_time = randf_range(3, 6)
		elif curstate == State.WALK:
			velocity.x = dir * walk_speed
			var delta_x = abs(position.x - last_position.x)
			if (state_time > walk_time) or (state_time > 1.0 and delta_x < 0.01):
				switch_to(State.IDLE)
				walk_time = randf_range(5, 8)
	
	last_position = position
	move_and_slide()
	
	if dir == 1:
		animated_sprite.flip_h = false
	else:
		animated_sprite.flip_h = true

func hit(damage: int):
	if curstate != State.HIT and curstate != State.DYING and curstate != State.DEAD:
		switch_to(State.HIT)
		health -= damage

func _on_animated_sprite_2d_animation_finished():
	if curstate == State.ATTACK:
		attackArea.monitoring = false
		switch_to(State.IDLE)
	elif curstate == State.HIT:
		switch_to(State.IDLE)
	elif curstate == State.DYING:
		player.update_spirit(randi_range(15, 25))
		switch_to(State.DEAD)

func _on_attack_area_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if curstate == State.ATTACK and body != self:
		var struck = false
		
		if dir == 1 and local_shape_index == 0:
			struck = true
		elif dir == -1 and local_shape_index == 1:
			struck = true
		
		if struck and body.name == "Player":
			body.hit(attack_dmg)






