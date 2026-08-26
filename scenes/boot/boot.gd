extends Control

## Boot scene UI controller.
## Displays title, era, build info, simulation time controls,
## debug state, company creation form, post-company status,
## AI creation form, and post-AI status.
## Phase-aware: shows different content based on GamePhase.

# --- M02: Time UI ---
@onready var _time_label: Label = $VBoxContainer/TimeDisplay
@onready var _speed_buttons: Dictionary = {}

# --- M03: Debug Panel ---
@onready var _debug_era: Label = $VBoxContainer/DebugPanel/DebugEra
@onready var _debug_company: Label = $VBoxContainer/DebugPanel/DebugCompany
@onready var _debug_ai: Label = $VBoxContainer/DebugPanel/DebugAI

# --- M04: Company Creation ---
@onready var _speed_controls: HBoxContainer = $VBoxContainer/SpeedControls
@onready var _debug_panel: VBoxContainer = $VBoxContainer/DebugPanel
@onready var _company_creation_form: VBoxContainer = $VBoxContainer/CompanyCreationForm
@onready var _post_company_info: VBoxContainer = $VBoxContainer/PostCompanyInfo
@onready var _name_input: LineEdit = $VBoxContainer/CompanyCreationForm/CCNameInput
@onready var _color_picker: ColorPickerButton = $VBoxContainer/CompanyCreationForm/CCColorPicker
@onready var _error_label: Label = $VBoxContainer/CompanyCreationForm/CCError
@onready var _create_button: Button = $VBoxContainer/CompanyCreationForm/CCButton
@onready var _pc_name: Label = $VBoxContainer/PostCompanyInfo/PCName

# --- M05: AI Creation ---
@onready var _ai_creation_form: VBoxContainer = $VBoxContainer/AICreationForm
@onready var _ai_visual: Label = $VBoxContainer/AICreationForm/AIVisual
@onready var _ai_name_input: LineEdit = $VBoxContainer/AICreationForm/AINameInput
@onready var _ai_char_container: VBoxContainer = $VBoxContainer/AICreationForm/AICharacteristicsContainer
@onready var _ai_points_label: Label = $VBoxContainer/AICreationForm/AIPointsLabel
@onready var _ai_threshold_label: Label = $VBoxContainer/AICreationForm/AIThresholdLabel
@onready var _ai_error: Label = $VBoxContainer/AICreationForm/AIError
@onready var _ai_create_button: Button = $VBoxContainer/AICreationForm/AICreateButton
@onready var _post_ai_panel: VBoxContainer = $VBoxContainer/PostAIPanel
@onready var _pa_name: Label = $VBoxContainer/PostAIPanel/PAName

## Temporary characteristic values during AI creation. Dictionary[int, int]
var _ai_characteristic_values: Dictionary = {}


func _ready() -> void:
	_connect_signals()
	_setup_buttons()
	_setup_company_creation()
	_setup_ai_creation()
	_update_phase_ui()


func _connect_signals() -> void:
	TimeManager.time_changed.connect(_on_time_changed)
	TimeManager.speed_changed.connect(_on_speed_changed)
	TimeManager.pause_state_changed.connect(_on_pause_state_changed)
	GameManager.company_created.connect(_on_company_created)
	GameManager.ai_created.connect(_on_ai_created)


# --- M02: Speed Buttons ---
func _setup_buttons() -> void:
	var button_container: HBoxContainer = $VBoxContainer/SpeedControls
	for child in button_container.get_children():
		if child is Button:
			var speed: int = child.get_meta("speed", -1) as int
			if speed >= 0:
				_speed_buttons[speed] = child
				child.pressed.connect(_on_speed_button_pressed.bind(speed))


# --- M04: Company Creation ---
func _setup_company_creation() -> void:
	_create_button.pressed.connect(_on_create_company_pressed)
	_error_label.visible = false


func _on_create_company_pressed() -> void:
	var company_name: String = _name_input.text
	var color: Color = _color_picker.color
	var success: bool = GameManager.create_company(company_name, color)
	if not success:
		_error_label.text = "Invalid company name. Enter 1–%d characters." % GameConfig.MAX_COMPANY_NAME_LENGTH
		_error_label.visible = true
	else:
		_error_label.visible = false


func _on_company_created() -> void:
	_update_phase_ui()
	_update_debug_panel()
	_update_post_company_panel()


