class_name AICharacteristic
extends RefCounted

## Data-driven definition of AI core characteristics.
## Used by AIState and the creation UI to avoid hardcoding 8 times.

enum ID {
	INTELLIGENCE,
	EFFICIENCY,
	LEARNING,
	CREATIVITY,
	ADAPTABILITY,
	AUTONOMY,
	PERCEPTION,
	SOCIAL
}


static func get_display_name(id: ID) -> String:
	match id:
		ID.INTELLIGENCE: return "INTELLIGENCE"
		ID.EFFICIENCY:   return "EFFICIENCY"
		ID.LEARNING:     return "LEARNING"
		ID.CREATIVITY:   return "CREATIVITY"
		ID.ADAPTABILITY: return "ADAPTABILITY"
		ID.AUTONOMY:     return "AUTONOMY"
		ID.PERCEPTION:   return "PERCEPTION"
		ID.SOCIAL:       return "SOCIAL"
		_:               return "UNKNOWN"


static func get_all_ids() -> Array[ID]:
	return [
		ID.INTELLIGENCE,
		ID.EFFICIENCY,
		ID.LEARNING,
		ID.CREATIVITY,
		ID.ADAPTABILITY,
		ID.AUTONOMY,
		ID.PERCEPTION,
		ID.SOCIAL,
	]
