extends CharacterBody2D

enum State {IDLE, MOVE, JUMP_UP, FALL, ROLL, ATTACK1, ATTACK2, ATTACK3}
var curstate

var max_speed: float = 300.0
var acceleration: float = 30.0
var jump_velocity: float = -400.0
var has_double_jumped: bool = false
var double_jump_velocity = -300.0
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var terminal_velocity: float = 500
var normal_gravity: int = 450
var fall_gravity: int = 980
var gravity: int

func _ready():
	curstate = State.IDLE
	gravity = normal_gravity

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

func _physics_process(delta):
	var direction = Input.get_axis("move_left", "move_right")
	if direction > 0:
		velocity.x += acceleration
	elif direction < 0:
		velocity.x -= acceleration
	else:
		velocity.x = lerp(velocity.x, 0.0, 0.6)
	velocity.x = clamp(velocity.x, -max_speed, max_speed)
	
	velocity.y += gravity * delta
	
	var is_falling = velocity.y > 0.0 and not is_on_floor()
	var is_jumping = Input.is_action_just_pressed("jump") and is_on_floor()
	var is_double_jumping = Input.is_action_just_pressed("jump") and is_falling
	var is_jump_cancelled = Input.is_action_just_released("jump") and velocity.y < 0.0
	var is_idling = is_on_floor() and is_zero_approx(velocity.x)
	var is_running = is_on_floor() and not is_zero_approx(velocity.x)
	var can_play_double_jump_anim = false
	
	if is_jumping:
		velocity.y = jump_velocity
	elif is_double_jumping and not has_double_jumped:
		gravity = normal_gravity
		velocity.y = double_jump_velocity
		has_double_jumped = true
		can_play_double_jump_anim = true
	elif is_falling:
		gravity = fall_gravity
	elif is_jump_cancelled:
		velocity.y = 0.0
	elif is_idling or is_running:
		gravity = normal_gravity
		has_double_jumped = false
	
	if (velocity.y > terminal_velocity):
		velocity.y = terminal_velocity
	
	move_and_slide()
	
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
	
	if is_jumping:
		switch_to(State.JUMP_UP)
	elif is_double_jumping and can_play_double_jump_anim:
		switch_to(State.JUMP_UP)
	elif is_running:
		switch_to(State.MOVE)
	elif is_falling:
		if velocity.y > 350.0:
			switch_to(State.FALL)
		else:
			switch_to(State.ROLL)
	elif is_idling:
		switch_to(State.IDLE)


func _on_animated_sprite_2d_animation_finished():
	if curstate == State.JUMP_UP:
		switch_to(State.ROLL)
	pass
