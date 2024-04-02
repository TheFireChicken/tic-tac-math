extends Node2D

var selected_row = 0
var selected_column = 0
	
func _on_area_2d_input_event(viewport, event, shape_idx):
	# If left clicking on a square, while not solving a calculation and game not finished
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and not Globals.game_instance.is_in_minigame and not Globals.game_instance.game_finished:
		set_clicked_fields()
		if Globals.game_instance.game_field[selected_row][selected_column] == "-":
			Globals.current_square_instance = self
			Globals.game_instance.start_calculate_minigame()
		

func set_clicked_fields():
		var click_position = self.position
		# Iterate through each row of SQUARE_POSITIONS
		for row_index in range(Globals.SQUARE_POSITIONS.size()):
			# Iterate through each position in the current row
			for col_index in range(Globals.SQUARE_POSITIONS[row_index].size()):
				# Get the position for the current cell
				var cell_position = Globals.SQUARE_POSITIONS[row_index][col_index]
				# Check if the click_position is within the bounds of the current cell, else invalid row and column, takes base value 
				if click_position.x > cell_position.x - 130 and click_position.x < cell_position.x + 130 and click_position.y > cell_position.y - 130 and click_position.y < cell_position.y + 130:
					# Matching position found, print the row and column index
					selected_row = row_index
					selected_column = col_index		
func place_symbol():
	var symbol = Globals.game_instance.current_turn
	var field_symbol = get_node(symbol)
	field_symbol.visible = true
	Globals.field_symbols.append(field_symbol)
	Globals.game_instance.game_field[selected_row][selected_column] = symbol
	Globals.game_instance.swap_turns()
