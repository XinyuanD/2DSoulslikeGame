extends Control
var player

var healthbar
var spirit_count
var stats_display
var levelup_display
var health_button
var sword_dmg_button
var spell_dmg_button
var cancel_button

var health_max_levelup_count: int = 5
var weapon_dmg_max_levelup_count: int = 3
var health_levelup_count: int = 0
var sword_dmg_levelup_count: int = 0
var spell_dmg_levelup_count: int = 0

var health_levelup_cost: int = 200
var sword_dmg_levelup_cost: int = 250
var spell_dmg_levelup_cost: int = 270

var health_levelup_amt: int = 20
var sword_dmg_levelup_amt: int = 1
var spell_dmg_levelup_amt: int = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_tree().get_root().find_child("Player", true, false)
	healthbar = $StatsDisplay/HealthBar
	spirit_count = $StatsDisplay/SpiritCount
	stats_display = $StatsDisplay
	levelup_display = $LevelUpDisplay
	health_button = $LevelUpDisplay/VBoxContainer/HealthButton
	sword_dmg_button = $LevelUpDisplay/VBoxContainer/SwordDamageButton
	spell_dmg_button = $LevelUpDisplay/VBoxContainer/SpellDamageButton
	cancel_button = $LevelUpDisplay/VBoxContainer/CancelButton
	healthbar.max_value = player.max_health
	
	health_button.text = "Health +" + str(health_levelup_amt) + "\nCost: " + str(health_levelup_cost) + " spirits"
	sword_dmg_button.text = "Sword Damage +" + str(sword_dmg_levelup_amt) + "\nCost: " + str(sword_dmg_levelup_cost) + " spirits"
	spell_dmg_button.text = "Spell Damage +" + str(spell_dmg_levelup_amt) + "\nCost: " + str(spell_dmg_levelup_cost) + " spirits"
	
	stats_display.visible = true
	levelup_display.visible = false
	health_button.disabled = true
	sword_dmg_button.disabled = true
	spell_dmg_button.disabled = true
	cancel_button.disabled = true
	
	_on_player_health_updated()
	_on_player_spirit_updated()

func _on_player_health_updated():
	healthbar.value = player.health

func _on_player_spirit_updated():
	spirit_count.text = str(player.spirits)
	
func show_levelup_display():
	stats_display.visible = false
	levelup_display.visible = true
	player.can_move = false
	
	if health_levelup_count < health_max_levelup_count and player.spirits >= health_levelup_cost:
		health_button.disabled = false
	if sword_dmg_levelup_count < weapon_dmg_max_levelup_count and player.spirits >= sword_dmg_levelup_cost:
		sword_dmg_button.disabled = false
	if spell_dmg_levelup_count < weapon_dmg_max_levelup_count and player.spirits >= spell_dmg_levelup_cost:
		spell_dmg_button.disabled = false
	cancel_button.disabled = false

func _on_cancel_button_pressed():
	player.can_move = true
	stats_display.visible = true
	levelup_display.visible = false
	health_button.disabled = true
	sword_dmg_button.disabled = true
	spell_dmg_button.disabled = true
	cancel_button.disabled = true

func _on_health_button_pressed():
	health_levelup_count += 1
	player.max_health += health_levelup_amt
	healthbar.max_value = player.max_health
	player.update_health(player.max_health)
	player.update_spirit(-health_levelup_cost)
	print("Player Health: " + str(player.health))
	if health_levelup_count >= health_max_levelup_count or player.spirits < health_levelup_cost:
		health_button.disabled = true

func _on_sword_damage_button_pressed():
	sword_dmg_levelup_count += 1
	player.sword_dmg += sword_dmg_levelup_amt
	player.update_spirit(-sword_dmg_levelup_cost)
	print("Player Sword Dmg: " + str(player.sword_dmg))
	if sword_dmg_levelup_count >= weapon_dmg_max_levelup_count or player.spirits < sword_dmg_levelup_cost:
		sword_dmg_button.disabled = true

func _on_spell_damage_button_pressed():
	spell_dmg_levelup_count += 1
	player.spell_dmg += spell_dmg_levelup_amt
	player.update_spirit(-spell_dmg_levelup_cost)
	print("Player Spell Dmg: " + str(player.spell_dmg))
	if spell_dmg_levelup_count >= weapon_dmg_max_levelup_count or player.spirits < spell_dmg_levelup_cost:
		spell_dmg_button.disabled = true




