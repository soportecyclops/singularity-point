extends Node

## GameManager — Global game state singleton (autoload).
## High-level coordinator. Owns the active GameState.
## Does NOT contain gameplay systems (economy, jobs, research, etc.).

const CONFIG := preload("res://scripts/core/game_config.gd")

signal company_created
signal ai_created

var game_version: String = CONFIG.VERSION
var _current_state: GameState


func _ready() -> void:
	initialize_new_game()
	print("Singularity Point v%s — Era %d" % [game_version, get_state().era])


## Returns the current active GameState. Single source of truth.
func get_state() -> GameState:
	return _current_state


## Creates a fresh GameState for a new playthrough.
func initialize_new_game() -> void:
	_current_state = GameState.new()
	_current_state.reset()


## Attempts to create a company with the given name and color.
## Returns true on success, false if validation fails.
func create_company(company_name: String, color: Color) -> bool:
	var state := get_state()
	var trimmed: String = company_name.strip_edges()

	if trimmed.is_empty():
		return false
	if trimmed.length() > GameConfig.MAX_COMPANY_NAME_LENGTH:
		return false

	state.company.name = trimmed
	state.company.founded = true
	state.company.company_id = _generate_company_id()
	state.company.primary_color = color
	state.phase = GamePhase.Phase.AI_CREATION
	company_created.emit()
	return true


## Attempts to create the AI with the given name and characteristic values.
## Returns true on success, false if validation fails.
func create_ai(ai_name: String, characteristics: Dictionary) -> bool:
	var state := get_state()
	var trimmed: String = ai_name.strip_edges()

	if trimmed.is_empty():
		return false
	if trimmed.length() > GameConfig.MAX_AI_NAME_LENGTH:
		return false

	var total: int = 0
	for id in AICharacteristic.get_all_ids():
		var val: int = characteristics.get(id, 0) as int
		if val < 0 or val > GameConfig.MAX_CHARACTERISTIC_VALUE:
			return false
		total += val

	if total != GameConfig.FOUNDATION_POINTS_TOTAL:
		return false

	var count_at_threshold: int = 0
	for id in AICharacteristic.get_all_ids():
		if characteristics[id] >= GameConfig.CHARACTERISTIC_THRESHOLD:
			count_at_threshold += 1
	if count_at_threshold < GameConfig.MIN_CHARACTERISTICS_AT_THRESHOLD:
		return false

	state.ai.name = trimmed
	state.ai.created = true
	state.ai.ai_id = _generate_ai_id()
	state.ai.visual_type = ":)"
	state.ai.foundation_points_total = GameConfig.FOUNDATION_POINTS_TOTAL
	state.ai.foundation_points_assigned = total
	state.ai.creation_timestamp = TimeManager.get_game_time()

	for id in AICharacteristic.get_all_ids():
		state.ai.characteristics[id] = characteristics[id]

	state.phase = GamePhase.Phase.MAIN_GAME
	ai_created.emit()
	return true


func _generate_company_id() -> String:
	return "COMP-%d-%04d" % [Time.get_ticks_msec(), randi() % 10000]


func _generate_ai_id() -> String:
	return "AI-%d-%04d" % [Time.get_ticks_msec(), randi() % 10000]
