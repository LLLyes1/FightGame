# M4 Balance Iteration Report

## Goal

The first M4 balance pass was not trying to reach final competitive balance.

It was trying to do three things:

1. keep existing archetypes readable
2. add one clearly distinct weapon
3. add one clearly distinct character without destabilizing the current build

## Final Expansion Additions

### Weapon: `halberd`

Target identity:

- mid-range control
- slower commitments
- stronger lane denial
- better anti-air coverage than saber
- less passive safety than hand_cannon

Key balance decisions:

- longer hitboxes than `saber`
- slower startup/recovery on high-value swings
- no projectile logic, so space control must come from positioning
- strong `up_ground`, `up_air`, and `special_up` to make anti-air identity obvious

### Character: `bastion`

Target identity:

- heavy anchor
- slower mobility
- higher knockback tolerance
- worse aerial correction and recovery freedom than `sky_drifter`

Key balance decisions:

- reduced `move_speed` and `air_speed`
- increased `weight` and `knockback_resistance`
- heavier gravity and shorter jumps
- slower, more committed dash timings

## Legacy Stability Decisions

This first M4 balance pass intentionally did **not** perform broad retuning on:

- `vanguard`
- `sky_drifter`
- `saber`
- `hand_cannon`
- global camera / HUD timing

Reason:

- the safest first production wave is to insert new archetypes without moving too many old baselines at once
- this keeps regression attribution clear when something goes wrong

## Current Archetype Read

### Characters

- `vanguard`: balanced standard
- `sky_drifter`: high-air-mobility specialist
- `bastion`: heavy anchor

### Weapons

- `saber`: short-range rushdown
- `hand_cannon`: long-range projectile control
- `halberd`: mid-range space control

## Balance Conclusion

The first M4 iteration succeeds if the roster now reads as:

- three distinct movement identities
- three distinct weapon rhythms
- no obviously duplicated archetype slot

Based on the implemented data pass and the automated matrix validation, that condition is met for this build.

## Next Tuning Targets

If the next balance pass reveals real play-feel issues, start here first:

1. `halberd` `heavy_ground` / `special_side` recovery if pressure proves too safe
2. `bastion` recovery routing if his return path is too weak to stay viable
3. `hand_cannon` reward values only if projectile control still invalidates the new mid-range lane game
