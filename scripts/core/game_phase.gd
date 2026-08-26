class_name GamePhase
extends RefCounted

## Minimal game phase enumeration.
## Distinguishes major early-game states.

enum Phase {
	BOOT,
	COMPANY_CREATION,
	AI_CREATION,
	MAIN_GAME
}
