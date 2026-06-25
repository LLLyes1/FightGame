# M5 程序任务书

## 1. 这份文档给谁

这份文档是给当前阶段负责实现与验证的程序同学的。

目标不是重新解释项目背景，而是明确：

- M5 每一块要做什么
- 先后顺序是什么
- 主要会改哪些文件
- 每块做到什么程度算完成

M5 的定位不是继续扩内容，而是把当前 `3 角色 x 3 武器` 版本做稳定化收口，为下一轮扩展建立可放心进入的基线。

相关参考：

- [m4-known-issues.md](/E:/MyGame/Fight/docs/m4-known-issues.md)
- [m4-regression-report.md](/E:/MyGame/Fight/docs/m4-regression-report.md)
- [m4-balance-iteration-report.md](/E:/MyGame/Fight/docs/m4-balance-iteration-report.md)
- [regression-test-checklist.md](/E:/MyGame/Fight/docs/regression-test-checklist.md)
- [tuning-parameter-hub.md](/E:/MyGame/Fight/docs/tuning-parameter-hub.md)

---

## 2. 当前代码阶段判断

当前版本已经完成：

- `halberd` 新武器接入
- `bastion` 新角色接入
- 自动化回归矩阵
- 参数集中化

当前最需要补上的，不是新内容，而是下面三类确认：

1. 人工长时间玩下来，手感到底哪里有问题
2. `halberd` 和 `bastion` 是否有真实对局下的失衡点
3. 当前 9 个合法 loadout 是否已经足够稳定到可以进入下一轮扩展

一句话：

**M5 程序工作的核心不是新功能，而是验证、收口、微调、定基线。**

---

## 3. M5 总任务顺序

请按下面顺序推进，不建议打乱：

1. `T15` 做人工验证支持与记录工具
2. `T16` 收口 `halberd` / `bastion` 风险点
3. `T17` 跑 3x3 阵容平衡收口
4. `T18` 做信息可读性与训练读数整理
5. `T19` 产出下一轮扩展准入结论

最短理解版：

**先让人能稳定测，再修高风险点，再收口阵容，再决定能不能继续扩。**

---

## 4. T15 人工验证支持与记录工具

## T15-C1 建立人工验证脚本模板

### 目标

让手测不再靠临场想到什么测什么，而是有固定流程。

### 建议输出

- `docs/m5-manual-playtest-script.md`

### 程序侧需要做的事

程序不一定要为这张卡改很多代码，但要先确认现有版本已经支持人工验证需要观察的信息：

- 当前角色/武器名显示正确
- 当前攻击槽位能显示
- 训练模式关键状态能显示
- HUD 消息不会遮挡主要观察点

### 优先检查文件

- [hud.gd](/E:/MyGame/Fight/scripts/game/hud.gd)
- [game_scene.gd](/E:/MyGame/Fight/scripts/game/game_scene.gd)
- [fighter.gd](/E:/MyGame/Fight/scripts/actors/fighter.gd)
- [main.gd](/E:/MyGame/Fight/scripts/main/main.gd)

### 建议脚本结构

每轮人工验证都固定记录：

- 测试组合
- 观察目标
- 现象
- 是否复现
- 是否阻塞
- 建议调参入口

### 完成标准

- 有一份正式人工验证脚本
- 测试者拿到文档就知道该怎么测

---

## T15-C2 基础四组合人工验证支持

### 目标

优先确认旧四组合手感没被新内容带偏。

### 固定组合

- `vanguard + saber`
- `vanguard + hand_cannon`
- `sky_drifter + saber`
- `sky_drifter + hand_cannon`

### 程序侧要重点观察

- 菜单进局流程是否顺手
- HUD 信息是否够看
- 攻击槽位提示是否匹配实际动作
- 回场、出界、结算是否可读

### 如发现问题优先修哪里

- 流程问题：`main.gd`、`game_scene.gd`
- 信息问题：`hud.gd`
- 动作 / 状态问题：`fighter.gd`

### 完成标准

- 旧四组合至少有一轮正式人工记录
- 程序能定位问题属于流程、信息还是战斗逻辑

---

## T15-C3 新内容专项人工验证支持

### 目标

专测新内容，不让新增 archetype 风险混在大盘里。

### 重点组合

- `vanguard + halberd`
- `sky_drifter + halberd`
- `bastion + saber`
- `bastion + hand_cannon`
- `bastion + halberd`

### 程序侧重点

- `halberd` 是否让边线控制过安全
- `bastion` 是否回场过弱
- 新旧组合碰撞时镜头和 HUD 是否仍稳定

### 建议记录字段

- 是否存在无脑压制
- 是否存在明显不可用回场路径
- 是否存在动作触发正确但体验很糟的问题

