extends Node

## Logger — Centralized diagnostic logging (M06).
##
## Dependency direction (see M06 Sec.9 / Sec.10):
##   TimeManager  ->  Logger  ->  GameManager / JobManager
## Logger reads TimeManager for game-time timestamps but is never called
## from TimeManager._ready() or TimeManager._init(), so there is no
## initialization-order deadlock even though both singletons reference
## each other's methods at runtime.
##
## Logger must never depend on GameManager or JobManager.

enum Level { DEBUG, INFO, WARNING, ERROR }

const LEVEL_NAMES := {
	Level.DEBUG: "DEBUG",
	Level.INFO: "INFO",
	Level.WARNING: "WARNING",
	Level.ERROR: "ERROR",
}

## Minimum level that gets printed. Kept at DEBUG during M06 development.
var min_level: int = Level.DEBUG

## In-memory ring buffer of recent entries (future debug UI / export hook).
var _history: Array[Dictionary] = []
const MAX_HISTORY: int = 500


func debug(category: String, system: String, message: String, context: Dictionary = {}) -> void:
	_log(Level.DEBUG, category, system, message, context)


func info(category: String, system: String, message: String, context: Dictionary = {}) -> void:
	_log(Level.INFO, category, system, message, context)


func warning(category: String, system: String, message: String, context: Dictionary = {}) -> void:
	_log(Level.WARNING, category, system, message, context)


func error(category: String, system: String, message: String, context: Dictionary = {}) -> void:
	_log(Level.ERROR, category, system, message, context)


func _log(level: int, category: String, system: String, message: String, context: Dictionary) -> void:
	if level < min_level:
		return

	var real_time: String = Time.get_datetime_string_from_system(false, true)
	var game_time_str: String = _get_game_time_string()
	var level_name: String = LEVEL_NAMES.get(level, "?")

	var entry := {
		"real_time": real_time,
		"game_time": game_time_str,
		"level": level_name,
		"category": category,
		"system": system,
		"message": message,
		"context": context,
	}

	_history.append(entry)
	if _history.size() > MAX_HISTORY:
		_history.pop_front()

	var line := "[%s] [GAME_TIME %s] [%s] [%s] [%s] %s" % [
		real_time, game_time_str, level_name, category, system, message
	]
	if not context.is_empty():
		line += "\n%s" % JSON.stringify(context, "    ")

	match level:
		Level.ERROR:
			printerr(line)
		Level.WARNING:
			print(line)
			push_warning(line)
		_:
			print(line)


## Defensive: TimeManager is expected to exist (loaded before Logger in
## autoload order), but we never assume a singleton is fully usable just
## because it exists in the tree.
func _get_game_time_string() -> String:
	if not (TimeManager and TimeManager.has_method("get_day")):
		return "D0 00:00:00"
	var day: int = TimeManager.get_day()
	var hour: int = TimeManager.get_hour()
	var minute: int = TimeManager.get_minute()
	var second: int = TimeManager.get_second()
	return "D%d %02d:%02d:%02d" % [day, hour, minute, second]


## Returns the most recent `count` log entries (oldest to newest).
## Intended for a future in-game log viewer; unused by the M06 debug panel.
func get_history(count: int = 50) -> Array[Dictionary]:
	var start: int = max(0, _history.size() - count)
	return _history.slice(start, _history.size())
