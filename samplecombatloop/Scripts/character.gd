class_name Character
extends Node


# figure out what other funcs character.gd uses
signal OnTakeDamage (health : int)
signal OnHeal (health: int)

@export var is_player : bool

@export var cur_health : int
@export var max_health : int

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

func heal (amount : int):
	cur_health += amount
	if (cur_health >= max_health):
		cur_health = max_health

func cast_combat_action (action : CombatAction, opponent : Character):
	heal(action.heal_amount)
	opponent.take_damage(action.melee_damage)

func _play_audio (steam : AudioStream):
	pass
	# maybe add attack sounds?
