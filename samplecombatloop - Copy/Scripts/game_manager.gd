extends Node

@export var player_character : Character
@export var ai_character : Character
@export var slash : CombatAction
@export var heal : CombatAction


# are these correct?
@onready var player_health_text = $"HUD/Player Health"
@onready var ai_health_text = $"HUD/AI Health"

var current_character : Character

# add end of game upon true
var game_over : bool = false

func _ready():
	$"Character Creator".show()
	$HUD.hide()


func next_turn ():
	if game_over:
		if ($Player_Character.cur_health <= 0):
			print("You Lose! Game Over!")
		elif ($AI_Character.cur_health <= 0):
			print("You win!")
	# add game logic end
		
	if current_character != null:
		current_character.end_turn()
	
	if current_character == ai_character or current_character == null:
		current_character = player_character
	else:
		current_character = ai_character
		
	current_character.begin_turn()
	
	if current_character.is_player:
		$HUD.reveal_hud()
		# enable and set player ui
		
	else:
		# disable player ui
		$HUD.hide_hud()
		var wait_time = randf_range(0.5, 1.5)
		await get_tree().create_timer(wait_time).timeout
		
		var action_to_cast = ai_decide_combat_action()
		ai_character.cast_combat_action(action_to_cast, player_character)
		
		await get_tree().create_timer(0.5).timeout
		next_turn()

func end_combat ():
	$HUD.hide()
	if ($Player_Character.cur_health <= 0):
		print("You Lose!")
	elif ($AI_Character.cur_health <= 0):
		print("You win!")

func player_cast_combat_action (action : CombatAction):
	if player_character != current_character:
		return
	
	player_character.cast_combat_action(action, ai_character)
	# disable player ui
	await get_tree().create_timer(0.5).timeout
	next_turn()


func ai_decide_combat_action () -> CombatAction:
	return slash


func _on_slash_pressed() -> void:
	player_cast_combat_action(slash)


func _on_heal_pressed() -> void:
	player_cast_combat_action(heal)


func _on_start_game_pressed() -> void:
	# save player character stats and start combat
	# $Player_Character set bonuses
	$"Character Creator".hide()
	$HUD/Player_Health.text = str($Player_Character.cur_health) + " / " + str($Player_Character.max_health)
	$HUD/AI_Health.text = str($AI_Character.cur_health) + " / " + str($AI_Character.max_health)
	$HUD.show()
	next_turn()


func _on_player_character_health_change():
	$HUD/Player_Health.text = str($Player_Character.cur_health) + " / " + str($Player_Character.max_health)
	# print("player damage hud is being called")


func _on_ai_character_health_change() -> void:
	$HUD/AI_Health.text = str($AI_Character.cur_health) + " / " + str($AI_Character.max_health)
	

func _on_player_character_health_depleted() -> void:
	game_over = true
func _on_ai_character_health_depleted() -> void:
	game_over = true
