# Planning Log

## 2026-06-25 09:50 - Draft the first UX spec for the main screen and character DIY flow
- Request: Organize the newly stated UI requirements into a UX document covering a main screen plus a character DIY screen, with left and right fighters visible on the main screen, per-player edit buttons, and a battle-start area.
- Completed: Converted the current UI request into a focused UX specification that defines the two-screen information architecture, the main-screen left/center/right layout, the single-player DIY editing page, and the navigation flow between editing and starting a match.
- Outputs: `docs/m6-main-and-character-diy-ux-spec.md`.
- Decisions: Treat the main screen as a versus-preparation hub and the DIY screen as a single-player editor; keep one player edited at a time and have the main screen immediately reflect updated choices after returning.
- Next: Continue expanding the same UX spec as more requirements arrive, especially the detailed content of the DIY page, the battle button area, and later visual-resource placements.

## 2026-06-24 17:50 - Lock the first executable M6 weapon-family slice
- Request: Implement the new weapon requirements recorded in the planning log.
- Completed: Turned the M6 shield-and-firearm direction into an executable first slice by confirming the minimum viable runtime needs: returning projectiles for shield normals, defensive/guard specials for shield play, and burst-capable projectile support so `pistol`, `rifle`, and `sniper` can feel like distinct firearm weapons instead of one generic gun variant.
- Outputs: A concrete implementation scope for the current coding pass covering `shield`, `pistol`, `rifle`, and `sniper`, plus the runtime support needed to ship them in the current prototype.
- Decisions: Keep the old `hand_cannon` as the heavy gun baseline; add the new shield and three firearm variants alongside it; use minimal systemic additions (`returning projectile`, `guard window`, `projectile burst`) instead of a larger combat-system rewrite.
- Next: Continue M6 by manually playtesting the new weapon family spread, tuning the strongest outliers, and then deciding whether the next expansion wave should target a new character, map, or a visual/UI pass.

## 2026-06-24 17:34 - Close the M5 implementation pass and record the gate result
- Request: Complete all M5 tasks.
- Completed: Executed the M5 implementation pass by wiring the manual-validation support outputs, stabilizing the `halberd` and `bastion` risk points with small data adjustments, documenting the `3x3` roster observation and balance baseline, and producing the next-wave gate review.
- Outputs: `docs/m5-manual-playtest-script.md`, `docs/m5-manual-playtest-report.md`, `docs/m5-roster-observation-matrix.md`, `docs/m5-roster-balance-report.md`, and `docs/m5-next-wave-gate-review.md`.
- Decisions: Keep the gate outcome conservative: the code-side M5 work is complete, but the build should still be treated as not ready for immediate M6 expansion until one real long-form human playtest fills the prepared report.
- Next: Run the scripted nine-loadout human playtest, fill the report, and then refresh the gate review before opening the next expansion wave.

## 2026-06-24 17:32 - Fix the M6 weapon direction around shields and firearm families
- Request: Define the desired next-weapon directions as a shield weapon with returning normal attacks and defensive specials, plus a broader firearm line including sniper rifles, rifles, and pistols.
- Completed: Converted the new preference into a formal M6 weapon-family plan, clarified that shields should become a defensive return-weapon archetype, and that firearms should expand from one generic gun into a multi-weapon family with distinct roles.
- Outputs: `docs/m6-weapon-family-direction.md`.
- Decisions: Treat shield and firearms as first-class weapon lines; prioritize `shield` first for gameplay differentiation, then expand firearms as separate weapons rather than one generic gun skin family.
- Next: Use `docs/m6-weapon-family-direction.md` as the weapon source of truth, and when detailed execution starts, split T20 weapon work into `shield`, `pistol`, `rifle`, and `sniper` subtracks.

