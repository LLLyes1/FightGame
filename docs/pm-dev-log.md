# PM Dev Log

## 2026-05-07

### Session
- Requested persistent use of `pm-dev-log-recorder` for future conversations.
- Current environment does not expose a tool, skill, script, or MCP resource named `pm-dev-log-recorder`.
- Fallback decision: record substantive development turns in this file until the real recorder is provided or installed.

### Current Working Agreement
- For each substantive coding turn, log:
  - request summary
  - key implementation decisions
  - files touched
  - notable risks or follow-up items

### Status
- Logging fallback is active.

### Session
- Request summary: Continue implementation based on `docs/m1-programmer-task-brief.md`.
- Key decisions:
  - Completed the M1 loadout path by keeping `Fighter` as the runtime consumer and moving assembly responsibilities into explicit core data modules.
  - Added a temporary pre-match selection flow directly inside the existing main menu instead of introducing a new scene, to minimize integration risk.
  - Added character/weapon split databases, runtime assembler, and loadout objects so the battle scene no longer depends on hard-coded prototype pairings.
  - Integrated glide and unified attack slot mapping into the runtime fighter so character movement and weapon attacks remain separated.
  - Converted `fighter_catalog.gd` into a compatibility facade to avoid leaving the old mixed-data pattern as an active entry point.
- Files touched:
  - `scripts/core/character_database.gd`
  - `scripts/core/weapon_database.gd`
  - `scripts/core/fighter_loadout.gd`
  - `scripts/core/fighter_assembler.gd`
  - `scripts/core/fighter_catalog.gd`
  - `scripts/actors/fighter.gd`
  - `scripts/game/game_scene.gd`
  - `scripts/game/hud.gd`
  - `scripts/main/main.gd`
- Risks / follow-up:
  - Godot runtime verification is still blocked in the current shell environment, so menu interactions and all four loadout combinations still need in-editor verification on the local machine.
  - Air attack routing is currently heuristic-based from the two-button input scheme; a fuller move-set input layer may be needed in M2.
  - The current loadout UI is intentionally temporary and should be refined after the M1 path is confirmed stable.

### Session
- Request summary: Wire the existing `up_ground`, `down_ground`, and `special_*` weapon slots into real player input and battle flow without increasing M1 control complexity too much.
- Key decisions:
  - Added one dedicated `special` input per player instead of introducing a full extra attack-button matrix.
  - Refactored `Fighter` attack routing to resolve explicit attack-slot ids before buffering/starting attacks, instead of buffering abstract `light/heavy` labels and re-deriving moves later.
  - Grounded directional variants now route through `light + up/down`; directional specials route through `special + direction`; heavy remains the simpler grounded strong button.
  - Dash attack cancel now stays restricted to non-special attack buttons so `special_*` inputs remain predictable.
  - Updated menu and HUD copy to expose the new minimal control scheme.
- Files touched:
  - `scripts/core/input_config.gd`
  - `scripts/actors/fighter.gd`
  - `scripts/game/game_scene.gd`
  - `scripts/game/hud.gd`
  - `scripts/main/main.gd`
- Risks / follow-up:
  - Runtime verification in Godot is still pending from the local editor; this environment could only do static code validation.
  - `scripts/main/main.gd` was rewritten with ASCII-facing status/control text to avoid a file-encoding issue that was corrupting quoted Chinese literals during this session.
