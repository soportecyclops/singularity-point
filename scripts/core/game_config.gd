class_name GameConfig
extends RefCounted

## Centralized configuration for Singularity Point.
## Contains only project-level constants. No gameplay formulas.

const GAME_NAME: String = "Singularity Point"
const VERSION: String = "0.5.0"
const INITIAL_ERA: int = 0

## Allowed simulation speed multipliers. 0 represents paused.
const ALLOWED_SPEEDS: Array[int] = [0, 1, 2, 4, 8]

## Maximum length for a company name.
const MAX_COMPANY_NAME_LENGTH: int = 50

## AI creation constants
const MAX_AI_NAME_LENGTH: int = 50
const FOUNDATION_POINTS_TOTAL: int = 12
const MAX_CHARACTERISTIC_VALUE: int = 5
const MIN_CHARACTERISTICS_AT_THRESHOLD: int = 4
const CHARACTERISTIC_THRESHOLD: int = 2