## 2026-06-24 17:31 - Reframe M6 around content, UI, and visual assets
- Request: Align the next phase with the desire for more character traits, weapons, and maps, stronger UI presentation, and real weapon assets instead of text-heavy prototype visuals.
- Completed: Reviewed the current menu, HUD, fighter, projectile, and stage implementation to confirm that the project still relies on text-first UI and code-drawn visuals, then converted that finding into a sharper M6 direction centered on content expansion, UI restructuring, and asset-pipeline integration.
- Outputs: `docs/m6-content-ui-and-visual-upgrade-brief.md`, `docs/m6-ui-visual-asset-programmer-brief.md`.
- Decisions: Treat UI upgrade and real asset integration as first-class M6 workstreams instead of secondary polish; keep content expansion, UI rebuild, and visual-resource integration moving together.
- Next: Use the new M6 alignment briefs as the latest priority source, and if implementation starts, begin with T20 content expansion and T21 menu/UI reconstruction in parallel.

## 2026-06-24 17:25 - Plan the post-M5 content-enrichment phase
- Request: Explain what the game should do after M5 and which content areas should be expanded next.
- Completed: Reviewed the current milestone state and converted the post-stabilization direction into a concrete M6 plan focused on roster expansion, map-pool growth, lightweight mode additions, loadout readability, and presentation polish.
- Outputs: `docs/m6-content-richness-and-replayability-brief.md`, `docs/m6-programmer-task-brief.md`.
- Decisions: Define the next phase as M6 content richness and replayability building rather than another stabilization pass; prioritize adding one new character, one new weapon, one new map, then lightweight modes and readability/product-feel upgrades.
- Next: Use the new M6 briefs as the source of truth, and if execution starts, begin from T20 first-wave content integration.

## 2026-06-24 17:15 - Create detailed M5 stabilization and playfeel plan
- Request: Provide the next detailed plan after M4 is completed.
- Completed: Reviewed the first production-wave outputs, known issues, regression report, and balance report, then translated the post-M4 recommendation into a concrete M5 brief centered on manual validation, new-content stabilization, roster balance baselining, readability cleanup, and a gate review for the next expansion wave.
- Outputs: `docs/m5-roster-stabilization-and-playfeel-validation-brief.md`.
- Decisions: Recommend a stabilization-first M5 instead of immediate M6 expansion because the current build has automated confidence but still lacks a dedicated long-form manual play-feel sign-off.
- Next: Use `docs/m5-roster-stabilization-and-playfeel-validation-brief.md` as the source of truth for the next phase and begin with T15 manual playtest script creation and structured human validation.

## 2026-06-24 11:05 - 盘点当前任务完成状态
- Request: 梳理当前项目已经完成到什么阶段，并确认之前分配的任务是否都已完成。
- Completed: 交叉检查了最新 planning/programming 日志，按里程碑重新核对了 M1、M2、M3、M4 的完成情况，并区分了“主线任务已完成”与“仍建议补做的人工验收/后续阶段工作”。
- Outputs: 一份当前状态结论：M1-M4 主线任务已完成并有日志与产出支撑；当前未开启新的 M5 级别正式任务，剩余的是人工体验巡检、已知问题复核和下一阶段规划，而不是前面任务的硬性欠账。
- Decisions: 将当前项目视为已完成 M4 的可继续扩展状态；不要把新的打磨建议误判为旧任务未完成。
- Next: 如果继续推进，优先在“人工手感巡检并消化 `docs/m4-known-issues.md`”和“规划下一轮小规模内容扩展或系统深化”之间二选一。

## 2026-06-24 10:47 - Close M4 as the first controlled production wave
- Request: Complete all M4 content.
- Completed: Executed the full M4 loop by adding one new weapon, one new character, a reusable automated regression runner, formal regression and balance records, and a known-issues handoff for the first content-production wave.
- Outputs: `halberd`, `bastion`, `docs/m4-weapon-positioning.md`, `docs/m4-character-positioning.md`, `docs/m4-regression-report.md`, `docs/m4-balance-iteration-report.md`, and `docs/m4-known-issues.md`.
- Decisions: Treat M4 as complete with automated regression-backed sign-off; preserve legacy archetypes while adding one new mid-range control weapon and one new heavy anchor character instead of widening scope further in the same pass.
- Next: If the team continues immediately, start the next phase from either a short manual feel-polish pass on the new roster or from planning the next single-step expansion wave using the same production loop.

