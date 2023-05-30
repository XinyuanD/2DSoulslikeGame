extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var swordArea: Area2D = $SwordArea
enum State {IDLE, MOVE, JUMP_UP, FALL, ROLL, ATTACK1, ATTACK2, ATTACK3, HIT, DYING, DEAD}
const CAN_ATTACK_STATES = [State.IDLE, State.MOVE, State.ATTACK1, State.ATTACK2, State.ATTACK3]
const ATTACK_STATES = [State.ATTACK1, State.ATTACK2, State.ATTACK3]
var curstate
var max_health: int = 30
var health: int = 30
var spirits: int = 0
var sword_dmg: int = 1
var spell_dmg: int = 2
var last_checkpoint: Vector2

signal spirit_updated
signal health_updated
signal player_died
signal checkpoint_reached

var can_move: bool = true

var heal_timer: float = 0.0
var heal_time_threshold: float = 1.0
var heal_cost: int = 30
var heal_amount: int = 20

var max_speed: float = 300.0
var acceleration: float = 30.0
var jump_velocity: float = -400.0
var has_double_jumped: bool = false
var double_jump_velocity = -300.0

var jump_buffer_time: int = 10 # 1/6 sec
var jump_buffer_counter: int = 0
var cayote_time: int = 40 # 2/3 sec
var cayote_counter: int = 0

var terminal_velocity: float = 500
var normal_gravity: int = 450
var fall_gravity: int = 980
var gravity: int

var is_attacking: bool = false
var is_chaining_attack: bool = false
var chain_attack_time: int = 90
var chain_attack_counter: int = 0

func _ready():
	curstate = State.IDLE
	gravity = normal_gravity
	swordArea.monitoring = false
	last_checkpoint = position

func switch_to(new_state: State):
	curstate = new_state
	
	if curstate == State.MOVE:
		animated_sprite.play("run")
	elif curstate == State.IDLE:
		animated_sprite.play("idle")
	elif curstate == State.JUMP_UP:
		animated_sprite.play("jump_up")
	elif curstate == State.ROLL:
		animated_sprite.play("roll")
	elif curstate == State.FALL:
		animated_sprite.play("fall")
	elif curstate == State.ATTACK1:
		animated_sprite.play("attack1")
	elif curstate == State.ATTACK2:
		animated_sprite.play("attack2")
	elif curstate == State.ATTACK3:
		animated_sprite.play("attack3")
	elif curstate == State.HIT:
		animated_sprite.play("hit")
	elif curstate == State.DYING:
		animated_sprite.play("die")
	elif curstate == State.DEAD:
		emit_signal("player_died")

