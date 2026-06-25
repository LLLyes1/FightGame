# Programming Log

## 2026-06-24 17:50 - Implement the first M6 weapon-family gameplay slice
- Request: Complete the new weapon requirements recorded in the planning log.
- Completed: Added bottom-layer support for projectile burst firing, returning projectiles, and guard-style defensive specials; rebuilt the weapon database into structured weapon builders; shipped the new `shield`, `pistol`, `rifle`, and `sniper` weapons alongside the existing roster; and updated menu/HUD copy so the new family tags and shield-defense behavior are visible in the current prototype.
- Outputs: A playable first M6 weapon-family pass with one shield archetype, three differentiated firearm variants, guard feedback callouts, and expanded weapon-card metadata.
- Files: `scripts/actors/fighter.gd`, `scripts/actors/projectile.gd`, `scripts/core/weapon_database.gd`, `scripts/core/fighter_assembler.gd`, `scripts/game/game_scene.gd`, `scripts/game/hud.gd`, `scripts/main/main.gd`, `docs/planning-log.md`, `docs/programming-log.md`.
- Verification: Godot headless startup succeeded with `D:\Godot\Godot_v4.6.1-stable_win64.exe\Godot_v4.6.1-stable_win64_console.exe --headless --path E:\MyGame\Fight --quit-after 1`; `res://scripts/tools/m5_regression_runner.gd` passed with `441` versus pairs and `21` training cases after the weapon-pool expansion.
- Next: Run in-editor playtests focused on shield guard timing, rifle burst pressure, pistol movement safety, and sniper punish windows, then tune damage/recovery/return timing based on those findings.

## 2026-06-24 17:44 - Build the first character and weapon editor menu
- Request: Add a character editor interface where the player can choose their character and weapon.
- Completed: Replaced the old dropdown-based loadout picker in the main menu with a dedicated editor layout that lets the user switch between player slots, choose characters and weapons from card-like selection panels, and view a live summary of the active loadout plus both players' current configurations.
- Outputs: The main menu now behaves like a first-pass loadout editor instead of a simple text form, while preserving the existing versus/training launch flow.
- Files: `scenes/main/main.tscn`, `scripts/main/main.gd`, `docs/programming-log.md`.
- Verification: Godot headless startup succeeded with `D:\Godot\Godot_v4.6.1-stable_win64.exe\Godot_v4.6.1-stable_win64_console.exe --headless --path E:\MyGame\Fight --quit-after 1`.
- Next: If the interface direction is accepted, the next step is to turn the current text-based cards into richer UI with portraits, weapon icons, and map-selection support.

## 2026-06-24 17:34 - Implement the M5 stabilization pass
- Request: Complete all M5 tasks.
- Completed: Reworked the menu and HUD to better support manual playtesting, refreshed the Chinese-facing main menu layout, tuned `halberd` edge-control risk and `bastion` recovery usability with small data-only changes, added a dedicated `m5_regression_runner.gd`, and produced the full M5 document bundle for manual validation, roster baselining, and the next-wave gate review.
- Outputs: Stronger pre-match loadout previews, clearer training/versus HUD messaging, first-pass M5 data tuning for `halberd` and `bastion`, `scripts/tools/m5_regression_runner.gd`, and the five M5 phase documents.
- Files: `project.godot`, `scenes/main/main.tscn`, `scripts/main/main.gd`, `scripts/game/hud.gd`, `scripts/game/game_scene.gd`, `scripts/core/character_database.gd`, `scripts/core/weapon_database.gd`, `scripts/tools/m5_regression_runner.gd`, `docs/m5-manual-playtest-script.md`, `docs/m5-manual-playtest-report.md`, `docs/m5-roster-observation-matrix.md`, `docs/m5-roster-balance-report.md`, `docs/m5-next-wave-gate-review.md`, `docs/planning-log.md`, `docs/programming-log.md`.
- Verification: Godot headless boot succeeded with `D:\Godot\Godot_v4.6.1-stable_win64.exe\Godot_v4.6.1-stable_win64_console.exe --headless --path E:\MyGame\Fight --quit-after 1`; `res://scripts/tools/m5_regression_runner.gd` passed with `81` versus pairs and `9` training cases.
- Next: Use the prepared manual playtest script to run a real nine-loadout human validation pass, then update the gate review based on those results.

## 2026-06-24 11:02 - 全面汉化当前可见游戏界面
- Request: 把游戏显示的 UI 全部换成中文，不要英文。
- Completed: 将主菜单、对战内 HUD、训练提示、暂停提示、战斗播报、角色/武器显示名与招式显示名统一切换为中文，并补上运行时兜底文本，避免 HUD 继续直接暴露 `special_*`、`forward_air` 这类内部槽位名。
- Outputs: 当前原型中玩家能直接看到的主菜单、状态栏、战斗播报、训练读数和招式名已统一为中文展示。
- Files: `project.godot`, `scenes/main/main.tscn`, `scripts/main/main.gd`, `scripts/game/game_scene.gd`, `scripts/game/hud.gd`, `scripts/actors/fighter.gd`, `scripts/actors/projectile.gd`, `scripts/core/character_database.gd`, `scripts/core/weapon_database.gd`.
- Verification: Godot headless 启动校验通过：`D:\Godot\Godot_v4.6.1-stable_win64.exe\Godot_v4.6.1-stable_win64_console.exe --headless --path E:\MyGame\Fight --quit-after 1`。
- Next: 如果继续打磨，可以再做一轮人工进编辑器巡检，重点确认长文本在主菜单、训练 HUD 和暂停面板里没有换行拥挤或截断。

