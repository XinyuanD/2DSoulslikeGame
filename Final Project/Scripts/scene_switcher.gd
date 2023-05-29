extends CanvasLayer

var current_scene = null
var fade_anim
var death_anim

func _ready():
	var root = get_tree().root
	current_scene = root.get_child(root.get_child_count() - 1)
	fade_anim = $FadeAnimationPlayer
	death_anim = $DeathAnimationPlayer

func goto_scene(path):
	# This function will usually be called from a signal callback,
	# or some other function in the current scene.
	# Deleting the current scene at this point is
	# a bad idea, because it may still be executing code.
	# This will result in a crash or unexpected behavior.

	# The solution is to defer the load to a later time, when
	# we can be sure that no code from the current scene is running:
	fade_anim.play("fade")
	await fade_anim.animation_finished
	call_deferred("_deferred_goto_scene", path)
	fade_anim.play_backwards("fade")
	await  fade_anim.animation_finished
	current_scene.find_child("UI").visible = true


func _deferred_goto_scene(path):
	var player_health = current_scene.find_child("Player").health
	var player_spirits = current_scene.find_child("Player").spirits
	
	# It is now safe to remove the current scene
	current_scene.free()

	# Load the new scene.
	var s = ResourceLoader.load(path)

	# Instance the new scene.
	current_scene = s.instantiate()
	current_scene.find_child("Player").health = player_health
	current_scene.find_child("Player").spirits = player_spirits
	current_scene.find_child("UI").visible = false
	# Add it to the active scene, as child of root.
	get_tree().root.add_child(current_scene)

	# Optionally, to make it compatible with the SceneTree.change_scene_to_file() API.
	get_tree().current_scene = current_scene

func reload_scene(path):
	death_anim.play("death_screen_anim")
	await death_anim.animation_finished
	call_deferred("_deferred_reload_scene", path)
	fade_anim.play_backwards("fade")
	death_anim.play("RESET")
	await  fade_anim.animation_finished
	current_scene.find_child("UI").visible = true

func _deferred_reload_scene(path):
	var last_checkpoint = current_scene.find_child("Player").last_checkpoint
	var death_position = current_scene.find_child("Player").position
	var player_spirits = current_scene.find_child("Player").spirits
	
	current_scene.free()
	var s = ResourceLoader.load(path)
	current_scene = s.instantiate()
	
	current_scene.find_child("Player").position = last_checkpoint
	current_scene.find_child("UI").visible = false
	
	get_tree().root.add_child(current_scene)
	get_tree().current_scene = current_scene
	
	if player_spirits > 0:
		var scene = load("res://Scenes/spirit_drop.tscn")
		var spirit_drop = scene.instantiate()
		spirit_drop.position = death_position
		print(player_spirits)
		spirit_drop.update_spirit_amt(player_spirits)
		current_scene.add_child(spirit_drop)
	
	
func reset_scene_on_checkpoint(path):
	call_deferred("_deferred_reset_scene_on_checkpoint", path)

func _deferred_reset_scene_on_checkpoint(path):
	var player_spirits = current_scene.find_child("Player").spirits
	var last_checkpoint = current_scene.find_child("Player").last_checkpoint
	
	current_scene.free()
	var s = ResourceLoader.load(path)
	current_scene = s.instantiate()
	
	current_scene.find_child("Player").spirits = player_spirits
	current_scene.find_child("Player").position = last_checkpoint
	
	get_tree().root.add_child(current_scene)
	get_tree().current_scene = current_scene
