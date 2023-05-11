extends CharacterBody2D

enum State {IDLE, WALK, ATTACK, HIT, DYING, DEAD}
var curstate = State.IDLE
var state_time: float = 0.0
var dir = 1
var idle_time: float = 0
var walk_time: float = 0

@onready var animated_sprite = $AnimatedSprite2D
var speed = 100
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

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
	state_time += delta
	velocity.y += gravity * delta
	
	if curstate == State.IDLE and state_time > idle_time:
		switch_to(State.WALK)
		# set idle time to random
	
	
	
	
	





