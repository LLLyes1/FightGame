# Regression Test Checklist

## Purpose

Use this checklist for every milestone build after combat, camera, stage, HUD, or content data changes.

T9 is complete when the team can run the same fixed self-test flow every time instead of relying on memory.

## Fixed Loadout Matrix

These four loadouts are the current baseline set:

1. `vanguard + saber`
2. `vanguard + hand_cannon`
3. `sky_drifter + saber`
4. `sky_drifter + hand_cannon`

## Recommended Test Order

### Pass A: Single-loadout smoke test

Run each of the four loadouts and confirm:

1. spawn is stable
2. ground move, jump, air movement, and dash work
3. `light_ground`, `heavy_ground`, `up_ground`, and `down_ground` all trigger correctly
4. `neutral_air`, `forward_air`, `up_air`, and `down_air` all trigger correctly
5. `special_neutral`, `special_side`, `special_up`, and `special_down` all trigger correctly
6. hit confirms produce readable HUD feedback
7. ring-out, respawn, and match-end flow still work

### Pass B: Pairing behavior test

Run these pairings:

1. `vanguard + saber` vs `sky_drifter + hand_cannon`
2. `vanguard + hand_cannon` vs `sky_drifter + saber`
3. mirror a melee-focused pacing check: `vanguard + saber` vs `sky_drifter + saber`
4. mirror a ranged-focused pacing check: `vanguard + hand_cannon` vs `sky_drifter + hand_cannon`

Confirm:

1. camera keeps both players readable at close and far distances
2. edge pressure and recovery are readable on the current stage
3. projectile and melee hit/receive flow both remain stable
4. no player gets stuck in platforms, hurt state, respawn, or match-end state

### Pass C: Training-mode readability test

In training mode verify:

1. loadout labels are correct
2. state, attack, jump, dash, velocity, timer, hit, and got fields update live
3. special attacks and directional ground attacks show the correct slot labels
4. recent landed-hit and received-hit summaries stay believable

## Result Recording Template

Use this block when recording a regression run:

```md
## YYYY-MM-DD - Regression Run
- Build/branch:
- Tester:
- Scope:
- Loadouts covered:
- Passed:
- Failed:
- Known issues:
- Follow-up:
```

## Blocking Failure Rules

Stop and fix before sign-off if any of these happen:

1. a required move slot does not trigger
2. a projectile never spawns or never resolves hit
3. camera loses a fighter during ordinary gameplay
4. ring-out or respawn soft-locks the match
5. HUD/debug text becomes misleading enough to break validation

## Exit Criteria

The current build is regression-stable when:

1. all four baseline loadouts complete Pass A
2. all four pair tests complete Pass B
3. training mode completes Pass C
4. no blocking failure remains open
