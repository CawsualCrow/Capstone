extends Control


const InputResponse = preload("res://InputResponse.tscn")

@export var max_lines_remembered := 30

var max_scroll_length := 0

@onready var history_rows = $UI/MarginContainer/GameInfo/DisplayAndActions/DisplayInfo/Scroll/HistoryRows
@onready var scroll = $UI/MarginContainer/GameInfo/DisplayAndActions/DisplayInfo/Scroll
@onready var scrollbar = scroll.get_v_scroll_bar()



func _ready() -> void:
	scrollbar.connect("changed", Callable(self, "handle_scrollbar_changed"))
	max_scroll_length = scrollbar.max_value


func handle_scrollbar_changed():
	if max_scroll_length != scrollbar.max_value:
		max_scroll_length = scrollbar.max_value
		scroll.scroll_vertical = max_scroll_length


func _on_Input_text_entered(new_text: String) -> void:
	if new_text.is_empty():
		return
	
	var input_response = InputResponse.instantiate()
	input_response.set_text(new_text, "This is where a response goes!")
	history_rows.add_child(input_response)
	
	
	if history_rows.get_child_count() > max_lines_remembered:
		var rows_to_forget = history_rows.get_child_count() - max_lines_remembered
		for i in range(rows_to_forget):
			history_rows.get_child(i).queue_free()
