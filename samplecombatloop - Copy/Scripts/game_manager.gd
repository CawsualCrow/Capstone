extends Node

@export var player_character : Character
@export var ai_character : Character
@export var slash : CombatAction
@export var heal : CombatAction

var cur_weapon_select : int

# PLAYER: Exp variable will increase when enemy is defeated.
var player_exp : int = 0

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

# boolean to determine if event screen goes to combat or not
var combat_event : bool = false

func _ready():
	$"Character Creator".show()
	$HUD.hide()
	$Level_Up_Screen.hide()
	$Game_Over.hide()
	$Event_HUD.hide()
	$Inventory.hide()
	$Navigation.hide()
	$Map.hide()

# Rotate turns in combat
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
		print("You Lose!")  # NOT WORKING
		$Event_HUD/Event_Description.text = "You feel a heavy impact as the monster's weapon crushes your chest. The world spins around you as you collapse to the floor, the monster laughing as it stands over you in victory."
		$Event_HUD.show()
	elif ($AI_Character.cur_health <= 0):
		print("You win!")
		player_exp += 250 #EXP gain from defeating enemy
		$AI_Character.cur_health = $AI_Character.max_health
		if (player_exp >= 1000):
			$Level_Up_Screen.show()
		else:
			# add item drops from enemy?
			# $Event_HUD/Event_Description.text = "You stand in victory as the monster lays defeated before you!"
			# $Event_HUD.show()
			# ADD TRANSITION FROM EVENT TO MAP
			$Navigation/PlayerInfo.text = "Hit Points: " + str($Player_Character.cur_health) + " / " + str($Player_Character.max_health)
			$Navigation.show()
			$Map.show()

# COMBAT: Player selects action to perform
func player_cast_combat_action (action : CombatAction):
	if player_character != current_character:
		return
	
	player_character.cast_combat_action(action, ai_character)
	# disable player ui
	await get_tree().create_timer(0.5).timeout # timer presents readability and flow of text
	next_turn()


func ai_decide_combat_action () -> CombatAction:
	return slash


func _on_slash_pressed() -> void: # PLAYER: perform slash in combat
	player_cast_combat_action(slash)
	


func _on_heal_pressed() -> void: # PLAYER: perform heal on self in combat
	player_cast_combat_action(heal)


func _on_start_game_pressed() -> void:
	# save player character stats and start combat
	# $Player_Character set bonuses
	# add refusal to start if character options not selected. (TO DO)
	$"Character Creator".hide()
	$HUD/Player_Health.text = "Hit Points: " + str($Player_Character.cur_health) + " / " + str($Player_Character.max_health)
	$HUD/AI_Health.text = str($AI_Character.cur_health) + " / " + str($AI_Character.max_health)
	$Map.show()
	$Navigation/PlayerInfo.text = "Hit Points: " + str($Player_Character.cur_health) + " / " + str($Player_Character.max_health)
	$Navigation.show()
	#next_turn()

# COMBAT: Displays/updates health changes on HUD during combat
func _on_player_character_health_change():
	$HUD/Player_Health.text = "Hit Points: " + str($Player_Character.cur_health) + " / " + str($Player_Character.max_health)
func _on_ai_character_health_change() -> void:
	$HUD/AI_Health.text = "Hit Points: " + str($AI_Character.cur_health) + " / " + str($AI_Character.max_health)
	
# COMBAT END: ends combat and calls Game Over or returns to map
func _on_player_character_health_depleted() -> void:
	game_over = true
func _on_ai_character_health_depleted() -> void:
	pass

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

# COMBAT: Scales enemy encounters after Player level up
func _on_player_character_leveled_up() -> void:
	$AI_Character.max_health += 10
	$AI_Character.cur_health = $AI_Character.max_health
	$AI_Character.strength_bonus += 2
	player_exp -= 1000 # spend player exp on level up
	$Level_Up_Screen.hide()
	$Navigation/PlayerInfo.text = "Hit Points: " + str($Player_Character.cur_health) + " / " + str($Player_Character.max_health)
	$Navigation.show()
	$Map.show()

	# MOVE THIS TO MOVEMENT FUNCS
#	event_chance = randi_range(0, 99)
#	if (event_chance >= 75):
#		event_selector = randi_range(0, (random_events.size()-1))
#		# do event, then continue to combat
#		print("Player health before event ", $Player_Character.cur_health)
#		$Event_HUD/Event_Description.text = random_events[event_selector].description
#		var event_action = random_events[event_selector].event_effect
#		$Player_Character.take_damage(event_action.melee_damage)
#		$Player_Character.heal(event_action.heal_amount)
#		print("Player health after event ", $Player_Character.cur_health)
#		#if (event_action.melee_damage > 0):
#		#	var event_health = "You take %d points of damage!"
#		#	$Event_HUD/Event_Description.text = random_events[event_selector].description + event_health
#		$Event_HUD.show()
#	else:
#		$HUD.show()
#		$HUD/Player_Health.text = str($Player_Character.cur_health) + " / " + str($Player_Character.max_health)
#		$HUD/AI_Health.text = str($AI_Character.cur_health) + " / " + str($AI_Character.max_health)
#		next_turn()
		