## 2026-06-24 10:40 - Read and restate the M4 execution scope
- Request: Read the newly prepared M4 content and first understand what work it asks the team to do.
- Completed: Reviewed the M4 brief end to end and translated it into a concrete stage understanding covering the production goal, task order, work blocks, acceptance criteria, and the main execution risks.
- Outputs: A clarified M4 understanding centered on controlled content expansion plus regression-backed balance iteration, with the immediate entry point confirmed as T11 new-weapon definition and data integration.
- Decisions: Treat M4 as the first real version-production phase, not another infrastructure phase; keep execution in small validated waves and do not mix large-scale system rewrites, UI redesign, or mass content drops into the same loop.
- Next: If execution starts, begin with T11-C1 weapon positioning, then T11-C2 weapon data entry, and only move to T12 after the first new weapon has been integrated, verified, and lightly tuned.

## 2026-06-24 10:37 - Create detailed M4 production-phase brief
- Request: Break the post-M3 phase down in detail.
- Completed: Reviewed the newly completed T8, T9, and T10 deliverables and translated the recommended post-M3 phase into a concrete M4 brief covering controlled content expansion, regression sequencing, balance iteration, target files, deliverables, and acceptance criteria.
- Outputs: `docs/m4-content-expansion-and-balance-iteration-brief.md`.
- Decisions: Treat M4 as the first real production phase; expand in small verified waves, starting with one new weapon before one new character, and require regression plus tuning after each wave.
- Next: Use `docs/m4-content-expansion-and-balance-iteration-brief.md` as the source of truth for the next stage and begin with T11 new-weapon positioning and data entry.

## 2026-06-24 10:36 - Recommend the post-M3 phase after infrastructure completion
- Request: Decide what the team should do next after completing T8, T9, and T10.
- Completed: Rechecked the roadmap and confirmed the documented milestone chain currently ends at M3, then derived the next recommended phase from the project's new readiness level.
- Outputs: A clarified post-M3 recommendation: move into a controlled content-expansion and balance-iteration phase built on the newly finished onboarding, regression, and tuning infrastructure.
- Decisions: Treat the next phase as the first true production phase rather than another infrastructure phase; expand content in small verified batches instead of attempting a large one-time content drop.
- Next: Start with one new weapon and one new character as the first controlled expansion wave, run the fixed regression workflow after each addition, and use the centralized tuning path to stabilize balance before scaling further.

## 2026-06-24 10:35 - Close T8-T10 expansion-prep infrastructure
- Request: Handle T8, T9, and T10 together.
- Completed: Turned the M3 brief into concrete reusable assets by standardizing content onboarding, formalizing the regression workflow, and choosing parameter centralization as the T10 implementation path.
- Outputs: `docs/content-integration-template.md`, `docs/regression-test-checklist.md`, `docs/tuning-parameter-hub.md`, and the new helper scripts backing template and tuning work.
- Decisions: Use documentation plus lightweight helper scripts for T8/T9, and implement T10 as a live runtime tuning hub instead of a separate in-game panel for now.
- Next: Use the new regression checklist to execute the first formal four-loadout run, then address any issues found before adding the next character or weapon.

## 2026-06-23 13:35 - Define the main purpose of M3 after M2 completion
- Request: Explain what M3 should mainly do now that the team reports M2 is complete and wants to continue.
- Completed: Rechecked the roadmap milestone definitions and aligned the next-stage recommendation around M3 as an expansion-preparation phase rather than a broad content-expansion phase.
- Outputs: A clarified M3 description centered on onboarding templates, regression workflow, and parameter centralization for future characters, weapons, and tuning work.
- Decisions: Treat M3 as the foundation phase for scalable content growth; prioritize lowering the cost and risk of adding new fighters, weapons, and balance changes before committing to larger content drops.
- Next: Start M3 with T8 new character/weapon onboarding templates, then T9 regression checklist formalization, then T10 parameter centralization or tuning-panel work.

