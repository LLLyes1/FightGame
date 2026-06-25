# Tuning Parameter Hub

## Purpose

T10 is being fulfilled through a parameter centralization approach instead of a separate in-game editor panel.

The rule is simple:

1. global feel knobs live in one runtime hub
2. character identity lives in character data
3. weapon identity lives in weapon data
4. dash defaults live in dash config defaults

## Primary Tuning Files

### Global runtime hub

File: `scripts/core/tuning_hub.gd`

Use this for values that affect the whole game rather than one specific character or one specific weapon.

Current groups:

- `CAMERA`
- `MATCH_FLOW`
- `HUD_FEEDBACK`
- `FIGHTER_RUNTIME`

### Character-level movement tuning

File: `scripts/core/character_database.gd`

Use this for:

- movement speed
- acceleration and brake
- gravity and fall speeds
- jump counts and jump velocities
- glide capability
- weight and knockback resistance
- character-specific dash overrides

### Weapon-level combat tuning

File: `scripts/core/weapon_database.gd`

Use this for:

- startup / active / recovery
- movement scale during attacks
- damage and knockback
- launch angle and hitstun
- hitbox size and offset
- projectile speed and lifetime

### Dash-system defaults

File: `scripts/core/dash_config.gd`

Use this for universal dash behavior shared by characters before character-specific overrides apply.

## Fast Mapping: What To Edit

If you want to tune one of these behaviors, start here:

| Goal | File | Field / group |
| --- | --- | --- |
| Camera too tight or too loose | `scripts/core/tuning_hub.gd` | `CAMERA.margin`, `CAMERA.close_zoom`, `CAMERA.far_zoom` |
| Camera too snappy or too slow | `scripts/core/tuning_hub.gd` | `CAMERA.position_smoothing_speed`, `CAMERA.move_lerp_speed`, `CAMERA.zoom_lerp_speed` |
| Start / KO / result messages too long or too short | `scripts/core/tuning_hub.gd` | `MATCH_FLOW` |
| Combat callout colors or sizes feel wrong | `scripts/core/tuning_hub.gd` | `HUD_FEEDBACK` |
| Short-hop / full-hop release feel is off | `scripts/core/tuning_hub.gd` | `FIGHTER_RUNTIME.jump_release_velocity_ratio` |
| Buffered attacks feel too sticky or too strict | `scripts/core/tuning_hub.gd` | `FIGHTER_RUNTIME.attack_buffer_seconds` |
| Hit flash is too weak or too strong | `scripts/core/tuning_hub.gd` | `FIGHTER_RUNTIME.heavy_hit_flash_seconds`, `default_hit_flash_seconds`, blend values |
| One character is too floaty / too heavy | `scripts/core/character_database.gd` | movement, gravity, weight fields |
| One weapon is too safe / too explosive | `scripts/core/weapon_database.gd` | attack frame data and knockback fields |
| Dash feels too privileged or too weak across the whole cast | `scripts/core/dash_config.gd` | default dash config |

## Safe Tuning Workflow

1. change only one tuning layer at a time
2. prefer `tuning_hub.gd` first for global feel changes
3. prefer `character_database.gd` for identity changes
4. prefer `weapon_database.gd` for move-specific changes
5. run the regression checklist after every meaningful tuning pass

## Important Guardrails

1. Do not tune the same behavior in both the global hub and per-character data unless the split is intentional.
2. Do not patch around a weapon problem by changing camera or HUD values.
3. Do not patch around a character identity problem by changing universal fighter runtime values.
4. When a new parameter gets added during future work, place it in the smallest correct layer instead of scattering another magic number into runtime code.
