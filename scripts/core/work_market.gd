class_name WorkMarket
extends RefCounted

## WorkMarket — Defines and holds available job templates.
## Separated from JobManager to keep definitions independent from execution.

var available_jobs: Array[JobData] = []


func _init() -> void:
	_generate_initial_jobs()


func get_available_jobs() -> Array[JobData]:
	return available_jobs


func get_job_by_id(job_id: String) -> JobData:
	for job in available_jobs:
		if job.id == job_id:
			return job
	return null


func _generate_initial_jobs() -> void:
	available_jobs.clear()
	available_jobs.append(JobData.new(
		"JOB_001", "LOCAL_PROGRAMMING", "Code Review",
		"Review and refactor a small module.", 60.0,
		{"money": 80, "knowledge": 5}, "LOW"
	))
	available_jobs.append(JobData.new(
		"JOB_002", "DOCUMENT_ANALYSIS", "Software Analysis",
		"Analyze a small software project for bugs.", 120.0,
		{"money": 120, "knowledge": 10}, "LOW"
	))
	available_jobs.append(JobData.new(
		"JOB_003", "DATA_PROCESSING", "Data Sorting",
		"Sort and clean a dataset.", 90.0,
		{"money": 100, "knowledge": 8}, "LOW"
	))
	available_jobs.append(JobData.new(
		"JOB_004", "LOCAL_DIAGNOSTICS", "Pattern Recognition",
		"Identify patterns in a sample dataset.", 180.0,
		{"money": 150, "knowledge": 15}, "MEDIUM"
	))
	available_jobs.append(JobData.new(
		"JOB_005", "BASIC_AUTOMATION", "Script Automation",
		"Write a small automation script.", 240.0,
		{"money": 200, "knowledge": 12}, "MEDIUM"
	))
