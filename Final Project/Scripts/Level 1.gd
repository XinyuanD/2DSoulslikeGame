extends Node2D
var UI
var player

# Called when the node enters the scene tree for the first time.
func _ready():
	UI = $CanvasLayer/UI
	player = $Player
	
func _on_switch_scene_button_pressed():
	UI.visible = false
	SceneSwitcher.goto_scene("res://Scenes/level 2.tscn")


func _on_player_player_died():
	UI.visible = false
	SceneSwitcher.reload_scene("res://Scenes/Level 1.tscn", player.last_checkpoint)