# --- M05: AI Creation ---
func _setup_ai_creation() -> void:
	_ai_create_button.pressed.connect(_on_create_ai_pressed)
	_ai_error.visible = false
	_reset_ai_characteristics()
	_build_ai_characteristic_rows()
	_update_ai_creation_ui()


func _reset_ai_characteristics() -> void:
	_ai_characteristic_values.clear()
	for id in AICharacteristic.get_all_ids():
		_ai_characteristic_values[id] = 0


func _build_ai_characteristic_rows() -> void:
	# Clear existing children
	for child in _ai_char_container.get_children():
		child.queue_free()

	for id in AICharacteristic.get_all_ids():
		var row := HBoxContainer.new()
		row.alignment = BoxContainer.ALIGNMENT_CENTER

		var name_label := Label.new()
		name_label.text = AICharacteristic.get_display_name(id)
		name_label.custom_minimum_size = Vector2(140, 0)
		row.add_child(name_label)

		var value_label := Label.new()
		value_label.name = "ValueLabel_%d" % id
		value_label.text = "0 / 5"
		value_label.custom_minimum_size = Vector2(60, 0)
		value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		row.add_child(value_label)

		var minus_btn := Button.new()
		minus_btn.text = "-"
		minus_btn.custom_minimum_size = Vector2(30, 30)
		minus_btn.pressed.connect(_on_ai_char_changed.bind(id, -1))
		row.add_child(minus_btn)

		var plus_btn := Button.new()
		plus_btn.text = "+"
		plus_btn.custom_minimum_size = Vector2(30, 30)
		plus_btn.pressed.connect(_on_ai_char_changed.bind(id, 1))
		row.add_child(plus_btn)

		_ai_char_container.add_child(row)


func _on_ai_char_changed(id: AICharacteristic.ID, delta: int) -> void:
	var current: int = _ai_characteristic_values.get(id, 0) as int
	var new_val: int = clampi(current + delta, 0, GameConfig.MAX_CHARACTERISTIC_VALUE)
	_ai_characteristic_values[id] = new_val
	_update_ai_creation_ui()


func _update_ai_creation_ui() -> void:
	var assigned: int = 0
	for id in AICharacteristic.get_all_ids():
		assigned += _ai_characteristic_values[id] as int
	var remaining: int = GameConfig.FOUNDATION_POINTS_TOTAL - assigned
	var count_at_threshold: int = 0
	for id in AICharacteristic.get_all_ids():
		if _ai_characteristic_values[id] >= GameConfig.CHARACTERISTIC_THRESHOLD:
			count_at_threshold += 1

	_ai_points_label.text = "Assigned: %d / %d  |  Remaining: %d" % [
		assigned, GameConfig.FOUNDATION_POINTS_TOTAL, remaining
	]
	_ai_threshold_label.text = "Core Traits >= %d: %d / %d" % [
		GameConfig.CHARACTERISTIC_THRESHOLD, count_at_threshold, GameConfig.MIN_CHARACTERISTICS_AT_THRESHOLD
	]

	# Update value labels in rows
	for id in AICharacteristic.get_all_ids():
		var row = _ai_char_container.get_child(id)
		if row:
			var val_label: Label = row.get_node("ValueLabel_%d" % id)
			if val_label:
				val_label.text = "%d / %d" % [_ai_characteristic_values[id], GameConfig.MAX_CHARACTERISTIC_VALUE]

	# Validate for button enablement
	var name_ok: bool = not _ai_name_input.text.strip_edges().is_empty()
	var points_ok: bool = assigned == GameConfig.FOUNDATION_POINTS_TOTAL
	var threshold_ok: bool = count_at_threshold >= GameConfig.MIN_CHARACTERISTICS_AT_THRESHOLD
	_ai_create_button.disabled = not (name_ok and points_ok and threshold_ok)

	if not name_ok:
		_ai_error.text = "Enter an AI name."
		_ai_error.visible = true
	elif not points_ok:
		_ai_error.text = "Assign exactly %d Foundation Points." % GameConfig.FOUNDATION_POINTS_TOTAL
		_ai_error.visible = true
	elif not threshold_ok:
		_ai_error.text = "Need at least %d core characteristics at %d or higher." % [
			GameConfig.MIN_CHARACTERISTICS_AT_THRESHOLD, GameConfig.CHARACTERISTIC_THRESHOLD
		]
		_ai_error.visible = true
	else:
		_ai_error.text = "AI CONFIGURATION VALID"
		_ai_error.add_theme_color_override("font_color", Color(0.4, 1.0, 0.4))
		_ai_error.visible = true


