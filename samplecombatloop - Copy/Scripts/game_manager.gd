extends Node

@export var player_character : Character
@export var ai_character : Character
@export var slash : CombatAction
@export var heal : CombatAction

@onready var game_over_sound = $Event_HUD/go_sound
@onready var navigation_music = $Navigation/nav_music

var cur_weapon_select : int

# PLAYER: Exp variable will increase when enemy is defeated.
var player_exp : int = 0
# BOSS boolean (used to present boss in final room)
var boss_encounter : bool = false

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
	navigation_music.stop()
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
		game_over_sound.play()
	elif ($AI_Character.cur_health <= 0):
		print("You win!")
		player_exp += 600 #EXP gain from defeating enemy
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
			navigation_music.play()

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
	navigation_music.play()
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


# COMBAT: Scales enemy encounters after Player level up
func _on_player_character_leveled_up() -> void:
	$AI_Character.max_health += 10
	$AI_Character.cur_health = $AI_Character.max_health
	$AI_Character.strength_bonus += 2
	player_exp -= 1000 # spend player exp on level up
	$Level_Up_Screen.hide()
	$Navigation/PlayerInfo.text = "Hit Points: " + str($Player_Character.cur_health) + " / " + str($Player_Character.max_health)
	$Navigation.show()
	navigation_music.play()
	$Map.show()


func _event_chance() -> void:
	event_chance = randi_range(0, 99)
	if (event_chance >= 66): # Random Event Printed to Screen
		event_selector = randi_range(0, (random_events.size()-1))
		$Navigation/Output.text = random_events[event_selector].description
		var event_action = random_events[event_selector].event_effect
		$Player_Character.take_damage(event_action.melee_damage)
		$Player_Character.heal(event_action.heal_amount)
		$Navigation/PlayerInfo.text = "Hit Points: " + str($Player_Character.cur_health) + " / " + str($Player_Character.max_health)
		if ($Player_Character.cur_health <= 0):
			$Navigation.hide()
			navigation_music.stop()
			$Map.hide()
			$Game_Over/Game_Over_Text.text = random_events[event_selector].description
			$Game_Over.show()
	elif (event_chance >= 33 and event_chance < 66): # COMBAT EVENT
		$HUD.show()
		$Navigation.hide()
		navigation_music.stop()
		$Map.hide()
		$HUD/Player_Health.text = "Hit Points: " + str($Player_Character.cur_health) + " / " + str($Player_Character.max_health)
		$HUD/AI_Health.text = "Hit Points: " + str($AI_Character.cur_health) + " / " + str($AI_Character.max_health)
		$HUD/Text_Output.text = "You encounter a monster!"
		next_turn()
		#combat_event = true
	else: # Step into new room with no event or combat
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
		navigation_music.play()
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
	#if ($Map.room_doors == 5): # boss encounter?
		#$Map.hide()
		#$Navigation.hide()
		#$HUD.show()
		#$HUD/Text_Output.text = "BOSS ENCOUNTER!"
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


func _on_start_over_pressed() -> void:
	# On Return to Character Select: Reset Player Attributes
	$Player_Character.max_health = 0
	$Player_Character.cur_health = 0
	$Player_Character.strength_bonus = 0
	$Player_Character.dexterity_bonus = 0
	$Player_Character.constitution_bonus = 0
	$Player_Character.intelligence_bonus = 0
	
	$Game_Over.hide()
	$"Character Creator".show()
	


func _on_load_game_after_loss_pressed() -> void:
	# Load JSON for Player Attributes and Map Progress
	var save_file = FileAccess.open("user://savegame.save", FileAccess.READ)
	while save_file.get_position() < save_file.get_length():
		var json_string = save_file.get_line()
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		var node_data = json.data
	 	
		$Player_Character.cur_health = "pc_cur_health".to_int()
		$Player_Character.max_health = "pc_max_health".to_int()
		player_exp = "exp".to_int()
		$Player_Character.ancestry = "pc_ancestry".to_int()
		$Player_Character.job = "pc_job".to_int()
		$Player_Character.strength_bonus = "pc_str_bonus".to_int()
		$Player_Character.dexterity_bonus = "pc_dex_bonus".to_int()
		$Player_Character.constitution_bonus = "pc_con_bonus".to_int()
		$Player_Character.intelligence_bonus = "pc_int_bonus".to_int()
		
		$AI_Character.cur_health = "monster_cur_health".to_int()
		$AI_Character.max_health = "monster_max_health".to_int()
		$AI_Character.strength_bonus = "monster_str_bonus".to_int()
	
		
		$Map.map_masks = "map_masks"
		$Map.visited_room = "map_visited_room"
		$Map.player_loc_x = "pc_loc_x"
		$Map.player_loc_y = "pc_loc_y"
		$Map.cur_col = "cur_map_col"
		$Map.cur_row = "cur_map_row"
		$Map.Player_Icon.position.x = "pc_icon_x"
		$Map.Player_Icon.position.y = "pc_icon_y"
		$Map.get_current = "cur_map_mask"
		$Map.visited = "var_visited"
	
	$Game_Over.hide()
	$Navigation.show()
	navigation_music.play()
	$Map.show()
	