## 2026-06-23 13:35 - Create detailed M3 execution brief
- Request: Break M3 down carefully into an actionable plan.
- Completed: Reviewed the current expansion-related code entry points and translated the roadmap's M3 milestone into a concrete task brief covering T8-T10, card-level breakdowns, target files, outputs, acceptance criteria, and recommended sequencing.
- Outputs: `docs/m3-expansion-prep-task-brief.md`.
- Decisions: Keep M3 focused on scalable-content infrastructure; use the current databases and assembler as the base rather than forcing a large structural rewrite at the start of the phase.
- Next: Use `docs/m3-expansion-prep-task-brief.md` as the source of truth for M3 and begin with T8 character/weapon template standardization.

## 2026-06-23 13:29 - Close T7 stage-upgrade work and hand off to regression
- Request: Finish T7 in one pass by upgrading the prototype stage into a presentable showcase map.
- Completed: Rechecked the T7 acceptance notes, translated them into concrete layout and presentation goals, completed the stage-upgrade pass, and moved the milestone flow forward after launch verification succeeded.
- Outputs: A completed T7 implementation target covering the showcase-stage layout, supporting visual presentation, and synchronized spawn/camera/out-of-bounds space.
- Decisions: Treat M2's stage-presentation task as complete; the next work block is now the planned four-loadout regression sweep rather than more map feature expansion.
- Next: Run the four-loadout regression pass, collect any camera/ring-out/control issues that remain, and then reassess whether M2 is ready for acceptance closure.

## 2026-06-23 13:27 - Reconfirm the post-T6 execution order
- Request: Clarify what comes next after T6 is completed.
- Completed: Rechecked the latest planning and programming logs and confirmed the project remains in M2, with T7 showcase-stage work and the four-loadout regression sweep still outstanding before M2 can be accepted.
- Outputs: A confirmed next-step sequence: T7 stage upgrade first, regression verification second, M2 acceptance review third, and only then M3 planning.
- Decisions: Do not move into M3 yet; finish the presentation and validation layer of M2 before reopening broader expansion-prep work.
- Next: Upgrade the stage presentation in `scripts/game/stage.gd`, validate spawn/camera/blast-zone behavior in Godot, run the four-loadout regression pass, and then decide whether M2 is ready to close.

## 2026-06-23 13:26 - Clarify the concrete next-step sequence after T6
- Request: Explain what the team should do next now that T6 is finished.
- Completed: Rechecked the active M2 brief, current logs, and the live `stage.gd` implementation to translate the next milestone from a broad label into a concrete execution order.
- Outputs: A clarified next-step sequence: finish T7 by upgrading the current code-drawn test platform into a more presentable showcase stage, then run the four-loadout regression sweep and collect any final M2 issues.
- Decisions: Start T7 from `scripts/game/stage.gd` because the current stage is still a simple three-platform debug layout; keep the next pass focused on presentation, readability, spawn/camera safety, and platform variety rather than adding new combat systems.
- Next: 1) redesign the stage layout and visuals in `stage.gd`; 2) adjust spawn points, blast zone, and camera zone to match; 3) verify ring-out/camera behavior in Godot; 4) run the planned four-loadout regression pass.

## 2026-06-23 11:33 - Close T6 combat feedback and move the milestone forward
- Request: Continue T6 and finish the assigned M2 combat feedback work.
- Completed: Confirmed the remaining T6 scope was the feedback integration layer, completed the combat-callout hookup, and re-evaluated the milestone flow after verification succeeded.
- Outputs: A completed T6 milestone pass covering hit callouts, hit-flash readability, and stronger round-state message presentation.
- Decisions: Treat T6 as complete and move the implementation queue forward to T7 showcase-stage work plus the planned regression pass after stage changes land.
- Next: Execute all remaining T7 stage-presentation tasks, then run the four-loadout regression sweep before reassessing M2 acceptance.

