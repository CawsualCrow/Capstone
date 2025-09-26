class_name CombatAction
extends Resource

@export var display_name : String
@export var description: String

@export var melee_damage : int = 0
# add melee name?  damage = randi(0,8) + strength; name = "1d8"
@export var heal_amount : int = 0

@export var base_weight : int = 100
# ai decision weight
