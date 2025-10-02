class_name Character
extends Node


# figure out what other funcs character.gd uses

signal OnTakeDamage (health : int)
signal OnHeal (health: int)
signal health_change
signal health_depleted

@export var is_player : bool

# @export var ancestry : Ancestry
# @export var job : Job

@export var strength_bonus : int
@export var intelligence_bonus : int
@export var constitution_bonus : int

@export var cur_health : int
@export var max_health : int

# @export var armor_class : int

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
	if (action.heal_amount > 0):
		heal(action.heal_amount + intelligence_bonus)
	if (action.melee_damage > 0):
		opponent.take_damage(action.melee_damage + strength_bonus)

func _play_audio (steam : AudioStream):
	pass
	# maybe add attack sounds?


func _on_ancestry_selection_item_selected(index: int) -> void:
	# Ancestry Bonuses
	if (index == 0):
		pass
		# human, no bonus for now
	elif (index == 1):
		# dwarf
		strength_bonus += 5
	else:
		# elf
		intelligence_bonus += 5


func _on_job_selection_item_selected(index: int) -> void:
	# Job Bonuses
	if (index == 0):
		max_health += 5
		cur_health += 5
		# fighter
	elif (index == 1):
		# rogue
		strength_bonus += 5
	else:
		# mage
		strength_bonus -= 2
		intelligence_bonus += 5
