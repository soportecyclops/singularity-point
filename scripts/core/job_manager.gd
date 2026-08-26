extends Node

## JobManager — Owns Job lifecycle: availability, start, progress, completion.
##
## Consumes TimeManager's central time signal; does NOT run its own clock
## (M06 Sec.41). Coordinates with WorkMarket for the job catalogue.
## Does NOT apply rewards to any persistent resource pool — GameState has
## no resource fields yet (Stage 04 / economy). Rewards are computed and
## logged only. This is a [PENDING DECISION] to revisit in Stage 04.
##
## GameManager remains the high-level coordinator; JobManager is a
## specialized system and must not be folded into GameManager (Sec.28).

signal job_started(job: Job)
signal job_progress_changed(job: Job, progress_ratio: float)
signal job_completed(job: Job)
signal job_failed(job: Job, reason: String)
signal job_cancelled(job: Job)
signal available_jobs_changed(jobs: Array[Job])

## Era 0: one AI, one simultaneous task (canon Sec.9 / M06 Sec.22).
const WORK_CAPACITY: int = 1

var _work_market: WorkMarket
var _available_jobs: Array[Job] = []
var _running_jobs: Array[Job] = []


func _ready() -> void:
	_work_market = WorkMarket.new()
	refresh_available_jobs()
	TimeManager.game_time_advanced.connect(_on_game_time_advanced)


func refresh_available_jobs() -> void:
	_available_jobs = _work_market.get_available_jobs()
	available_jobs_changed.emit(_available_jobs)


func get_available_jobs() -> Array[Job]:
	return _available_jobs


func get_running_jobs() -> Array[Job]:
	return _running_jobs


func get_used_capacity() -> int:
	return _running_jobs.size()


func get_free_capacity() -> int:
	return max(0, WORK_CAPACITY - get_used_capacity())


## Attempts to start a job by id. Returns true on success, false otherwise.
## Fully validates before mutating any state (atomic, Sec.34).
func start_job(job_id: String) -> bool:
	if job_id == null or job_id.is_empty():
		Logger.error("JOB", "JobManager", "start_job called with empty id")
		return false

	var job: Job = _find_available_job(job_id)
	if job == null:
		Logger.error("JOB", "JobManager", "start_job: job not found or not available", {"job_id": job_id})
		return false

	if get_free_capacity() <= 0:
		Logger.warning("JOB", "JobManager", "start_job: no free capacity", {"job_id": job_id})
		return false

	# All validation passed — now mutate state atomically.
	_available_jobs.erase(job)
	job.status = Job.Status.RUNNING
	job._progress_game_seconds = 0.0
	job._started_at_game_time = TimeManager.get_game_time()
	_running_jobs.append(job)

	job_started.emit(job)
	available_jobs_changed.emit(_available_jobs)
	Logger.info("JOB", "JobManager", "Job started", job.to_context())
	return true


## Cancels a currently running job. Returns true on success.
func cancel_job(job_id: String) -> bool:
	if job_id == null or job_id.is_empty():
		Logger.error("JOB", "JobManager", "cancel_job called with empty id")
		return false

	var job: Job = _find_running_job(job_id)
	if job == null:
		Logger.error("JOB", "JobManager", "cancel_job: job not running", {"job_id": job_id})
		return false

	_running_jobs.erase(job)
	job.status = Job.Status.CANCELLED
	job_cancelled.emit(job)
	Logger.info("JOB", "JobManager", "Job cancelled", job.to_context())
	return true


func _on_game_time_advanced(delta_game_seconds: float) -> void:
	if _running_jobs.is_empty():
		return

	# Iterate a snapshot: completion mutates _running_jobs mid-loop.
	for job: Job in _running_jobs.duplicate():
		if job.status != Job.Status.RUNNING:
			continue  # fail-safe: never advance/complete a job twice

		job._progress_game_seconds += delta_game_seconds
		job_progress_changed.emit(job, job.get_progress_ratio())

		if job._progress_game_seconds >= job.duration:
			_complete_job(job)


func _complete_job(job: Job) -> void:
	if job.status != Job.Status.RUNNING:
		return  # fail-safe: a job can only complete once (Sec.36)

	job.status = Job.Status.COMPLETED
	_running_jobs.erase(job)

	job_completed.emit(job)
	Logger.info("JOB", "JobManager", "Job completed", job.to_context())

	refresh_available_jobs()


func _find_available_job(job_id: String) -> Job:
	for job: Job in _available_jobs:
		if job.id == job_id:
			return job
	return null


func _find_running_job(job_id: String) -> Job:
	for job: Job in _running_jobs:
		if job.id == job_id:
			return job
	return null