### 完成标准

- 新内容专项组合有正式人工结论
- 至少能明确列出 2-3 个最高优先问题

---

## T15-C4 产出人工验证报告

### 目标

把手测结论固化，不要只留在口头结论里。

### 建议输出

- `docs/m5-manual-playtest-report.md`

### 报告内容建议

- 测试日期
- 测试者
- 覆盖组合
- 阻塞问题
- 平衡风险
- 体验风险
- 推荐修复顺序

### 完成标准

- 报告足够支撑后续调参与收口

---

## 5. T16 新内容专项稳定化

## T16-C1 `halberd` 风险复核

### 目标

确认 `halberd` 的中距离控制和压边能力是否超出健康范围。

### 重点改动入口

- [weapon_database.gd](/E:/MyGame/Fight/scripts/core/weapon_database.gd)
- 如需全局反馈配合，可看 [tuning_hub.gd](/E:/MyGame/Fight/scripts/core/tuning_hub.gd)

### 优先关注攻击

- `heavy_ground`
- `special_side`
- `up_ground`
- `up_air`

### 优先可调参数

- `startup`
- `recovery`
- `movement_scale`
- `hitbox_size`
- `base_knockback`
- `knockback_growth`

### 判断标准

如果问题是“太强但仍有明确破绽”，先小调。

如果问题是“几乎无风险反复压边”，优先加：

- 更长 `recovery`
- 更低位移收益
- 更保守 hitbox

### 完成标准

- `halberd` 仍是中距离控制型
- 但不能靠单一节奏无脑压边

---

## T16-C2 `bastion` 风险复核

### 目标

确认 `bastion` 的重型身份成立，但不会因为回场过弱而失去可用性。

### 重点改动入口

- [character_database.gd](/E:/MyGame/Fight/scripts/core/character_database.gd)
- [dash_config.gd](/E:/MyGame/Fight/scripts/core/dash_config.gd)
- 必要时看 [fighter.gd](/E:/MyGame/Fight/scripts/actors/fighter.gd)

### 优先可调参数

- `air_speed`
- `gravity`
- `jump_velocity`
- `double_jump_velocity`
- `weight`
- `knockback_resistance`
- `dash_config_overrides`

### 调整原则

- 不能把 `bastion` 调成普通角色
- 只能补“最低可用回场空间”
- 优先补操作窗口，不要直接把缺点抹掉

### 完成标准

- `bastion` 仍然是重型、短回场、强承伤
- 但不会因为太难回场而变成明显弃用角色

---

## T16-C3 新内容二次调参与复测

### 目标

把 `halberd` 和 `bastion` 的第一轮问题收口成“可接受风险”。

### 建议流程

1. 从人工报告里挑 1-2 个最高优先问题
2. 每次只改一类参数
3. 改完就跑专项复测

### 工具与入口

- [tuning_hub.gd](/E:/MyGame/Fight/scripts/core/tuning_hub.gd)
- [weapon_database.gd](/E:/MyGame/Fight/scripts/core/weapon_database.gd)
- [character_database.gd](/E:/MyGame/Fight/scripts/core/character_database.gd)
- [regression-test-checklist.md](/E:/MyGame/Fight/docs/regression-test-checklist.md)

### 完成标准

- 没有明显阻塞级新内容问题残留
- 新内容身份仍然清楚

---

## 6. T17 3x3 阵容平衡收口

## T17-C1 建立 9 组合观察矩阵

### 目标

把当前所有合法 loadout 都纳入统一观察表。

### 当前 9 组合

- `vanguard + saber`
- `vanguard + hand_cannon`
- `vanguard + halberd`
- `sky_drifter + saber`
- `sky_drifter + hand_cannon`
- `sky_drifter + halberd`
- `bastion + saber`
- `bastion + hand_cannon`
- `bastion + halberd`

### 程序侧建议产物

- 一份观察矩阵表，按组合记录：
  - 机动感
  - 对空能力
  - 压边能力
  - 回场容错
  - 命中收益

### 完成标准

- 所有合法组合都有可比较的观察记录

---

## T17-C2 识别强弱组合

### 目标

在当前 9 组合里找出风险组，而不是盲调全盘。

### 至少要识别

- 最稳通用组合
- 最强压边组合
- 最弱回场组合
- 最需继续观察组合

### 结论用途

- 给 T17-C3 小步调参排序
- 给 T19 是否准入下一轮扩展提供依据

### 完成标准

- 当前阵容的主要风险组被明确点名

---

## T17-C3 阵容小步调参与收口

### 目标

不是做“最后平衡”，而是做“第一版稳定基线”。

### 调整优先级

