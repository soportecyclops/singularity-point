extends Node

## TimeManager — Centralized game-time simulation.
## FPS-independent. Provides time, speed control, and pause.
## Other systems consume time; this manager contains no gameplay logic.

signal time_changed(day: int, hour: int, minute: int, second: int)
signal speed_changed(speed: int)
signal pause_state_changed(paused: bool)

const SECONDS_PER_DAY: int = 86400
const INITIAL_TOTAL_SECONDS: float = 9.0 * 3600.0  ## Day 1, 09:00:00

var _total_game_seconds: float = INITIAL_TOTAL_SECONDS
var _speed_multiplier: int = 1
var _paused: bool = false

var _last_displayed_second: int = -1


func _ready() -> void:
	_update_display_time()


func _process(delta: float) -> void:
	if _paused or _speed_multiplier == 0:
		return

	_total_game_seconds += delta * _speed_multiplier
	_update_display_time()


func _update_display_time() -> void:
	var current_second: int = int(_total_game_seconds)
	if current_second != _last_displayed_second:
		_last_displayed_second = current_second
		var day: int = current_second / SECONDS_PER_DAY + 1
		var rem: int = current_second % SECONDS_PER_DAY
		var hour: int = rem / 3600
		var minute: int = (rem % 3600) / 60
		var second: int = rem % 60
		time_changed.emit(day, hour, minute, second)


func get_game_time() -> float:
	return _total_game_seconds


func get_day() -> int:
	return int(_total_game_seconds) / SECONDS_PER_DAY + 1


func get_hour() -> int:
	var rem: int = int(_total_game_seconds) % SECONDS_PER_DAY
	return rem / 3600


func get_minute() -> int:
	var rem: int = int(_total_game_seconds) % SECONDS_PER_DAY
	return (rem % 3600) / 60


func get_second() -> int:
	var rem: int = int(_total_game_seconds) % SECONDS_PER_DAY
	return rem % 60


func get_speed() -> int:
	return _speed_multiplier


func is_paused() -> bool:
	return _paused


func set_speed(multiplier: int) -> void:
	if multiplier not in GameConfig.ALLOWED_SPEEDS:
		push_warning("TimeManager: invalid speed %d, ignoring." % multiplier)
		return

	if _speed_multiplier == multiplier:
		return

	_speed_multiplier = multiplier
	speed_changed.emit(_speed_multiplier)


func pause() -> void:
	if _paused:
		return
	_paused = true
	pause_state_changed.emit(true)


func resume() -> void:
	if not _paused:
		return
	_paused = false
	pause_state_changed.emit(false)


func toggle_pause() -> void:
	if _paused:
		resume()
	else:
		pause()
