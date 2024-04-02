extends Node2D

var current_turn = "X"
var game_field = [["-","-","-"],["-","-","-"],["-","-","-"]]
var game_finished = false

var difficulty = 0
var is_in_minigame = false
var number1 
var number2
var operator
var operator_display = ["+","-","x"]
var solution 

func _ready():
	Globals.game_instance = self
	$SelectDifficulty.add_item("Easy")
	$SelectDifficulty.add_item("Normal")
	$SelectDifficulty.add_item("Hard")
	$SelectDifficulty.add_item("Very Hard")

func _process(delta):
	if Input.is_action_just_pressed("Click") and game_finished:
		restart_game()

func start_calculate_minigame():
	is_in_minigame = true
	calculate_solution()
	$BlockedField.visible = true
	$Calculation.visible = true
	$Calculation.text = str(number1) + " " + operator + " " + str(number2) + " ="
	$CalculationInputField.visible = true
	$TimeLeftTimer.start()
	$TimeLeftProgress.visible = true

func calculate_successfully():
	$OverlayTimer.start()
	$Overlay.visible = true
	$Overlay.modulate = Color(Color.GREEN,0.1)
	stop_calculate_minigame()
	place_symbol()
	swap_turns()	

func calculate_failed():
	$OverlayTimer.start()	
	$Overlay.visible = true
	$Overlay.modulate = Color(Color.RED,0.1)	
	stop_calculate_minigame()
	swap_turns()

func place_symbol():
	var symbol = Globals.game_instance.current_turn
	var field_symbol = Globals.current_square_instance.get_node(symbol)
	field_symbol.visible = true
	Globals.field_symbols.append(field_symbol)
	game_field[Globals.current_square_instance.selected_row][Globals.current_square_instance.selected_column] = symbol
		
func stop_calculate_minigame():
	is_in_minigame = false
	$BlockedField.visible = false
	$Calculation.visible = false
	$CalculationInputField.visible = false
	$CalculationInputField.text = ""
	$TimeLeftTimer.stop()
	$TimeLeftProgress.visible = false
	$TimeLeftProgress.value = 100

func calculate_solution():
	number1 = getRandomValue()
	number2 = getRandomValue()
	var operator_chosen = getRandomOperator()
	operator = operator_display[operator_chosen]
	if operator_chosen == 0:
		solution = number1 + number2
		return
	if operator_chosen == 1:
		solution = number1 - number2
		return
	if operator_chosen == 2:
		solution = number1 * number2
		return	

func getRandomValue():
	var max_value = 20
	if difficulty == 1:
		max_value == 50
	if difficulty == 2:
		max_value == 100
	if difficulty == 3:
		max_value = 200		
	return randi_range(1, max_value)

func getRandomOperator():
	return randi_range(0, 2)

func swap_turns():
	# Restart game if someone won or if all fields are filled and it's a draw
	if checkWin() != "" or Globals.field_symbols.size() == 9:
		stop_game()
		return
	if current_turn == "X":
		current_turn = "O"
		$TurnSymbol.text = current_turn
		return
	current_turn = "X"	
	$TurnSymbol.text = current_turn

func stop_game():
	game_finished = true
	$TurnText.visible = false
	$TurnSymbol.visible = false
	$WinnerText.text = "[b] WINNER: " + current_turn + " [/b]"
	$WinnerText.visible = true
	$RestartText.visible = true

func restart_game():
	game_field = [["-","-","-"],["-","-","-"],["-","-","-"]]
	current_turn = "X"
	for index in Globals.field_symbols.size():
		Globals.field_symbols[index].visible = false
	Globals.field_symbols.clear()
	$TurnText.visible = true
	$TurnSymbol.visible = true
	$WinnerText.visible = false
	$RestartText.visible = false	
	game_finished = false
	
func checkWin():
	var winner = ""
	
	# Check rows
	for row in game_field:
		if row[0] == row[1] and row[0] == row[2] and row[0] != "-":
			winner = row[0]
			return winner

	# Check columns
	for col in range(3):
		if game_field[0][col] == game_field[1][col] and game_field[0][col] == game_field[2][col] and game_field[0][col] != "-":
			winner = game_field[0][col]
			return winner

	# Check diagonals
	if game_field[0][0] == game_field[1][1] and game_field[0][0]== game_field[2][2] and game_field[0][0] != "-":
		winner = game_field[0][0]
		return winner
	if game_field[0][2] == game_field[1][1] and game_field[0][2] == game_field[2][0] and game_field[0][2] != "-":
		winner = game_field[0][2]
		return winner

	return winner


func _on_calculation_input_field_text_submitted(new_text):
	if new_text.is_valid_int(): # If entered an int, check if it's correct solution
		var int_value = new_text.to_int()
		if int_value == solution:
			calculate_successfully()
		else:
			calculate_failed()
	else:
		print("String cannot be converted to int")



func _on_time_left_timer_timeout():
	const STEP = 2
	var calculated_value = $TimeLeftProgress.value - STEP
	$TimeLeftProgress.value = calculated_value
	if calculated_value <= 0:
		calculate_failed()


func _on_select_difficulty_item_selected(index):
	difficulty = index


func _on_overlay_timer_timeout():
	$Overlay.visible = false
	$Overlay.modulate = Color(Color.WHITE,1)
