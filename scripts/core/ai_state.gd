class_name AIState
extends RefCounted

## AI state.
## Represents the identity, foundation, and core characteristics of the AI.

var name: String = ""
var created: bool = false
var ai_id: String = ""
var visual_type: String = ":)"

## Foundation points tracking
var foundation_points_total: int = 12
var foundation_points_assigned: int = 0

## Core characteristics: Dictionary[int, int] mapping AICharacteristic.ID → value (0–5)
var characteristics: Dictionary = {}

## Timestamp from TimeManager when the AI was created
var creation_timestamp: float = 0.0


func _init() -> void:
	_reset_characteristics()


func reset() -> void:
	name = ""
	created = false
	ai_id = ""
	visual_type = ":)"
	foundation_points_total = 12
	foundation_points_assigned = 0
	creation_timestamp = 0.0
	_reset_characteristics()


func _reset_characteristics() -> void:
	characteristics.clear()
	for id in AICharacteristic.get_all_ids():
		characteristics[id] = 0


## Returns the value of a specific characteristic.
func get_characteristic(id: AICharacteristic.ID) -> int:
	return characteristics.get(id, 0) as int


## Sets a characteristic value, clamped to 0–max_value.
func set_characteristic(id: AICharacteristic.ID, value: int, max_value: int = 5) -> void:
	characteristics[id] = clampi(value, 0, max_value)


## Returns how many characteristics have a value >= threshold.
func count_characteristics_at_or_above(threshold: int) -> int:
	var count: int = 0
	for id in AICharacteristic.get_all_ids():
		if characteristics[id] >= threshold:
			count += 1
	return count
