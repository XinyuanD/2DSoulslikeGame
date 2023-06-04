extends Node2D
var UI
var player

# Called when the node enters the scene tree for the first time.
func _ready():
	UI = $CanvasLayer/UI
	player = $Player
	SceneSwitcher.current_scene = self

func _on_scene_switch_portal_switch_scene():
	UI.visible = false
	SceneSwitcher.goto_scene("res://Scenes/level 2.tscn")


func _on_player_player_died():
	UI.visible = false
	SceneSwitcher.reload_scene_on_death("res://Scenes/Level 1.tscn")


func _on_player_checkpoint_reached():
	SceneSwitcher.reset_scene_on_checkpoint("res://Scenes/Level 1.tscn")


