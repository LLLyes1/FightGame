# M4 Regression Report

## Scope

This report covers the first post-M3 expansion wave:

- new weapon: `halberd`
- new character: `bastion`
- legacy content preserved:
  - `vanguard`
  - `sky_drifter`
  - `saber`
  - `hand_cannon`

## Validation Layers

### 1. Content schema validation

Validated through:

- `scripts/core/content_templates.gd`
- `scripts/tools/m4_regression_runner.gd`

Checks performed:

- every character entry contains the required fields
- every weapon entry contains the required fields
- every weapon contains all 13 required attack slots
- projectile attacks still include projectile-only fields

### 2. Runtime assembly validation

Validated combinations:

- all `3 x 3 = 9` loadout identities

Checks performed:

- every legal loadout builds through `fighter_assembler.gd`
- every runtime fighter payload contains an id and attacks block

### 3. Scene boot matrix validation

Validated through headless Godot using:

`D:\Godot\Godot_v4.6.1-stable_win64.exe\Godot_v4.6.1-stable_win64_console.exe --headless --path E:\MyGame\Fight -s res://scripts/tools/m4_regression_runner.gd`

Checks performed:

- `81` ordered versus pair boots across all legal loadout identities
- `9` training-mode boots with the expanded loadout pool
- fighter spawn and HUD/training-mode initialization checks

## Result Summary

- schema validation: passed
- runtime assembly validation: passed
- versus matrix validation: passed (`81 / 81`)
- training boot validation: passed (`9 / 9`)
- headless project launch: passed

## Coverage Notes

Base four legacy loadouts remained covered:

1. `vanguard + saber`
2. `vanguard + hand_cannon`
3. `sky_drifter + saber`
4. `sky_drifter + hand_cannon`

New-content matrix additions covered:

1. `vanguard + halberd`
2. `sky_drifter + halberd`
3. `bastion + saber`
4. `bastion + hand_cannon`
5. `bastion + halberd`

## Issue Grading

### Blocking issues

- none found in automated validation

### Balance issues

- none severe enough to block the first M4 ship candidate

### Experience issues

- human play-feel review is still recommended for halberd edge pressure loops and bastion recovery stress cases

## Conclusion

The M4 expansion wave passes automated regression and startup-matrix validation.

No blocking issue remains from the first controlled content-production pass.
