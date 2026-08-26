class_name LogTypes
extends RefCounted

## Enums de logging desacoplados del autoload Logger.
## Al ser una clase global normal (no autoload), su resolución estática
## no depende del orden de carga de [autoload] en project.godot.

enum Level {
	DEBUG,
	INFO,
	WARNING,
	ERROR,
	CRITICAL
}

enum Category {
	SYSTEM,
	GAME,
	TIME,
	COMPANY,
	AI,
	JOB,
	ECONOMY,
	UI,
	SAVE,
	LOAD
}
