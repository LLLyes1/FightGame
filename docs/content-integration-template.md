# Content Integration Template

## Purpose

Use this template when adding a new character, a new weapon, or a new character/weapon pair to the project.

The goal of T8 is to make content expansion predictable:

1. data entry has a fixed shape
2. attack slot coverage stays complete
3. runtime validation happens before Godot-side playtest

## Runtime Flow

Current content enters the game through this chain:

1. `scripts/core/character_database.gd`
2. `scripts/core/weapon_database.gd`
3. `scripts/core/fighter_assembler.gd`
4. `scripts/core/fighter_catalog.gd` or the menu/loadout flow
5. `scripts/actors/fighter.gd` and `scripts/game/game_scene.gd`

## Reusable Template Helper

Use `scripts/core/content_templates.gd` as the canonical template source.

It provides:

- `build_character_template()`
- `build_weapon_template()`
- `build_attack_template()`
- `validate_character_entry()`
- `validate_weapon_entry()`

Recommended workflow:

1. copy the generated template shape
2. fill the real data
3. run the validator mentally or with a quick debug call before wiring the loadout into matches

## Character Entry Checklist

Each character entry should define:

- identity: `id`, `display_name`
- presentation: `primary_color`, `accent_color`, `movement_summary`
- ground movement: `move_speed`, `move_acceleration`, `move_brake`
- air movement: `air_speed`, `air_acceleration`
- gravity/fall: `gravity`, `max_fall_speed`, `fast_fall_speed`
- jump behavior: `jump_count`, `jump_velocity`, `double_jump_velocity`, `jump_buffer`, `coyote_time`
- trait behavior: `can_glide`, `glide_fall_speed`, `glide_horizontal_control`
- survivability: `weight`, `knockback_resistance`
- dash identity: `dash_profile_label`, `dash_config_overrides`

Minimal example:

```gdscript
{
	"id": "new_character",
	"display_name": "New Character",
	"primary_color": Color("8ecae6"),
	"accent_color": Color("ffb703"),
	"move_speed": 440.0,
	"air_speed": 390.0,
	"move_acceleration": 3000.0,
	"move_brake": 3400.0,
	"air_acceleration": 2200.0,
	"gravity": 2500.0,
	"jump_count": 2,
	"jump_velocity": -920.0,
	"double_jump_velocity": -900.0,
	"max_fall_speed": 1280.0,
	"fast_fall_speed": 1680.0,
	"coyote_time": 0.10,
	"jump_buffer": 0.12,
	"can_glide": false,
	"glide_fall_speed": 0.0,
	"glide_horizontal_control": 1.0,
	"weight": 1.0,
	"knockback_resistance": 1.0,
	"dash_profile_label": "Standard Dash",
	"dash_config_overrides": {},
	"movement_summary": "Describe the intended movement feel.",
}
```

## Weapon Entry Checklist

Each weapon entry should define:

- identity: `id`, `display_name`
- category: `weapon_type`, `is_ranged`, `range_class`
- player-facing summary: `attack_tempo_label`, `preview_summary`
- full attack slot coverage under `attacks`

Important distinction:

- weapon entry `weapon_type` currently uses project-level categories like `melee` or `ranged`
- attack entry `type` uses runtime behavior categories like `melee` or `projectile`

Required attack slots:

- `light_ground`
- `heavy_ground`
- `up_ground`
- `down_ground`
- `dash_attack`
- `neutral_air`
- `forward_air`
- `up_air`
- `down_air`
- `special_neutral`
- `special_side`
- `special_up`
- `special_down`

Each attack should define:

- `name`, `type`
- `startup`, `active`, `recovery`
- `movement_scale`
- `damage`
- `base_knockback`
- `knockback_growth`
- `launch_angle`
- `hitstun`
- `hitbox_offset`
- `hitbox_size`
- `lunge`

Projectile attacks must also define:

- `projectile_speed`
- `projectile_lifetime`

## Integration Steps

### Add a new character

1. Add a new entry to `scripts/core/character_database.gd`.
2. Keep the data schema aligned with `ContentTemplates.build_character_template()`.
3. Verify `dash_config_overrides` only changes values that really differ from the default dash profile.

### Add a new weapon

1. Add a new entry to `scripts/core/weapon_database.gd`.
2. Ensure all required attack slots exist, even if some are intentionally simple starter moves.
3. Make sure melee/projectile `type` values match the intended runtime behavior.

### Add a new loadout into selection or default tests

1. Create a loadout with `scripts/core/fighter_loadout.gd`.
2. Expose it through `scripts/core/fighter_catalog.gd` or the active selection flow.
3. Verify the HUD still reads the weapon/character labels correctly.

## Smoke Test Before Hand-off

Before declaring a new content drop usable:

1. Open the new entry and confirm required fields are complete.
2. Confirm every required weapon slot triggers a real move in battle.
3. Confirm projectile weapons spawn/hit correctly and melee weapons resolve hitboxes correctly.
4. Confirm the character's movement identity is visible in under 30 seconds of play.
5. Confirm no missing text, fallback IDs, or obviously default placeholder values remain.
