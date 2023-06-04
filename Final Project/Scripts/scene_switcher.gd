extends CanvasLayer

var current_scene = null
var fade_anim
var death_anim

func _ready():
	var root = get_tree().root
	current_scene = root.get_child(root.get_child_count() - 1)
	fade_anim = $FadeAnimationPlayer
	death_anim = $DeathAnimationPlayer

# citation
# https://docs.godotengine.org/en/stable/tutorials/scripting/singletons_autoload.html#custom-scene-switcher

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
	var old_player = current_scene.find_child("Player")
	var player_max_health = old_player.max_health
	var player_health = old_player.health
	var player_spirits = old_player.spirits
	var player_sword_dmg = old_player.sword_dmg
	var player_spell_dmg = old_player.spell_dmg
	
	var old_UI = current_scene.find_child("UI")
	var health_levelup_count = old_UI.health_levelup_count
	var sword_dmg_levelup_count = old_UI.sword_dmg_levelup_count
	var spell_dmg_levelup_count = old_UI.spell_dmg_levelup_count
	# It is now safe to remove the current scene
	current_scene.free()

	# Load the new scene.
	var s = ResourceLoader.load(path)

	# Instance the new scene.
	current_scene = s.instantiate()
	
	var new_player = current_scene.find_child("Player")
	new_player.max_health = player_max_health
	new_player.health = player_health
	new_player.spirits = player_spirits
	new_player.sword_dmg = player_sword_dmg
	new_player.spell_dmg = player_spell_dmg
	
	var new_UI = current_scene.find_child("UI")
	new_UI.health_levelup_count = health_levelup_count
	new_UI.sword_dmg_levelup_count = sword_dmg_levelup_count
	new_UI.spell_dmg_levelup_count = spell_dmg_levelup_count
	new_UI.visible = false
	
	# Add it to the active scene, as child of root.
	get_tree().root.add_child(current_scene)

	# Optionally, to make it compatible with the SceneTree.change_scene_to_file() API.
	get_tree().current_scene = current_scene

func reload_scene_on_death(path):
	death_anim.play("death_screen_anim")
	await death_anim.animation_finished
	call_deferred("_deferred_reload_scene_on_death", path)
	fade_anim.play_backwards("fade")
	death_anim.play("RESET")
	await  fade_anim.animation_finished
	current_scene.find_child("UI").visible = true

func _deferred_reload_scene_on_death(path):
	var old_player = current_scene.find_child("Player")
	var player_max_health = old_player.max_health
	var player_spirits = old_player.spirits
	var player_sword_dmg = old_player.sword_dmg
	var player_spell_dmg = old_player.spell_dmg
	var last_checkpoint = old_player.last_checkpoint
	var death_position = old_player.position
	
	var old_UI = current_scene.find_child("UI")
	var health_levelup_count = old_UI.health_levelup_count
	var sword_dmg_levelup_count = old_UI.sword_dmg_levelup_count
	var spell_dmg_levelup_count = old_UI.spell_dmg_levelup_count
	
	current_scene.free()
	var s = ResourceLoader.load(path)
	current_scene = s.instantiate()
	
	var new_player = current_scene.find_child("Player")
	new_player.max_health = player_max_health
	new_player.health = player_max_health
	new_player.sword_dmg = player_sword_dmg
	new_player.spell_dmg = player_spell_dmg
	new_player.position = last_checkpoint
	
	var new_UI = current_scene.find_child("UI")
	new_UI.health_levelup_count = health_levelup_count
	new_UI.sword_dmg_levelup_count = sword_dmg_levelup_count
	new_UI.spell_dmg_levelup_count = spell_dmg_levelup_count
	new_UI.visible = false
	
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
	var old_player = current_scene.find_child("Player")
	var player_max_health = old_player.max_health
	var player_spirits = old_player.spirits
	var player_sword_dmg = old_player.sword_dmg
	var player_spell_dmg = old_player.spell_dmg
	var last_checkpoint = old_player.last_checkpoint
	
	var old_UI = current_scene.find_child("UI")
	var health_levelup_count = old_UI.health_levelup_count
	var sword_dmg_levelup_count = old_UI.sword_dmg_levelup_count
	var spell_dmg_levelup_count = old_UI.spell_dmg_levelup_count
	
	current_scene.free()
	var s = ResourceLoader.load(path)
	current_scene = s.instantiate()
	
	var new_player = current_scene.find_child("Player")
	new_player.max_health = player_max_health
	new_player.health = player_max_health
	new_player.spirits = player_spirits
	new_player.sword_dmg = player_sword_dmg
	new_player.spell_dmg = player_spell_dmg
	new_player.position = last_checkpoint
	
	var new_UI = current_scene.find_child("UI")
	new_UI.health_levelup_count = health_levelup_count
	new_UI.sword_dmg_levelup_count = sword_dmg_levelup_count
	new_UI.spell_dmg_levelup_count = spell_dmg_levelup_count
	
	get_tree().root.add_child(current_scene)
	get_tree().current_scene = current_scene
	
	new_UI.show_levelup_display()




