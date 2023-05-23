extends Node2D
var UI

# Called when the node enters the scene tree for the first time.
func _ready():
	UI = $CanvasLayer/UI

func _on_switch_scene_button_pressed():
	UI.visible = false
	SceneSwitcher.goto_scene("res://Scenes/Level 1.tscn")