func _event_chance() -> void:
	event_chance = randi_range(0, 99)
	if (event_chance >= 66):
		event_selector = randi_range(0, (random_events.size()-1))
		#print("Player health before event ", $Player_Character.cur_health)
		#$Event_HUD/Event_Description.text = random_events[event_selector].description
		$Navigation/Output.text = random_events[event_selector].description
		var event_action = random_events[event_selector].event_effect
		$Player_Character.take_damage(event_action.melee_damage)
		$Player_Character.heal(event_action.heal_amount)
		$Navigation/PlayerInfo.text = "Hit Points: " + str($Player_Character.cur_health) + " / " + str($Player_Character.max_health)
		if ($Player_Character.cur_health <= 0):
			$Navigation.hide()
			$Map.hide()
			$Game_Over/Game_Over_Text.text = random_events[event_selector].description
			$Game_Over.show()
	elif (event_chance >= 33 and event_chance < 66):
		$HUD.show()
		$Navigation.hide()
		$Map.hide()
		$HUD/Player_Health.text = "Hit Points: " + str($Player_Character.cur_health) + " / " + str($Player_Character.max_health)
		$HUD/AI_Health.text = "Hit Points: " + str($AI_Character.cur_health) + " / " + str($AI_Character.max_health)
		$HUD/Text_Output.text = "You encounter a monster!"
		next_turn()
		#combat_event = true
	else:
		pass

# EVENT SCREEN: transition from event to map, or to combat
# 	CHANGE THIS
func _on_continue__to_combat_pressed() -> void:
	# $Event_HUD.hide()
	# $HUD.show()
	$HUD/Player_Health.text = "Hit Points: " + str($Player_Character.cur_health) + " / " + str($Player_Character.max_health)
	$HUD/AI_Health.text = "Hit Points: " + str($AI_Character.cur_health) + " / " + str($AI_Character.max_health)
	# next_turn()
	if ($Player_Character.cur_health <= 0):
		$Event_HUD.hide()
		$Game_Over.show()
	else:
		$Event_HUD.hide()
		$Navigation.show()
		$Map.show()
		
func _on_equip_weapon_pressed() -> void:
	$Player_Character.equip_weapon(weapon_list[cur_weapon_select])
	$Inventory.hide()
	$Level_Up_Screen.show()
	
func _on_weapon_selector_item_selected(index: int) -> void:
	cur_weapon_select = index

func _on_inventory_button_pressed() -> void:
	$Level_Up_Screen.hide()
	$Inventory.show()

# NAVIGATION / MAP: Direction buttons 
func _on_north_pressed() -> void:
	var outcome = $Map._move(-1,0)
	if(outcome == -1):
		#print("Cannot move")
		$Navigation/Output.text = "> You cannot go that way."
	if(outcome == 0):
		#print("Event Triggered (new room)")
		$Navigation/Output.text = "> You enter the room to the north"
		_event_chance()
	if(outcome == 1):
		$Navigation/Output.text = "> You enter the room to the north"
		#print("Room already visited (no event)")
func _on_west_pressed() -> void:
	var outcome = $Map._move(0,-1)
	if(outcome == -1):
		#print("Cannot move")
		$Navigation/Output.text = "> You cannot go that way."
	if(outcome == 0):
		#print("Event Triggered (new room)")
		$Navigation/Output.text = "> You enter the room to the west."
		_event_chance()
	if(outcome == 1):
		#print("Room already visited (no event)")
		$Navigation/Output.text = "> You enter the room to the west."
func _on_south_pressed() -> void:
	var outcome = $Map._move(1,0)
	if(outcome == -1):
		#print("Cannot move")
		$Navigation/Output.text = "> You cannot go that way."
	if(outcome == 0):
		#print("Event Triggered (new room)")
		$Navigation/Output.text = "> You enter the room to the south."
		_event_chance()
	if(outcome == 1):
		#print("Room already visited (no event)")
		$Navigation/Output.text = "> You enter the room to the south."
func _on_east_pressed() -> void:
	var outcome = $Map._move(0,1)
	if(outcome == -1):
		#print("Cannot move")
		$Navigation/Output.text = "> You cannot go that way."
	if(outcome == 0):
		#print("Event Triggered (new room)")
		$Navigation/Output.text = "> You enter the room to the south."
		_event_chance()
	if(outcome == 1):
		#print("Room already visited (no event)")
		$Navigation/Output.text = "> You enter the room to the south."
