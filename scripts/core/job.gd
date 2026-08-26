class_name Job
extends RefCounted

## Job — minimal data/state structure for a unit of AI work (M06 / Era 0).
##
## Scope per M06 Sec.18-19: id, title, description, type, duration,
## requirements, reward, risk, status. No economic balancing here —
## reward values are illustrative placeholders, not final numbers
## (Sec.25: economy is Stage 04).
##
## Status must never be ambiguous: use `status`, not scattered booleans
## (Sec.20). A RUNNING job cannot also be COMPLETED.

enum Status {
	AVAILABLE,
	QUEUED,
	RUNNING,
	COMPLETED,
	FAILED,
	CANCELLED,
}

## Era 0 job types only (M06 Sec.19). Advanced types (hacking, cyberattack,
## dark web, etc.) are explicitly deferred to later milestones.
enum JobType {
	LOCAL_PROGRAMMING,
	DATA_PROCESSING,
	DOCUMENT_ANALYSIS,
	BASIC_AUTOMATION,
	LOCAL_DIAGNOSTICS,
}

var id: String = ""
var title: String = ""
var description: String = ""
var type: JobType = JobType.LOCAL_PROGRAMMING

## Duration in GAME seconds (TimeManager's authoritative time unit).
var duration: float = 0.0

## Extensible, unused for gating in M06 (reserved for Stage 03 capability/era gating).
var requirements: Dictionary = {}

## Extensible reward bag, e.g. {"money": 100, "knowledge": 2}.
## NOT applied to any persistent resource pool yet — GameState has no
## resource fields until Stage 04. See JOB_MANAGER completion log.
var reward: Dictionary = {}

## 0..1 placeholder, not used in any formula yet (no balancing in M06).
var risk: float = 0.0

var status: Status = Status.AVAILABLE

## --- Runtime execution tracking (not part of the job "definition") ---
var _progress_game_seconds: float = 0.0
var _started_at_game_time: float = -1.0


static func get_type_name(t: JobType) -> String:
	match t:
		JobType.LOCAL_PROGRAMMING: return "LOCAL_PROGRAMMING"
		JobType.DATA_PROCESSING:   return "DATA_PROCESSING"
		JobType.DOCUMENT_ANALYSIS: return "DOCUMENT_ANALYSIS"
		JobType.BASIC_AUTOMATION:  return "BASIC_AUTOMATION"
		JobType.LOCAL_DIAGNOSTICS: return "LOCAL_DIAGNOSTICS"
		_: return "UNKNOWN"


static func get_status_name(s: Status) -> String:
	match s:
		Status.AVAILABLE: return "AVAILABLE"
		Status.QUEUED:    return "QUEUED"
		Status.RUNNING:   return "RUNNING"
		Status.COMPLETED: return "COMPLETED"
		Status.FAILED:    return "FAILED"
		Status.CANCELLED: return "CANCELLED"
		_: return "UNKNOWN"


func get_progress_ratio() -> float:
	if duration <= 0.0:
		return 1.0
	return clampf(_progress_game_seconds / duration, 0.0, 1.0)


## Compact dictionary for Logger context (see M06 Sec.8 example format).
func to_context() -> Dictionary:
	return {
		"job_id": id,
		"job_type": Job.get_type_name(type),
		"status": Job.get_status_name(status),
		"duration": duration,
		"reward": reward,
	}
