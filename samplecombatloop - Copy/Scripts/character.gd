class_name Character
extends Node


# figure out what other funcs character.gd uses

signal OnTakeDamage (health : int)
signal OnHeal (health: int)
signal health_change
signal health_depleted
signal leveled_up

@export var is_player : bool

# @export var ancestry : Ancestry
# @export var job : Job

var ancestry : int # 0 = human, 1 = dwarf, 2 = elf
var job : int # 0 = fighter, 1 = rogue, 2 = mage

@export var strength_bonus : int # increase damage
@export var dexterity_bonus : int # increase ac
@export var constitution_bonus : int # increase health
@export var intelligence_bonus : int # increase heal

@export var cur_health : int # cur / max
@export var max_health : int

@export var armor_class : int # determine if hit

@export var combat_actions : Array[CombatAction]

var target_scale : float = 1.0


# var audio
# var take_damage_sfx
# var heal_sfx


func begin_turn():
	target_scale = 1.1
	# what does this do??
	
	if is_player:
		print("Player turn has begun")
		print("Player health: " + str(cur_health))
	else:
		print("AI turn has begun")
		print("AI health: " + str(cur_health))

func end_turn():
	target_scale = 0.9
	# what does this do? increase/decrease character size on screen on turn?

func _process (delta):
	pass

func take_damage (amount : int):
	cur_health -= amount
	health_change.emit()
	if (cur_health <= 0):
		health_depleted.emit()
		

func heal (amount : int):
	cur_health += amount
	if (cur_health >= max_health):
		cur_health = max_health
	health_change.emit()

func cast_combat_action (action : CombatAction, opponent : Character):
	var dmg = randi_range(1, 8) # doubles as heal value
	
	if (action.heal_amount > 0):
		action.heal_amount = (dmg + intelligence_bonus)
		heal(action.heal_amount)
		print("Heal for %s points! (roll %s + %s)" % [str(action.heal_amount), str(dmg), str(intelligence_bonus)])
	if (action.melee_damage > 0):
		action.melee_damage = (dmg + strength_bonus)
		opponent.take_damage(action.melee_damage)
		print("Take %s damage! (roll %s + %s)" % [str(action.melee_damage), str(dmg), str(strength_bonus)])

func _play_audio (steam : AudioStream):
	pass
	# maybe add attack sounds?


func _on_ancestry_selection_item_selected(index: int) -> void:
	# Ancestry Bonuses
	if(!is_player):
		pass
	else:
		ancestry = index
		if (index == 0): # HUMAN
			cur_health += 8
			max_health += 8
			# add modifier bonuses later
		elif (index == 1): # DWARF
			strength_bonus += 1
			constitution_bonus += 1
			cur_health += 10
			max_health += 10
		else: # ELF
			dexterity_bonus += 1
			intelligence_bonus += 1
			cur_health += 6
			max_health += 6


func _on_job_selection_item_selected(index: int) -> void:
	# Job Bonuses
	if (!is_player):
		pass
	else:
		job = index
		if (index == 0): # FIGHTER
			max_health += (10 + constitution_bonus)
			cur_health += (10 + constitution_bonus)
			strength_bonus += 1
		elif (index == 1): # ROGUE
			cur_health += (8 + constitution_bonus)
			max_health += (8 + constitution_bonus)
			strength_bonus += 1
		else: # MAGE
			strength_bonus -= 1
			intelligence_bonus += 1
			cur_health += (6 + constitution_bonus)
			max_health += (6 + constitution_bonus)
		


func _on_option_button_item_selected(index: int) -> void:
	# Ability Modifier Increase
	if (!is_player):
		pass
	else:
		if (index == 0): # STRENGTH
			strength_bonus += 1
		elif (index == 1): # DEXTERITY
			dexterity_bonus += 1
		elif (index == 2): # CONSTITUTION
			constitution_bonus += 1
		else: # INTELLIGENCE
			intelligence_bonus += 1


func _on_finish_level_up_pressed() -> void:
	if (!is_player):
		pass
	else:
		if (job == 0): # FIGHTER
			cur_health += (10 + constitution_bonus)
			max_health += (10 + constitution_bonus)
		elif (job == 1): # ROGUE
			cur_health += (8 + constitution_bonus)
			max_health += (8 + constitution_bonus)
		else: # MAGE
			cur_health += (6 + constitution_bonus)
			max_health += (6 + constitution_bonus)
		leveled_up.emit()