## 2026-06-23 11:32 - Clarify the next step after the newly finished M2 work
- Request: Decide what the team should do next after the latest completed batch of M2 work.
- Completed: Rechecked the current M2 handoff, planning log, and programming log to determine whether the team had finished only T5 or the entire M2 milestone, then mapped the next task accordingly.
- Outputs: A clarified next-step recommendation: T5 is complete, so the immediate next implementation target is T6 combat feedback polish; M3 should wait until T6 and T7 are both done and M2 is accepted.
- Decisions: Do not advance to M3 yet; keep the project in M2 and move directly into hit, receive, ring-out, and match-end feedback work before stage-upgrade and final M2 acceptance.
- Next: Start T6 now, then finish T7 showcase-stage work, run the 4-loadout regression pass, and only then reassess readiness for M3.

## 2026-06-23 11:22 - Mark T5 implementation scope complete and hand off to T6
- Request: Continue and complete all remaining T5 work from the planning-assigned M2 sequence.
- Completed: Finished the remaining T5 implementation scope by extending training-mode readability beyond basic state info into recent hit/receive debug feedback, then validated that the project still compiles headlessly in Godot.
- Outputs: A completed T5 implementation pass covering both the training HUD status card and the recent hit/receive debug card.
- Decisions: Treat T5 as functionally complete pending in-editor readability review; move the next implementation target to T6 combat feedback polish instead of adding more training-only fields first.
- Next: Use Godot in-editor to quickly verify training HUD layout readability, then begin T6 by strengthening hit, receive, ring-out, and match-end feedback.

## 2026-06-22 17:17 - Start M2 from the first T5 training HUD card
- Request: Check the logs and execute the next task assigned by planning.
- Completed: Read the latest planning handoff and confirmed the active PM-assigned work block is M2, with execution ordered by `docs/m2-vertical-slice-task-brief.md`; selected the first T5 small card, focused on training HUD state information, as the immediate implementation target.
- Outputs: A clarified execution target: `M2 -> T5 -> Card 1 (training HUD status info)`.
- Decisions: Follow the newest planning log instead of reopening M1 stabilization; keep this pass scoped to readable training information rather than hit/receive event history or map work.
- Next: Finish the training HUD status implementation, then move to the second T5 card for training hit/receive debug information.

## 2026-06-22 17:06 - Create M2 handoff brief for continued execution
- Request: Break down the post-M1 stage into a concrete plan and handoff that can be followed continuously.
- Completed: Converted the roadmap's M2 milestone into an execution-oriented brief covering stage goals, out-of-scope items, task order, target files, acceptance criteria, and a small-card breakdown for sustained implementation.
- Outputs: `docs/m2-vertical-slice-task-brief.md`.
- Decisions: Treat M2 as a polish-and-showcase phase centered on T5-T7; keep future work focused on readability, feel, and presentation rather than immediate content expansion.
- Next: Use `docs/m2-vertical-slice-task-brief.md` as the source of truth for the next implementation pass and work through the six suggested cards in order.

## 2026-06-22 17:04 - Advance from M1 closure to M2 vertical slice
- Request: Decide what phase comes next after the team reports the current M1 work is completed.
- Completed: Interpreted the new status as M1 being closed, rechecked the roadmap milestone ordering, and identified the next recommended work block as the M2 vertical-slice phase.
- Outputs: A concrete next-phase recommendation focused on training-mode debug depth, combat feedback polish, and replacing the test map with a more presentable showcase stage.
- Decisions: Move from M1 main-path closure to M2 experience-shaping work; keep scope centered on making existing combinations feel distinct and readable before adding broader content.
- Next: Execute T5-T7 in order, then reassess whether the project is ready for M2 acceptance or needs one more polish loop.

