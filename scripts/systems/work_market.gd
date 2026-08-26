class_name WorkMarket
extends RefCounted

## WorkMarket — Source of available Job instances for Era 0 (M06).
##
## Owns job templates. Does NOT execute jobs — JobManager does that.
## Templates are centralized in one table here so they can move to
## external .tres/JSON resources later (per canon Sec.39 data domains)
## without touching JobManager or Boot UI.
##
## [PENDING DECISION] Catalogue regenerates fully each refresh; there is
## no persistence, expiry, or procedural generation yet. Acceptable for
## M06 infrastructure scope — Stage 03 will define real job design and
## discovery rules.

var _next_sequence: int = 1


## Returns the Era 0 job catalogue as fresh Job instances.
func get_available_jobs() -> Array[Job]:
	var jobs: Array[Job] = []

	jobs.append(_make_job(
		Job.JobType.LOCAL_PROGRAMMING,
		"Fix Local Script Bug",
		"Debug and patch a small local script.",
		20.0 * 60.0,
		{"money": 80}
	))
	jobs.append(_make_job(
		Job.JobType.DATA_PROCESSING,
		"Clean Local Dataset",
		"Process and normalize a small local dataset.",
		15.0 * 60.0,
		{"money": 50, "knowledge": 1}
	))
	jobs.append(_make_job(
		Job.JobType.DOCUMENT_ANALYSIS,
		"Summarize Local Documents",
		"Read and summarize a batch of local documents.",
		25.0 * 60.0,
		{"money": 40, "knowledge": 2}
	))
	jobs.append(_make_job(
		Job.JobType.BASIC_AUTOMATION,
		"Automate Repetitive Task",
		"Write a script to automate a repetitive local task.",
		30.0 * 60.0,
		{"money": 100}
	))
	jobs.append(_make_job(
		Job.JobType.LOCAL_DIAGNOSTICS,
		"Run System Diagnostics",
		"Check local system health and report findings.",
		10.0 * 60.0,
		{"money": 30, "trust": 1}
	))

	return jobs


func _make_job(type: Job.JobType, title: String, description: String, duration_game_seconds: float, reward: Dictionary) -> Job:
	var job := Job.new()
	job.id = "JOB-%03d" % _next_sequence
	_next_sequence += 1
	job.title = title
	job.description = description
	job.type = type
	job.duration = duration_game_seconds
	job.reward = reward
	job.status = Job.Status.AVAILABLE
	return job
