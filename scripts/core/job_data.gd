class_name JobData
extends RefCounted

## Data container for a single job definition and its execution state.

enum Status {
	AVAILABLE,
	QUEUED,
	RUNNING,
	COMPLETED,
	FAILED,
	CANCELLED
}

var id: String = ""
var type: String = ""  ## LOCAL_PROGRAMMING, DATA_PROCESSING, DOCUMENT_ANALYSIS, BASIC_AUTOMATION, LOCAL_DIAGNOSTICS
var title: String = ""
var description: String = ""
var duration_seconds: float = 0.0
var requirements: Dictionary = {}
var rewards: Dictionary = {}  ## {"money": 100, "knowledge": 2} etc.
var risk_level: String = "LOW"  ## LOW, MEDIUM, HIGH

var status: Status = Status.AVAILABLE
var start_time: float = 0.0


func _init(p_id: String, p_type: String, p_title: String, p_desc: String,
		   p_duration: float, p_rewards: Dictionary, p_risk: String) -> void:
	id = p_id
	type = p_type
	title = p_title
	description = p_desc
	duration_seconds = p_duration
	rewards = p_rewards.duplicate()
	risk_level = p_risk


func get_risk_color() -> Color:
	match risk_level:
		"LOW":    return Color(0.4, 1.0, 0.4)
		"MEDIUM": return Color(1.0, 1.0, 0.4)
		"HIGH":   return Color(1.0, 0.4, 0.4)
		_:        return Color.WHITE


func get_reward_money() -> int:
	return int(rewards.get("money", 0))


func get_reward_knowledge() -> int:
	return int(rewards.get("knowledge", 0))
