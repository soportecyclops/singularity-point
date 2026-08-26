# Singularity Point

## Current Milestone

Milestone 05 — AI Creation & Foundation Characteristics

## Status

Implemented / Pending Validation

## Completed

- [x] Godot 4 project foundation created (`project.godot`)
- [x] Clean directory structure
- [x] Centralized configuration script (`scripts/core/game_config.gd`)
- [x] GameManager autoload singleton (`scripts/core/game_manager.gd`)
- [x] TimeManager autoload singleton (`scripts/core/time_manager.gd`)
- [x] FPS-independent simulated clock
- [x] Pause / 1x / 2x / 4x / 8x speed controls
- [x] GameState foundation (`scripts/core/game_state.gd`)
- [x] CompanyState foundation (`scripts/core/company_state.gd`)
- [x] AIState foundation (`scripts/core/ai_state.gd`)
- [x] GamePhase enum (`scripts/core/game_phase.gd`)
- [x] Company creation flow with validation
- [x] Company ID generation, name, primary color
- [x] Phase-aware Boot scene (COMPANY_CREATION → AI_CREATION)
- [x] **AICharacteristic data-driven definitions (`scripts/core/ai_characteristic.gd`)**
- [x] **8 core characteristics: Intelligence, Efficiency, Learning, Creativity, Adaptability, Autonomy, Perception, Social**
- [x] **Foundation Points system (12 points, max 5 per characteristic)**
- [x] **AI creation validation (name, total=12, max<=5, min 4 traits >=2)**
- [x] **AI creation UI with +/- controls per characteristic**
- [x] **AIState extended with ai_id, visual_type, characteristics, foundation tracking, timestamp**
- [x] **Phase transition AI_CREATION → MAIN_GAME**
- [x] **Post-AI panel showing created AI**

## Not Implemented

The following systems are intentionally NOT present:

- Jobs / task assignment / job execution / job rewards
- Economy / resources (MONEY, COMPUTE, KNOWLEDGE, ACCESS, TRUST)
- AI experience / learning / memory / goals / autonomy behavior
- AI evolution tree / secondary branches / Eras / AGI / ASI
- Hardware / upgrades / Internet access / vulnerabilities / hacking
- Media / world events / other AI companies / competition / diplomacy
- Footprint / reputation system
- Save / load / autosave / cloud saves
- Multiplayer / networking / online services
- Final UI / audio / final graphics

## Architecture

```
res://
├── scenes/
│   └── boot/
│       ├── boot.tscn
│       └── boot.gd
├── scripts/
│   └── core/
│       ├── game_config.gd
│       ├── game_manager.gd
│       ├── time_manager.gd
│       ├── game_state.gd
│       ├── company_state.gd
│       ├── ai_state.gd
│       ├── game_phase.gd
│       └── ai_characteristic.gd
├── data/
├── assets/
│   ├── ui/
│   ├── sprites/
│   └── audio/
├── docs/
│   └── PROJECT_STATUS.md
├── tests/
├── .gitignore
└── project.godot
```

## State Architecture

```
GameManager (autoload)
    │
    └── _current_state: GameState
            │
            ├── era: int = 0
            ├── phase: GamePhase.Phase
            │
            ├── company: CompanyState
            │       ├── name, founded, company_id, primary_color
            │
            └── ai: AIState
                    ├── name, created, ai_id, visual_type
                    ├── foundation_points_total = 12
                    ├── foundation_points_assigned
                    ├── characteristics: Dictionary[ID → int]
                    └── creation_timestamp

TimeManager (autoload)
    │
    └── _total_game_seconds (authoritative simulation time)
```

## Current Version

0.5.0

## Current Era

Era 0

## Next Milestone

To be determined after Milestone 05 is validated.

## Important Development Rule

Future systems must not be implemented until their milestone is explicitly authorized.