func _on_close_inventory_pressed() -> void:
	# Exit Inventory and return to Map/Navigation
	$Inventory.hide()
	$Navigation.show()
	$Map.show()


func _on_access_inventorry_pressed() -> void:
	#Bring up Inventory Scene
	$Map.hide()
	$Navigation.hide()
	$Inventory.show()
	

func _on_save_game_pressed() -> void:
	# Save Game Progress (MAY NEED TO REVISE WHAT IS SAVED
	var save_file = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	var save_data = {"pc_cur_health" : $Player_Character.cur_health, "pc_max_health" : $Player_Character.max_health, "exp" : player_exp, "pc_ancestry" : $Player_Character.ancestry, "pc_job" : $Player_Character.job, "pc_str_bonus" : $Player_Character.strength_bonus, "pc_dex_bonus" : $Player_Character.dexterity_bonus, "pc_con_bonus" : $Player_Character.constitution_bonus, "pc_int_bonus" : $Player_Character.intelligence_bonus, "monster_cur_health" : $AI_Character.cur_health, "monster_max_health" : $AI_Character.max_health, "monster_str_bonus" : $AI_Character.strength_bonus, "map_masks" : $Map.map_masks, "map_visited_room" : $Map.visited_room, "pc_loc_x" : $Map.player_loc_x, "pc_loc_y" : $Map.player_loc_y, "cur_map_col" : $Map.cur_col, "cur_map_row" : $Map.cur_row, "pc_icon_x" : $Map.Player_Icon.position.x, "pc_icon_y" : $Map.Player_Icon.position.y, "cur_map_mask" : $Map.get_current} #, "var_visited" : $Map.visited}
	var json_data = JSON.stringify(save_data)
	save_file.store_line(json_data)
	


func _on_load_game_pressed() -> void:
	# Load JSON for Player Attributes and Map Progress
	var save_file = FileAccess.open("user://savegame.save", FileAccess.READ)
	while save_file.get_position() < save_file.get_length():
		var json_string = save_file.get_line()
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		var node_data = json.data
	 	
		$Player_Character.cur_health = "pc_cur_health".to_int()
		$Player_Character.max_health = "pc_max_health".to_int()
		player_exp = "exp".to_int()
		$Player_Character.ancestry = "pc_ancestry".to_int()
		$Player_Character.job = "pc_job".to_int()
		$Player_Character.strength_bonus = "pc_str_bonus".to_int()
		$Player_Character.dexterity_bonus = "pc_dex_bonus".to_int()
		$Player_Character.constitution_bonus = "pc_con_bonus".to_int()
		$Player_Character.intelligence_bonus = "pc_int_bonus".to_int()
		
		$AI_Character.cur_health = "monster_cur_health".to_int()
		$AI_Character.max_health = "monster_max_health".to_int()
		$AI_Character.strength_bonus = "monster_str_bonus".to_int()
	
		
		$Map.map_masks = "map_masks"
		$Map.visited_room = "map_visited_room"
		$Map.player_loc_x = "pc_loc_x"
		$Map.player_loc_y = "pc_loc_y"
		$Map.cur_col = "cur_map_col"
		$Map.cur_row = "cur_map_row"
		$Map.Player_Icon.position.x = "pc_icon_x"
		$Map.Player_Icon.position.y = "pc_icon_y"
		$Map.get_current = "cur_map_mask"
		$Map.visited = "var_visited"
	
	$"Character Creator".hide()
	$Navigation.show()
	navigation_music.play()
	$Map.show()