func _on_create_ai_pressed() -> void:
	var ai_name: String = _ai_name_input.text
	var success: bool = GameManager.create_ai(ai_name, _ai_characteristic_values.duplicate())
	if not success:
		_ai_error.text = "Invalid AI configuration. Check requirements."
		_ai_error.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))
		_ai_error.visible = true


func _on_ai_created() -> void:
	_update_phase_ui()
	_update_debug_panel()
	_update_post_ai_panel()


func _update_post_ai_panel() -> void:
	var state: GameState = GameManager.get_state()
	_pa_name.text = state.ai.name


# --- Phase UI ---
func _update_phase_ui() -> void:
	var phase: GamePhase.Phase = GameManager.get_state().phase
	match phase:
		GamePhase.Phase.COMPANY_CREATION:
			_time_label.visible = false
			_speed_controls.visible = false
			_debug_panel.visible = false
			_company_creation_form.visible = true
			_post_company_info.visible = false
			_ai_creation_form.visible = false
			_post_ai_panel.visible = false
		GamePhase.Phase.AI_CREATION:
			_time_label.visible = true
			_speed_controls.visible = true
			_debug_panel.visible = true
			_company_creation_form.visible = false
			_post_company_info.visible = true
			_ai_creation_form.visible = true
			_post_ai_panel.visible = false
			_update_time_display(
				TimeManager.get_day(),
				TimeManager.get_hour(),
				TimeManager.get_minute(),
				TimeManager.get_second()
			)
			_highlight_current_speed()
		GamePhase.Phase.MAIN_GAME:
			_time_label.visible = true
			_speed_controls.visible = true
			_debug_panel.visible = true
			_company_creation_form.visible = false
			_post_company_info.visible = false
			_ai_creation_form.visible = false
			_post_ai_panel.visible = true
			_update_time_display(
				TimeManager.get_day(),
				TimeManager.get_hour(),
				TimeManager.get_minute(),
				TimeManager.get_second()
			)
			_highlight_current_speed()
		_:
			_time_label.visible = true
			_speed_controls.visible = true
			_debug_panel.visible = true
			_company_creation_form.visible = false
			_post_company_info.visible = false
			_ai_creation_form.visible = false
			_post_ai_panel.visible = false


# --- M04: Post-Company Panel ---
func _update_post_company_panel() -> void:
	var state: GameState = GameManager.get_state()
	_pc_name.text = state.company.name
	_pc_name.modulate = state.company.primary_color


# --- M02: Speed Controls ---
func _on_speed_button_pressed(speed: int) -> void:
	if speed == 0:
		TimeManager.toggle_pause()
	else:
		TimeManager.resume()
		TimeManager.set_speed(speed)


func _on_time_changed(day: int, hour: int, minute: int, second: int) -> void:
	_update_time_display(day, hour, minute, second)


func _update_time_display(day: int, hour: int, minute: int, second: int) -> void:
	_time_label.text = "DAY %d\n%02d:%02d:%02d" % [day, hour, minute, second]


# --- M03: Debug Panel ---
func _update_debug_panel() -> void:
	var state: GameState = GameManager.get_state()
	_debug_era.text = "Era: %d" % state.era
	_debug_company.text = "Company: %s" % (state.company.name if state.company.founded else "Not Founded")
	_debug_ai.text = "AI: %s" % (state.ai.name if state.ai.created else "Not Created")


# --- M02: Speed Highlight ---
func _on_speed_changed(_speed: int) -> void:
	_highlight_current_speed()


func _on_pause_state_changed(paused: bool) -> void:
	_highlight_current_speed()
	if paused:
		_speed_buttons[0].text = "RESUME"
	else:
		_speed_buttons[0].text = "PAUSE"


func _highlight_current_speed() -> void:
	var active_speed: int = 0 if TimeManager.is_paused() else TimeManager.get_speed()
	for speed in _speed_buttons:
		var button: Button = _speed_buttons[speed]
		if speed == active_speed:
			button.modulate = Color(0.4, 1.0, 0.4)
		else:
			button.modulate = Color(1.0, 1.0, 1.0)
