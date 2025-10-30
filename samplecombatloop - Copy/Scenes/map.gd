extends CanvasLayer

## map
@export var map_masks : Array[Array]
@export var row1 : Array[TextureRect]
@export var row2 : Array[TextureRect]
@export var get_current : TextureRect
@export var cur_row : int
@export var cur_col : int

var visited_room : Array[Array]
var vis_row1 : Array[int]
var vis_row2 : Array[int]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
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
	
	vis_row1.append(0)
	vis_row1.append(0)
	vis_row2.append(0)
	vis_row2.append(1)
	
	visited_room.append(vis_row1)
	visited_room.append(vis_row2)

	
	cur_col = 1
	cur_row = 1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _move(x, y):
	if(cur_row + x >= map_masks[0].size() or cur_row + x < 0):
		return -1
	elif(cur_col + y >= map_masks.size() or cur_col + y < 0):
		return -1
	else:
		cur_col += y
		cur_row += x
		get_current = map_masks[cur_row][cur_col]
		var visited = visited_room[cur_row][cur_col]
		get_current.hide()
		visited_room[cur_row][cur_col] = 1
		return visited
