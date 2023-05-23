extends Control
var player
var healthbar
var spirit_count

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_tree().get_root().find_child("Player", true, false)
	healthbar = $HealthBar
	spirit_count = $SpiritCount
	healthbar.max_value = player.max_health
	_on_player_health_updated()
	_on_player_spirit_updated()

func _on_player_health_updated():
	healthbar.value = player.health

func _on_player_spirit_updated():
	#var tween = create_tween()
	#tween.tween_property(spirit_count, "text", str(player.spirits), 0.5)
	spirit_count.text = str(player.spirits)
