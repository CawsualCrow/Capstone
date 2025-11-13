extends CanvasLayer

# map variables  # Note: row1 values = [0,n], row2 = [1,n]
@export var map_masks : Array[Array] # "Hidden" rooms = unexplored
@export var row1 : Array[Sprite2D] # row1 and row2 are map coordinates
@export var row2 : Array[Sprite2D]
@export var row3 : Array[Sprite2D]
@export var row4 : Array[Sprite2D]
@export var get_current : Sprite2D # ?
@export var cur_row : int # cur_row/col = player coordinates
@export var cur_col : int
@export var Player_Icon : Sprite2D

var visited_room = [[0,0,0,0], # 0 = unvisited, 1 = visited
					[0,0,0,0],
					[0,0,0,0],
					[0,0,0,1]] # starting room

var player_loc_x = [50,150,250,350] # x-coordinate for player location

var player_loc_y = [45,135,225,315] # y-coordinate for player location

# array of door locations. if door to south, mult by 3; 
# if door to east, mult by 2, if door to west, mult by 5, 
# if door to north, mult by 7 (wtf is my life) 
# Room door directions utilize prime numbers to ensure that modulus
# will not interfere with directions (south mod will always act the same, etc)
var room_doors = [[6,15,3,3], 
				  [14,210,210,35],
				  [6,35,14,15],
				  [14,10,5,7]]

# Called when the node enters the scene tree for the first time.
# For updating _move(), use cur_row and cur_col var
func _ready() -> void: # Start of Game (SoG)
	Player_Icon = $"Player_Icon" # setting player icon variable to Sprite2D
	Player_Icon.show()
	# Add ? over map spaces at start of game. Signifies unexplored rooms
	# SoG: mask unvisited rooms, show starting room
	row1.append($"4x4Map/Mask1") # append room_masks to rows
	row1.append($"4x4Map/Mask2")
	row1.append($"4x4Map/Mask3")
	row1.append($"4x4Map/Mask4")
	row2.append($"4x4Map/Mask5")
	row2.append($"4x4Map/Mask6")
	row2.append($"4x4Map/Mask7")
	row2.append($"4x4Map/Mask8")
	row3.append($"4x4Map/Mask9")
	row3.append($"4x4Map/Mask10")
	row3.append($"4x4Map/Mask11")
	row3.append($"4x4Map/Mask12")
	row4.append($"4x4Map/Mask13")
	row4.append($"4x4Map/Mask14")
	row4.append($"4x4Map/Mask15")
	row4.append($"4x4Map/Mask16")
	map_masks.append(row1) # append mask rows to mask array
	map_masks.append(row2)
	map_masks.append(row3)
	map_masks.append(row4)
	map_masks[0][0].show() # start game with rooms "masked"
	map_masks[0][1].show()
	map_masks[0][2].show()
	map_masks[0][3].show()
	map_masks[1][0].show()
	map_masks[1][1].show()
	map_masks[1][2].show()
	map_masks[1][3].show()
	map_masks[2][0].show()
	map_masks[2][1].show()
	map_masks[2][2].show()
	map_masks[2][3].show()
	map_masks[3][0].show()
	map_masks[3][1].show()
	map_masks[3][2].show()
	map_masks[3][3].hide() # starting room should be visible, "unmasked"
	

	# Coordinates for updating _move()
	# Set to starting room at SoG
	cur_col = 3
	cur_row = 3

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _move(x, y):
	print("Moved from: ", room_doors[cur_row][cur_col])
	if(cur_row + x >= map_masks[0].size() or cur_row + x < 0):
		return -1
	elif(cur_col + y >= map_masks.size() or cur_col + y < 0):
		return -1
	elif(y == -1 and room_doors[cur_row][cur_col]%5 != 0 ):
		print("Case 1") # west
		return -1
	elif(y == 1 and room_doors[cur_row][cur_col]%2 != 0):
		print("Case 2") # east
		return -1
	elif(x == 1 and room_doors[cur_row][cur_col]%3 != 0):
		print("Case 3") # south
		return -1
	elif(x == -1 and room_doors[cur_row][cur_col]%7 != 0):
		print("Case 4") # north
		return -1
	else:
		# Player_Icon.hide()
		cur_col += y
		cur_row += x
		Player_Icon.position.x += (y * 100) # DO NOT ASK WHY THIS WORKS
		Player_Icon.position.y += (x * 90)
		get_current = map_masks[cur_row][cur_col]
		var visited = visited_room[cur_row][cur_col]
		get_current.hide()
		# player_location[cur_col][cur_row].show()
		visited_room[cur_row][cur_col] = 1
		print("Moved to: ", room_doors[cur_row][cur_col])
		return visited
