extends CanvasLayer

# map variables  # Note: row1 values = [0,n], row2 = [1,n]
@export var map_masks : Array[Array] # "Hidden" rooms = unexplored
@export var row1 : Array[TextureRect] # row1 and row2 are map coordinates
@export var row2 : Array[TextureRect]
@export var get_current : TextureRect # ?
@export var cur_row : int # cur_row/col = player coordinates
@export var cur_col : int

var visited_room : Array[Array] # tracks visited (1) and unvisited (0) rooms
var vis_row1 : Array[int] # coordinates of un/visited rooms
var vis_row2 : Array[int]
var player_location : Array[Array] # tracks player icon on map
var pl_row1 : Array[Sprite2D] # player icon location
var pl_row2 : Array[Sprite2D]


# Called when the node enters the scene tree for the first time.
# For updating _move(), use cur_row and cur_col var
func _ready() -> void: # Start of Game (SoG)
	# Add ? over map spaces at start of game. Signifies unexplored rooms
	# SoG: mask unvisited rooms, show starting room
	row1.append($"2x2Map/Mask")
	row1.append($"2x2Map/Mask2")
	row2.append($"2x2Map/Mask3")
	row2.append($"2x2Map/Mask4")
	map_masks.append(row1)
	map_masks.append(row2)
	map_masks[0][0].show()
	map_masks[1][0].show()
	map_masks[0][1].show()
	map_masks[1][1].hide()
	
	# SoG: set all rooms but starting room to "unvisited"
	vis_row1.append(0)
	vis_row1.append(0)
	vis_row2.append(0)
	vis_row2.append(1)
	visited_room.append(vis_row1)
	visited_room.append(vis_row2)

	# Coordinates for updating _move()
	# Set to starting room at SoG
	cur_col = 1
	cur_row = 1

	# SoG: set player icon grid, show for starting room
	# Note: coordinates acting strange.
	# Coord work when [col][row] rather than [row][col] called in move function
	pl_row1.append($PL_0_0)
	pl_row1.append($PL_0_1)
	pl_row2.append($PL_1_0)
	pl_row2.append($PL_1_1)
	player_location.append(pl_row1)
	player_location.append(pl_row2)
	player_location[0][0].hide()
	player_location[0][1].hide()
	player_location[1][0].hide()
	player_location[1][1].show()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _move(x, y):
	if(cur_row + x >= map_masks[0].size() or cur_row + x < 0):
		return -1
	elif(cur_col + y >= map_masks.size() or cur_col + y < 0):
		return -1
	else:
		player_location[cur_col][cur_row].hide() # not sure why this needs to be backwards, but it worked lol
		cur_col += y
		cur_row += x
		get_current = map_masks[cur_row][cur_col]
		var visited = visited_room[cur_row][cur_col]
		get_current.hide()
		player_location[cur_col][cur_row].show()
		visited_room[cur_row][cur_col] = 1
		return visited