## 2026-06-24 10:47 - Complete M4 content expansion and balance iteration
- Request: Complete all M4 content.
- Completed: Rebuilt the character and weapon databases into clean stable runtime data, added the new `halberd` weapon and `bastion` character, created an automated M4 regression runner that validates schema, runtime assembly, and scene boot across the expanded loadout matrix, and documented the positioning, regression, balance, and known-issues outcomes for the first production wave.
- Outputs: The project now ships M4 with three characters, three weapons, automated validation for `81` versus pair boots plus `9` training cases, and a full first-wave documentation bundle for regression and balance iteration.
- Files: `scripts/core/character_database.gd`, `scripts/core/weapon_database.gd`, `scripts/tools/m4_regression_runner.gd`, `docs/m4-weapon-positioning.md`, `docs/m4-character-positioning.md`, `docs/m4-regression-report.md`, `docs/m4-balance-iteration-report.md`, `docs/m4-known-issues.md`, `docs/planning-log.md`, `docs/programming-log.md`.
- Verification: Godot headless compile/launch succeeded with `D:\Godot\Godot_v4.6.1-stable_win64.exe\Godot_v4.6.1-stable_win64_console.exe --headless --path E:\MyGame\Fight --quit-after 1`; `scripts/tools/m4_regression_runner.gd` passed with `81` versus pairs and `9` training cases.
- Next: Run a short human play-feel pass on the new roster if the next phase is polish-focused, or begin the next controlled expansion wave using the same add -> regress -> tune loop.

## 2026-06-24 10:35 - Implement T8-T10 onboarding, regression, and tuning assets
- Request: Handle T8, T9, and T10 together.
- Completed: Added a reusable content template/validator helper, centralized key runtime tuning values into a new tuning hub wired into match, HUD, camera, and fighter feedback code, and created the formal content-integration and regression checklist documents.
- Outputs: The project now has concrete assets for new content onboarding, a fixed self-test flow, and a single global tuning entry point for common feel adjustments.
- Files: `scripts/core/tuning_hub.gd`, `scripts/core/content_templates.gd`, `scripts/game/game_scene.gd`, `scripts/game/hud.gd`, `scripts/actors/fighter.gd`, `docs/content-integration-template.md`, `docs/regression-test-checklist.md`, `docs/tuning-parameter-hub.md`, `docs/planning-log.md`, `docs/programming-log.md`.
- Verification: Godot headless compile/launch succeeded with `D:\Godot\Godot_v4.6.1-stable_win64.exe\Godot_v4.6.1-stable_win64_console.exe --headless --path E:\MyGame\Fight --quit-after 1`.
- Next: Run the first formal regression sweep with the new checklist and fix any issues it surfaces before expanding the roster.

## 2026-06-23 13:29 - Complete T7 showcase-stage upgrade
- Request: Finish T7 in one pass by turning the current test platform into a presentable showcase stage.
- Completed: Rebuilt the stage script around a clearer data-driven platform layout, upgraded the playable geometry to a more expressive staggered showcase map, and added layered backdrop/support visuals plus synchronized spawn, camera, and blast-zone tuning.
- Outputs: The project now has a showcase-ready main stage with a stronger sense of place and better support for chase, recovery, edge pressure, and readable camera framing.
- Files: `scripts/game/stage.gd`, `docs/planning-log.md`, `docs/programming-log.md`.
- Verification: Godot headless compile/launch succeeded with `D:\Godot\Godot_v4.6.1-stable_win64.exe\Godot_v4.6.1-stable_win64_console.exe --headless --path E:\MyGame\Fight --quit-after 1`.
- Next: Run the planned four-loadout regression pass and capture any remaining M2 gameplay or camera polish issues.

## 2026-06-23 11:33 - Complete T6 combat feedback polish
- Request: Continue T6 and finish the remaining M2 combat-feedback implementation.
- Completed: Added fighter-to-scene combat feedback events, receiver hit-flash timing/colors, HUD combat callouts for landed hits, and stronger styled messaging for fight start, training resets, ring-outs, and match-end results.
- Outputs: T6 now has readable moment-to-moment feedback across hit confirms, damage spikes, projectile contacts, and round-state transitions without increasing control complexity.
- Files: `scripts/actors/fighter.gd`, `scripts/game/game_scene.gd`, `scripts/game/hud.gd`, `docs/planning-log.md`, `docs/programming-log.md`.
- Verification: Godot headless compile/launch succeeded with `D:\Godot\Godot_v4.6.1-stable_win64.exe\Godot_v4.6.1-stable_win64_console.exe --headless --path E:\MyGame\Fight --quit-after 1`.
- Next: Implement T7 showcase-stage presentation work and then run the planned four-loadout regression pass.