1. 先修极端失衡
2. 再修身份模糊
3. 最后修细节手感

### 主要文件

- [character_database.gd](/E:/MyGame/Fight/scripts/core/character_database.gd)
- [weapon_database.gd](/E:/MyGame/Fight/scripts/core/weapon_database.gd)
- [dash_config.gd](/E:/MyGame/Fight/scripts/core/dash_config.gd)
- [tuning_hub.gd](/E:/MyGame/Fight/scripts/core/tuning_hub.gd)

### 完成标准

- 当前阵容没有明显“无脑必选”
- 也没有明显“完全不值得选”

---

## T17-C4 阵容平衡报告

### 目标

把当前 roster 的阶段结论文档化。

### 建议输出

- `docs/m5-roster-balance-report.md`

### 内容应包含

- 3 名角色当前身份总结
- 3 把武器当前身份总结
- 需要继续观察的 2-3 个组合
- 目前最缺的下一个 archetype 空位

### 完成标准

- 看完报告，团队知道当前阵容“站不站得住”

---

## 7. T18 信息可读性与表现补强

## T18-C1 菜单与组合预览补强

### 目标

让试玩者在进局前更容易理解角色与武器定位。

### 主要文件

- [main.gd](/E:/MyGame/Fight/scripts/main/main.gd)
- [scenes/main/main.tscn](/E:/MyGame/Fight/scenes/main/main.tscn)

### 可做内容

- 角色一句话定位
- 武器一句话定位
- 组合预览更直观

### 完成标准

- 玩家能在选人阶段大致理解“这个组合怎么玩”

---

## T18-C2 战斗内消息与训练 HUD 筛整

### 目标

让当前 HUD 和消息更服务调试与试玩。

### 主要文件

- [hud.gd](/E:/MyGame/Fight/scripts/game/hud.gd)
- [game_scene.gd](/E:/MyGame/Fight/scripts/game/game_scene.gd)
- [fighter.gd](/E:/MyGame/Fight/scripts/actors/fighter.gd)

### 建议动作

- 保留真有价值的训练读数
- 弱化噪音字段
- 确保攻击槽位、状态、回场相关信息仍可读

### 完成标准

- 调试信息足够用
- 但不会影响人工试玩判断

---

## T18-C3 中文布局人工复核支持

### 目标

配合最近中文化，确认长文本没有挤压、截断、错位。

### 主要文件

- [main.gd](/E:/MyGame/Fight/scripts/main/main.gd)
- [hud.gd](/E:/MyGame/Fight/scripts/game/hud.gd)
- [scenes/main/main.tscn](/E:/MyGame/Fight/scenes/main/main.tscn)

### 程序侧要做的事

- 如果人工复核发现问题，优先调布局、字号、行距和兜底文本

### 完成标准

- 主要中文 UI 没有明显排版问题

---

## 8. T19 下一轮扩展准入评审

## T19-C1 汇总问题与风险

### 目标

把 M5 前面几块的问题统一收口。

### 输入来源

- `m4-known-issues`
- `m5-manual-playtest-report`
- `m5-roster-balance-report`
- `T18` 的人工界面复核结果

### 输出

- 一份最终风险清单

---

## T19-C2 给下一轮扩展做准入结论

### 目标

给出明确结论，而不是模糊说“差不多能扩了”。

### 建议输出

- `docs/m5-next-wave-gate-review.md`

### 结论只保留两种

1. 当前版本已稳，可以进入下一轮扩展
2. 当前版本不够稳，需要再做一轮稳定化

### 完成标准

- 团队对下一步没有歧义

---

## 9. 推荐验证方式

M5 每一块建议都走两条验证线：

1. 自动验证
   当前已有 [m4_regression_runner.gd](/E:/MyGame/Fight/scripts/tools/m4_regression_runner.gd)
2. 人工验证
   当前 M5 必须补齐这条线

程序侧最低要求：

- 每轮改完后至少再跑一次 headless 回归
- 每轮关键改动都要有人玩

---

## 10. 阶段完成标准

M5 可以算完成，当且仅当下面条件都成立：

1. 已产出正式人工验证脚本和报告
2. `halberd` 与 `bastion` 的风险点已复核并收口
3. 当前 `3x3` 阵容有正式平衡结论
4. 主要中文 UI 与训练 HUD 已人工复核
5. 已产出下一轮扩展准入评审

---

## 11. 给程序的最后一句话

M5 程序开发的重点不是“多写新功能”，而是：

**把当前版本的真实问题挖出来、修到可接受、并形成下一轮扩展前的稳定基线。**

执行主线请始终保持：

**人工验证支持 -> 新内容收口 -> 阵容平衡 -> 可读性整理 -> 准入评审**