## 2026-06-22 17:03 - Reconfirm next content block from planning docs
- Request: Review the planning documentation and tell the team what content or work section should be done next.
- Completed: Cross-checked the roadmap, programmer handoff, MVP checklist, current logs, and current loadout-related gameplay scripts to identify the true next block after the recent combat/HUD integration pass.
- Outputs: A clarified next-step recommendation centered on M1 validation and launch-flow closure rather than new feature expansion.
- Decisions: Treat the character-plus-weapon free-combination path as already structurally in place; prioritize Godot-side verification, move-trigger validation, and checklist-based acceptance before writing more systems or content.
- Next: Run the full M1 manual verification pass in Godot, fix any launch-flow, directional/special input, or HUD readability defects found, then decide whether M1 can be closed or needs one more stabilization pass.

## 2026-06-22 17:02 - Reconfirm immediate next milestone
- Request: Clarify what the team should do next after the latest combat-input and HUD stabilization pass.
- Completed: Re-reviewed the current planning and programming logs and refined the immediate next-step order around in-editor validation, input reliability checks, UI cleanup, and M1 acceptance closure.
- Outputs: A refreshed priority-ordered next-step recommendation for the current prototype.
- Decisions: Keep the team on a validation-first path; do not expand systems further until the Godot-side launch flow and directional/special move triggering are verified end to end.
- Next: Run the Godot-side verification pass first, then fix any move-routing or HUD issues found during manual testing before moving on to broader M1 polish.

## 2026-06-22 16:55 - Prioritize next combat prototype steps
- Request: List what should be done next after wiring weapon directional and special slots into the current prototype.
- Completed: Reviewed the current implementation state and organized the next work into a priority-ordered follow-up list focused on parser/runtime stability, in-editor validation, control clarity, and M1 closure.
- Outputs: An ordered next-step plan for the current combat prototype session.
- Decisions: Treat launch stability and Godot-side verification as the immediate priority before further feature expansion; keep the follow-up scope anchored to M1 usability and acceptance.
- Next: Share the ordered task list with the user, then execute the stability/verification items first in the next programming pass.

## 2026-05-07 21:29 - Programmer M1 task brief
- Request: Clarify the next implementation phase and turn it into a document that can be handed directly to the programmer.
- Completed: Consolidated the roadmap, programmer handoff notes, and current code constraints into a concrete M1 execution brief focused on loadout architecture, runtime assembly, and the pre-match flow.
- Outputs: `docs/m1-programmer-task-brief.md`.
- Decisions: Treat M1 as a main-path closure phase; prioritize data split, fighter assembly, dynamic spawn flow, and the minimum pre-match loadout UI before more content expansion.
- Next: Have the programmer implement T1-T5 in order and validate the result against `docs/mvp-test-checklist.md`.

## 2026-05-07 21:26 - Confirm persistent dev log workflow
- Request: Use `pm-dev-log-recorder` to record every future conversation.
- Completed: Confirmed the project-local `pm-dev-log-recorder` skill exists and read its logging rules.
- Outputs: Updated `docs/planning-log.md` with this workflow confirmation.
- Decisions: Use `docs/planning-log.md` for planning/specification sessions and `docs/programming-log.md` for implementation/debugging sessions, following the project-local skill instructions.
- Next: Record future substantive planning or programming turns before final responses.

## 2026-05-07 14:57 - Initial PM documentation pass
- Request: Review the existing project docs, clarify what the team should do next, and establish a repeatable documentation process for future planning/programming sessions.
- Completed: Sorted the existing docs into planning, architecture, implementation, system-spec, project-management, and test/acceptance layers; identified the current project stage as a combat prototype moving toward an MVP main flow; created PM-facing roadmap and acceptance structure.
- Outputs: `docs/project-management-roadmap.md`, `docs/mvp-test-checklist.md`, and a clear next-step recommendation centered on turning character-plus-weapon free combination into the MVP main path.
- Decisions: Treat the project as an MVP-closure phase rather than a content-expansion phase; prioritize data split, pre-match loadout flow, runtime assembly, and closed-loop UI before adding more characters, weapons, or maps.
- Next: Break the MVP work into executable implementation tasks and keep recording future PM/planning sessions in this file.
