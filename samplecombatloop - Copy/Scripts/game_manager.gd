extends Node

@export var player_character : Character
@export var ai_character : Character
@export var slash : CombatAction
@export var heal : CombatAction

var cur_weapon_select : int


# are these correct?
@onready var player_health_text = $"HUD/Player Health"
@onready var ai_health_text = $"HUD/AI Health"

# event array
@export var random_events : Array[RandomEvent]
@export var event_selector : int
@export var event_chance : int
@export var weapon_list : Array[Weapon]


# current character
var current_character : Character

# add end of game upon true
var game_over : bool = false
var combat_over : bool = false

func _ready():
	$"Character Creator".show()
	$HUD.hide()
	$Level_Up_Screen.hide()
	$Game_Over.hide()
	$Event_HUD.hide()
	$Inventory.hide()
	$Navigation.hide()
	$Map.hide()


func next_turn ():
	if current_character != null: # swapping between characters
		current_character.end_turn()
	
	if current_character == ai_character or current_character == null:
		current_character = player_character
	else:
		current_character = ai_character
		
	current_character.begin_turn()
	
	if current_character.is_player: # Take player turn
		$HUD.reveal_hud()
		# enable and set player ui
		
	elif ($AI_Character.cur_health > 0): # AI is still alive
		# disable player ui
		$HUD.hide_hud()
		$Inventory.hide()
		var wait_time = randf_range(0.5, 1.5) # wait time for ai turn
		await get_tree().create_timer(wait_time).timeout
		
		var action_to_cast = ai_decide_combat_action() # ai choice of action
		ai_character.cast_combat_action(action_to_cast, player_character)
		
		await get_tree().create_timer(0.5).timeout # wait time for ai action
		
		if ($Player_Character.cur_health <= 0): # check if player dead
			end_combat() # combat ends if player dead
		else: 
			next_turn() # combat continues otherwise
			
	else: # ai is defeated
		end_combat()
		

func end_combat (): # handles player or ai death
	$HUD.hide()
	if ($Player_Character.cur_health <= 0):
		print("You Lose!")
		$Game_Over.show()
	elif ($AI_Character.cur_health <= 0):
		print("You win!")
		$Level_Up_Screen.show()

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


func _on_start_game_pressed() -> void: # change to go to navigation
	# save player character stats and start combat
	# $Player_Character set bonuses
	# add refusal to start if character options not selected.
	$"Character Creator".hide()
	$"Navigation".show()
	$"Map".show()
	
	#$HUD/Player_Health.text = str($Player_Character.cur_health) + " / " + str($Player_Character.max_health)
	#$HUD/AI_Health.text = str($AI_Character.cur_health) + " / " + str($AI_Character.max_health)
	#$HUD.show()
	#next_turn()

# add func to move from navigation to combat/event

func _on_player_character_health_change():
	$HUD/Player_Health.text = str($Player_Character.cur_health) + " / " + str($Player_Character.max_health)

func _on_ai_character_health_change() -> void:
	$HUD/AI_Health.text = str($AI_Character.cur_health) + " / " + str($AI_Character.max_health)
	
func _on_player_character_health_depleted() -> void:
	game_over = true
func _on_ai_character_health_depleted() -> void:
	game_over = true

#func _on_finish_level_up_pressed() -> void:
	#$AI_Character.max_health += 10
	#$AI_Character.cur_health = $AI_Character.max_health
	#$AI_Character.strength_bonus += 2
	#$Level_Up_Screen.hide()
	#$HUD.show()
	#$HUD/Player_Health.text = str($Player_Character.cur_health) + " / " + str($Player_Character.max_health)
	#$HUD/AI_Health.text = str($AI_Character.cur_health) + " / " + str($AI_Character.max_health)
	#
	#next_turn()


func _on_player_character_leveled_up() -> void:
	$AI_Character.max_health += 10
	$AI_Character.cur_health = $AI_Character.max_health
	$AI_Character.strength_bonus += 2
	$Level_Up_Screen.hide()

	
	event_chance = randi_range(0, 99)
	if (event_chance >= 50):
		event_selector = randi_range(0, (random_events.size()-1))
		# do event, then continue to combat
		print("Player health before event ", $Player_Character.cur_health)
		$Event_HUD/Event_Description.text = random_events[event_selector].description
		var event_action = random_events[event_selector].event_effect
		$Player_Character.take_damage(event_action.melee_damage)
		$Player_Character.heal(event_action.heal_amount)
		print("Player health after event ", $Player_Character.cur_health)
		#if (event_action.melee_damage > 0):
		#	var event_health = "You take %d points of damage!"
		#	$Event_HUD/Event_Description.text = random_events[event_selector].description + event_health
		$Event_HUD.show()
	else:
		$HUD.show()
		$HUD/Player_Health.text = str($Player_Character.cur_health) + " / " + str($Player_Character.max_health)
		$HUD/AI_Health.text = str($AI_Character.cur_health) + " / " + str($AI_Character.max_health)
		next_turn()
		


func _on_continue__to_combat_pressed() -> void:
	$Event_HUD.hide()
	$HUD.show()
	$HUD/Player_Health.text = str($Player_Character.cur_health) + " / " + str($Player_Character.max_health)
	$HUD/AI_Health.text = str($AI_Character.cur_health) + " / " + str($AI_Character.max_health)
	next_turn()


func _on_equip_weapon_pressed() -> void:
	$Player_Character.equip_weapon(weapon_list[cur_weapon_select])
	$Inventory.hide()
	$Level_Up_Screen.show()
	


func _on_weapon_selector_item_selected(index: int) -> void:
	cur_weapon_select = index


func _on_inventory_button_pressed() -> void:
	$Level_Up_Screen.hide()
	$Inventory.show()


func _on_north_pressed() -> void:
	var outcome = $Map._move(0,-1)
	if(outcome == -1):
		print("Cannot move")
	if(outcome == 0):
		print("Event Triggered (new room)")
	if(outcome == 1):
		print("Room already visited (no event)")


func _on_west_pressed() -> void:
	var outcome = $Map._move(-1,0)
	if(outcome == -1):
		print("Cannot move")
	if(outcome == 0):
		print("Event Triggered (new room)")
	if(outcome == 1):
		print("Room already visited (no event)")


func _on_south_pressed() -> void:
	var outcome = $Map._move(0,1)
	if(outcome == -1):
		print("Cannot move")
	if(outcome == 0):
		print("Event Triggered (new room)")
	if(outcome == 1):
		print("Room already visited (no event)")


func _on_east_pressed() -> void:
	var outcome = $Map._move(1,0)
	if(outcome == -1):
		print("Cannot move")
	if(outcome == 0):
		print("Event Triggered (new room)")
	if(outcome == 1):
		print("Room already visited (no event)")
