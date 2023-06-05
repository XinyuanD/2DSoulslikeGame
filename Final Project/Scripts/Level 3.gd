extends Node2D
var UI
var player
var barrier

# Called when the node enters the scene tree for the first time.
func _ready():
	UI = $CanvasLayer/UI
	player = $Player
	barrier = $StaticBody2D/CollisionShape2D

func _on_player_player_died():
	UI.visible = false
	SceneSwitcher.reload_scene_on_death("res://Scenes/level_3.tscn")
	

func _on_player_checkpoint_reached():
	SceneSwitcher.reset_scene_on_checkpoint("res://Scenes/level_3.tscn")	


func _on_boss_skeleton_is_dead():
	barrier.disabled = true


func _on_scene_switch_portal_switch_scene():
	UI.visible = false
	SceneSwitcher.finish_game()