func _physics_process(delta):
	# add gravity
	velocity.y += gravity * delta
	
	# handle horizontal movement
	var direction = Input.get_axis("move_left", "move_right")
	if direction > 0:
		velocity.x += acceleration
	elif direction < 0:
		velocity.x -= acceleration
	else:
		velocity.x = lerp(velocity.x, 0.0, 0.6)
	velocity.x = clamp(velocity.x, -max_speed, max_speed)
	
	# healing timer
	if Input.is_action_pressed("heal") and health < max_health:
		heal_timer += delta
	elif Input.is_action_just_released("heal"):
		heal_timer = 0
	
	# cayote time
	if is_on_floor():
		cayote_counter = cayote_time
	else:
		if cayote_counter > 0:
			cayote_counter -= 1
	
	# jump buffer
	#if Input.is_action_just_pressed("jump"):
	#	jump_buffer_counter = jump_buffer_time
	#if jump_buffer_counter > 0:
	#	jump_buffer_counter -= 1
	
	# variables
	var is_falling = velocity.y > 0.0 and not is_on_floor()
	#var is_jumping = jump_buffer_counter > 0 and cayote_counter > 0
	var is_jumping = Input.is_action_just_pressed("jump") and cayote_counter > 0
	var is_double_jumping = Input.is_action_just_pressed("jump") and is_falling
	var is_jump_cancelled = Input.is_action_just_released("jump") and velocity.y < 0.0
	var is_idling = is_on_floor() and is_zero_approx(velocity.x)
	var is_running = is_on_floor() and not is_zero_approx(velocity.x)
	var is_healing = Input.is_action_pressed("heal") and is_on_floor() and spirits >= heal_cost and health < max_health
	
	# handles attack
	var attack_initiated = Input.is_action_just_pressed("attack")
	is_attacking = attack_initiated or curstate in ATTACK_STATES
	if Input.is_action_just_released("attack"):
		chain_attack_counter = chain_attack_time
	if chain_attack_counter > 0:
		chain_attack_counter -= 1
	
	if attack_initiated and chain_attack_counter > 0:
		is_chaining_attack = true
		chain_attack_counter = 0
	
	if !can_move:
		velocity.x = 0
		direction = 0
		switch_to(State.IDLE)
	elif curstate == State.DEAD or curstate == State.HIT:
		velocity.x = 0
		direction = 0
	elif health <= 0:
		velocity.x = 0
		direction = 0
		switch_to(State.DYING)
	#elif curstate == State.HIT:
	#	velocity.x = 0
	#	direction = 0
	elif is_healing:
		velocity.x = 0
		direction = 0
		switch_to(State.IDLE)
		
		if heal_timer > heal_time_threshold:
			update_spirit(-heal_cost)
			update_health(heal_amount)
			heal_timer = 0.0
	elif is_attacking and curstate in CAN_ATTACK_STATES:
		
		velocity.x = 0
		direction = 0
		if curstate not in ATTACK_STATES:
			is_chaining_attack = false
			switch_to(State.ATTACK1)
		
		# handles sword hitboxes
		if animated_sprite.animation == "attack1":
			if animated_sprite.frame >= 2:
				swordArea.monitoring = true
		elif animated_sprite.animation == "attack2":
			if animated_sprite.frame >= 3:
				swordArea.monitoring = true
		elif animated_sprite.animation == "attack3":
			if animated_sprite.frame >= 2:
				swordArea.monitoring = true
	
	elif is_jumping:
		
		velocity.y = jump_velocity
		switch_to(State.JUMP_UP)
		
	elif is_double_jumping and not has_double_jumped:
		
		gravity = normal_gravity
		velocity.y = double_jump_velocity
		has_double_jumped = true
		switch_to(State.JUMP_UP)
		
	elif is_falling:
		
		gravity = fall_gravity
		if velocity.y > 350.0:
			switch_to(State.FALL)
		else:
			switch_to(State.ROLL)
		
	elif is_jump_cancelled:
		velocity.y *= 0.2
		
	elif is_idling or is_running:
		
		gravity = normal_gravity
		has_double_jumped = false
		
		if is_running:
			switch_to(State.MOVE)
		elif is_idling:
			switch_to(State.IDLE)
	
	# clamp max fall speed
	if (velocity.y > terminal_velocity):
		velocity.y = terminal_velocity
	
	# handles sprite direction
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
	
	move_and_slide()
	#print(State.find_key(curstate))
	
	# reset jump buffer and cayote time
	if is_jumping:
		jump_buffer_counter = 0
		cayote_counter = 0

func hit(damage: int):
	if curstate != State.HIT and curstate != State.DYING and curstate != State.DEAD:
		switch_to(State.HIT)
		update_health(-damage)

func _on_animated_sprite_2d_animation_finished():
	if curstate == State.JUMP_UP:
		switch_to(State.ROLL)
	elif curstate in ATTACK_STATES:
		if is_chaining_attack:
			if curstate == State.ATTACK1:
				switch_to(State.ATTACK2)
			elif curstate == State.ATTACK2:
				switch_to(State.ATTACK3)
			elif curstate == State.ATTACK3:
				switch_to(State.IDLE)
			is_chaining_attack = false
		else:
			switch_to(State.IDLE)
		swordArea.monitoring = false
	elif curstate == State.HIT:
		switch_to(State.IDLE)
	elif curstate == State.DYING:
		switch_to(State.DEAD)

func _on_sword_area_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if curstate in ATTACK_STATES and body != self:
		var struck = false
		
		if animated_sprite.flip_h == false:
			if curstate == State.ATTACK1 and local_shape_index == 0:
				struck = true
			elif curstate == State.ATTACK2 and local_shape_index == 1:
				struck = true
			elif curstate == State.ATTACK3 and local_shape_index == 2:
				struck = true
		else:
			if curstate == State.ATTACK1 and local_shape_index == 3:
				struck = true
			elif curstate == State.ATTACK2 and local_shape_index == 4:
				struck = true
			elif curstate == State.ATTACK3 and local_shape_index == 5:
				struck = true
		
		if struck and body is Skeleton:
			body.hit(sword_dmg)

func update_health(num: int):
	health += num
	health = clampi(health, 0, max_health)
	emit_signal("health_updated")

func update_spirit(num: int):
	spirits += num
	emit_signal("spirit_updated")

func update_checkpoint():
	print("new checkpoint set!")
	last_checkpoint = position
	update_health(max_health)
	emit_signal("checkpoint_reached")