## 2026-06-23 11:22 - Finish T5 training debug HUD coverage
- Request: Continue and complete all remaining T5 work from the M2 handoff.
- Completed: Added recent landed-hit and received-hit tracking to fighters, propagated projectile-hit summaries back to the attacker, expanded training HUD readouts with hit/taken lines plus timer information, and verified the project compiles successfully through a Godot headless launch.
- Outputs: Training mode now exposes loadout identity, movement resources, current state, current attack slot, flags, live velocity/timers, and the latest hit/receive summaries needed for T5 debugging.
- Files: `scripts/actors/fighter.gd`, `scripts/actors/projectile.gd`, `scripts/game/hud.gd`, `docs/planning-log.md`, `docs/programming-log.md`.
- Verification: Static quote-balance check passed for the touched scripts; Godot headless compile/launch succeeded with `D:\Godot\Godot_v4.6.1-stable_win64.exe\Godot_v4.6.1-stable_win64_console.exe --headless --path E:\MyGame\Fight --quit-after 1`.
- Next: Validate the new training HUD layout visually in the editor, then start T6 combat feedback polish.

## 2026-06-22 17:17 - Expand training HUD state readout for M2 T5 card 1
- Request: Check the logs, identify the PM-assigned next task, and execute it.
- Completed: Followed the newest M2 handoff, implemented the first T5 training-mode HUD card, and expanded the runtime debug readout so training mode now surfaces loadout identity, jump/dash resources, locomotion state, attack slot, flags, and live velocity while keeping versus mode more compact.
- Outputs: A stronger training HUD information layer aligned to `docs/m2-vertical-slice-task-brief.md` T5 card 1.
- Files: `scripts/actors/fighter.gd`, `scripts/game/hud.gd`, `docs/planning-log.md`, `docs/programming-log.md`.
- Verification: Static quote-balance check passed for the touched scripts; manually reviewed the new HUD text and helper methods; Godot runtime launch and in-editor layout validation were not run in this shell.
- Next: Continue with T5 card 2 by adding clearer training hit/receive debug information, then evaluate whether the HUD needs layout tightening after in-editor verification.

## 2026-06-22 17:00 - Stabilize combat UI text and add attack-slot HUD feedback
- Request: Continue the post-integration follow-up work after wiring directional and special weapon slots into the prototype.
- Completed: Cleaned remaining high-risk battle-scene and HUD status strings to stable ASCII text, removed lingering mojibake from the active startup path, and added a lightweight HUD readout for the current attack slot so manual move verification is easier in Godot.
- Outputs: Safer scene/HUD startup text and live `Attack <slot>` status feedback during matches.
- Files: `scripts/actors/fighter.gd`, `scripts/game/game_scene.gd`, `scripts/game/hud.gd`.
- Verification: Static quote-balance check passed for the main touched gameplay scripts; non-ASCII scan returned no matches for `scripts/game/game_scene.gd`, `scripts/game/hud.gd`, and `scripts/main/main.gd`; Godot runtime launch was not available in this shell.
- Next: Open the project in Godot and verify menu entry, pause/restart flow, and that both weapons correctly show `up_ground`, `down_ground`, and each `special_*` slot in the HUD when triggered.

## 2026-05-07 21:29 - Add programmer M1 task brief
- Request: Create a handoff document that tells the programmer exactly what to build next.
- Completed: Wrote a programmer-facing M1 task brief covering current code constraints, required task order, target files, deliverables, and acceptance criteria for the loadout-based MVP phase.
- Outputs: `docs/m1-programmer-task-brief.md`.
- Files: `docs/m1-programmer-task-brief.md`, `docs/planning-log.md`, `docs/programming-log.md`.
- Verification: Reviewed the new brief against `docs/programmer-implementation-handoff.md`, `docs/project-management-roadmap.md`, `scripts/core/fighter_catalog.gd`, and `scripts/game/game_scene.gd`.
- Next: Use the new brief as the implementation source of truth for the next programming pass.

## 2026-05-07 14:57 - Create project-local work log skill
- Request: Create a skill that keeps separate persistent planning and programming journals in the same two project documents, recording what was done and what was produced each session.
- Completed: Initialized a project-local Codex skill under `.codex/skills/pm-dev-log-recorder`, replaced the template instructions with a concrete logging workflow, and created the two canonical journal files that future sessions should maintain.
- Outputs: `.codex/skills/pm-dev-log-recorder/SKILL.md`, `docs/planning-log.md`, and `docs/programming-log.md`.
- Files: `.codex/skills/pm-dev-log-recorder/SKILL.md`, `docs/planning-log.md`, `docs/programming-log.md`.
- Verification: Manual structure check passed for the skill files and journals; `quick_validate.py` could not run because the bundled Python environment is missing the `yaml` module required by the validator.
- Next: Use this skill as the default project logging workflow for future planning and implementation sessions; optionally install the validator dependency later if full automated skill validation is needed.
