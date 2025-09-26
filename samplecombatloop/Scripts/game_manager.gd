extends Node

@export var player_character : Character
@export var ai_character : Character
@export var slash : CombatAction
@export var heal : CombatAction

var current_character : Character


var game_over : bool = false

func _ready():
	next_turn()


func next_turn ():
	if game_over:
		return
		
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
