class_name GameState
extends RefCounted

## GameState — The state of the current playthrough.
## Single source of truth for era, phase, company, and AI.
## Does NOT contain game time; TimeManager remains the time authority.

var era: int = 0
var phase: GamePhase.Phase = GamePhase.Phase.COMPANY_CREATION
var company: CompanyState
var ai: AIState


func _init() -> void:
	company = CompanyState.new()
	ai = AIState.new()


func reset() -> void:
	era = 0
	phase = GamePhase.Phase.COMPANY_CREATION
	company.reset()
	ai.reset()
