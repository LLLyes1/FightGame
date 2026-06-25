# M3 扩展准备任务简报

## 1. 这份文档给谁

这份文档用于 M2 完成后的下一阶段交接。

M3 的目标不是立刻猛加角色、猛加武器，而是先把后续扩内容的基础设施搭好，让新增内容、回归验证、参数调平衡都更稳、更快、更便宜。

这份文档重点回答 4 件事：

- M3 主要要做什么
- 建议按什么顺序做
- 会优先动哪些文件
- 做到什么程度算完成

相关参考：

- [project-management-roadmap.md](/E:/MyGame/Fight/docs/project-management-roadmap.md)
- [m2-vertical-slice-task-brief.md](/E:/MyGame/Fight/docs/m2-vertical-slice-task-brief.md)
- [mvp-test-checklist.md](/E:/MyGame/Fight/docs/mvp-test-checklist.md)

---

## 2. 当前阶段判断

默认前提：M2 已完成并验收通过。

当前项目已经具备：

- 2 角色 + 2 武器的可玩组合
- 本地对战与训练模式
- 可展示的战斗反馈与演示地图
- 基本稳定的对局闭环

M3 的问题不再是“这游戏能不能演示”，而是：

- 后面加第 3 个角色会不会很痛苦
- 后面加第 3 把武器会不会改一堆底层
- 调一个冲刺参数、击飞参数，会不会牵一发动全身
- 每次做新内容后，怎么快速证明没把旧东西改坏

一句话：

**M3 是把当前原型，从“能继续做”升级成“适合持续扩”的阶段。**

---

## 3. M3 总目标

M3 主要完成 3 类基础建设：

1. 新角色 / 新武器接入模板
2. 固定化的回归测试清单
3. 参数集中化或调优面板化

完成后应该达到这些结果：

- 新增一个角色或武器时，有固定接入流程
- 平衡参数不再散落得到处都是
- 每次改完内容，都有一套固定检查流程
- 文档、代码、测试能彼此对上

---

## 4. 当前阶段先不要做什么

M3 依然不建议现在就做这些：

- 不一次性新增大量角色
- 不一次性新增大量武器
- 不开启联网相关工作
- 不做大规模 UI/美术重做
- 不引入新的大玩法系统

原则：

**先把扩展通道修平，再正式扩内容。**

---

## 5. M3 主任务

## T8. 新角色 / 武器接入模板

### 目标

把“新增角色”和“新增武器”这件事从临时开发，变成标准流程。

### 现状判断

当前已有较明确入口：

- 角色数据主要在 [character_database.gd](/E:/MyGame/Fight/scripts/core/character_database.gd)
- 武器数据主要在 [weapon_database.gd](/E:/MyGame/Fight/scripts/core/weapon_database.gd)
- 运行时组合主要在 [fighter_assembler.gd](/E:/MyGame/Fight/scripts/core/fighter_assembler.gd)
- 默认组合入口在 [fighter_catalog.gd](/E:/MyGame/Fight/scripts/core/fighter_catalog.gd)
- 冲刺模板参数在 [dash_config.gd](/E:/MyGame/Fight/scripts/core/dash_config.gd)

这说明 M3 最适合做的，不是重构整套系统，而是把这些入口进一步标准化。

### 建议输出

- 角色模板规范
- 武器模板规范
- 新增角色接入步骤
- 新增武器接入步骤
- 角色/武器最小可运行样板

### 建议拆卡

1. `T8-C1` 角色数据字段清单定稿
2. `T8-C2` 武器数据字段清单定稿
3. `T8-C3` 新角色接入文档或模板函数
4. `T8-C4` 新武器接入文档或模板函数
5. `T8-C5` 用 1 个占位新角色或新武器验证模板有效

### 具体要做什么

#### T8-C1 角色字段清单定稿

目标：

- 明确角色数据最少必须包含哪些字段
- 区分“必填字段”和“可选字段”

建议字段分组：

- 标识字段：`id`、`display_name`
- 视觉字段：`primary_color`、`accent_color`
- 移动字段：`move_speed`、`air_speed`、`move_acceleration`、`move_brake`
- 跳跃字段：`jump_count`、`jump_velocity`、`double_jump_velocity`
- 下落字段：`gravity`、`max_fall_speed`、`fast_fall_speed`
- 手感辅助字段：`coyote_time`、`jump_buffer`
- 特性字段：`can_glide`、`glide_fall_speed`、`glide_horizontal_control`
- 生存字段：`weight`、`knockback_resistance`
- 冲刺字段：`dash_profile_label`、`dash_config_overrides`
- 描述字段：`movement_summary`

建议产物：

- 角色字段约定文档
- 一个标准角色样板条目

#### T8-C2 武器字段清单定稿

目标：

- 明确武器数据最少必须包含哪些字段
- 明确所有武器共用的攻击槽位

建议字段分组：

- 标识字段：`id`、`display_name`、`weapon_type`
- 风格字段：`is_ranged`、`range_class`、`attack_tempo_label`
- 预览字段：`preview_summary`
- 攻击集合字段：`attacks`

建议统一攻击槽位：

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

建议产物：

- 武器字段约定文档
- 一个标准近战武器样板
- 一个标准远程武器样板

#### T8-C3 新角色接入步骤标准化

目标：

- 让“新增角色”有固定步骤

建议步骤：

1. 在 `character_database.gd` 增加新条目
2. 检查 `fighter_assembler.gd` 是否已覆盖所需字段
3. 检查菜单和 HUD 预览是否自动显示
4. 为该角色挑选至少 2 套测试武器组合
5. 跑训练模式 + 对战模式验证

建议产物：

- `docs/new-character-integration-checklist.md` 或写入 M3 文档附录

#### T8-C4 新武器接入步骤标准化

目标：

- 让“新增武器”也有固定步骤

建议步骤：

1. 在 `weapon_database.gd` 增加新条目
2. 补齐全部攻击槽位
3. 检查 `fighter_assembler.gd` 是否能无改动接入
4. 检查投射物型与近战型逻辑是否都能兼容
5. 用两名已有角色分别测试该武器

建议产物：

- `docs/new-weapon-integration-checklist.md` 或写入 M3 文档附录

#### T8-C5 用一个样板新增内容验证模板

目标：

- 不只是写规范，还要证明这套模板真的能用

建议方式：

- 新增一个极简占位角色，复用现有武器验证角色接入
- 或新增一个极简占位武器，复用现有角色验证武器接入

建议优先：

- 先加“占位武器”更便宜，因为攻击数据结构已经比较清楚

### 优先关注文件

- [character_database.gd](/E:/MyGame/Fight/scripts/core/character_database.gd)
- [weapon_database.gd](/E:/MyGame/Fight/scripts/core/weapon_database.gd)
- [fighter_assembler.gd](/E:/MyGame/Fight/scripts/core/fighter_assembler.gd)
- [fighter_catalog.gd](/E:/MyGame/Fight/scripts/core/fighter_catalog.gd)
- [dash_config.gd](/E:/MyGame/Fight/scripts/core/dash_config.gd)

### 验收标准

- 新增 1 个角色或 1 把武器时，不需要改动大块底层逻辑
- 新增内容有固定接入流程可跟
- 文档和代码字段命名一致

---

## T9. 回归测试清单固化

### 目标

把现在零散的“手测经验”，变成固定的版本回归制度。

### 建议输出

- M3 版回归测试清单
- 组合测试矩阵
- 变更类型到测试范围的映射表

### 建议拆卡

1. `T9-C1` 现有 M1/M2 测试项整理
2. `T9-C2` 建立 4 组合固定回归矩阵
3. `T9-C3` 建立按改动类型触发的测试范围表
4. `T9-C4` 建立测试记录模板

### 具体要做什么

#### T9-C1 整理现有测试项

输入来源：

- [mvp-test-checklist.md](/E:/MyGame/Fight/docs/mvp-test-checklist.md)
- 近期规划日志和编程日志中的实际验证项

目标：

- 把流程、战斗、训练、反馈、地图、稳定性测试合并整理

#### T9-C2 固定 4 组合回归矩阵

建议固定矩阵：

- 角色1 + 武器1
- 角色1 + 武器2
- 角色2 + 武器1
- 角色2 + 武器2

后续有新内容后，再在这个基础上增加“新增内容专项矩阵”。

#### T9-C3 建立改动类型 -> 测试范围表

示例：

- 改 `stage.gd`：重点测出生点、镜头、出界、回场
- 改 `fighter.gd`：重点测移动、受击、状态切换、攻击衔接
- 改 `weapon_database.gd`：重点测全部攻击槽位、命中、击飞、节奏差异
- 改 `dash_config.gd`：重点测地面冲刺、空中冲刺、取消窗口、回场

目标：

- 以后每次改动，知道要回归哪些项，而不是全靠记忆

#### T9-C4 建立测试记录模板

建议字段：

- 日期
- 版本/分支
- 改动范围
- 测试人
- 测试组合
- 结果：通过 / 失败 / 待确认
- 备注：复现步骤 / 风险 / 后续动作

建议产物：

- `docs/regression-checklist.md`
- `docs/regression-run-template.md`

### 优先关注文件

- [mvp-test-checklist.md](/E:/MyGame/Fight/docs/mvp-test-checklist.md)
- [planning-log.md](/E:/MyGame/Fight/docs/planning-log.md)
- [programming-log.md](/E:/MyGame/Fight/docs/programming-log.md)

### 验收标准

- 每种常见改动都能映射到明确回归范围
- 回归流程可以交给别人执行，不依赖单人经验
- 至少有一份可重复使用的测试记录模板

---

## T10. 数据调优面板或参数集中区

### 目标

降低调手感和调平衡时的维护成本。

### 现状判断

当前参数主要散落在：

- `character_database.gd`
- `weapon_database.gd`
- `dash_config.gd`
- 以及可能的运行时逻辑默认值

这对早期原型没问题，但随着角色和武器数量增加，会越来越难调。

### 建议输出

- 参数集中区方案
- 统一的命名与分组
- 一版最小可用调优入口

### 建议拆卡

1. `T10-C1` 参数分布盘点
2. `T10-C2` 参数分组方案设计
3. `T10-C3` 第一版参数集中化
4. `T10-C4` 视情况补一个轻量调试面板

### 具体要做什么

#### T10-C1 参数分布盘点

先盘出来当前有哪些参数最常调：

- 角色移动参数
- 跳跃与下落参数
- 冲刺参数
- 攻击时序参数
- 击飞与受击参数
- 投射物参数

目标：

- 明确哪些必须先集中，哪些可以后移

#### T10-C2 参数分组方案设计

建议分组：

- `CharacterTuning`
- `WeaponTuning`
- `DashTuning`
- `CombatTuning`

如果暂时不拆文件，至少也要形成稳定的区块和命名规则。

#### T10-C3 第一版参数集中化

可选方案：

- 方案 A：继续保留数据库脚本，但把默认值和关键常量集中整理
- 方案 B：开始拆成更明确的配置脚本或资源

建议当前项目优先：

- 先做 **方案 A**

原因：

- 成本更低
- 更贴近现有结构
- 适合 M3 的“准备阶段”定位

#### T10-C4 轻量调优面板

这一步不是必须立刻做完，但可以预留。

可做内容：

- 显示当前角色移动参数
- 显示当前武器节奏参数
- 提供少量只读或半手动调试入口

注意：

- M3 不需要一上来就做复杂编辑器
- 先把“参数集中”做好，面板只是锦上添花

### 优先关注文件

- [character_database.gd](/E:/MyGame/Fight/scripts/core/character_database.gd)
- [weapon_database.gd](/E:/MyGame/Fight/scripts/core/weapon_database.gd)
- [dash_config.gd](/E:/MyGame/Fight/scripts/core/dash_config.gd)
- [fighter_assembler.gd](/E:/MyGame/Fight/scripts/core/fighter_assembler.gd)

### 验收标准

- 关键手感参数有统一分组逻辑
- 常调参数不需要跨很多脚本来回找
- 后续平衡调整成本明显下降

---

## 6. 推荐顺序

请按这个顺序推进 M3：

1. 先做 `T8`，把新增内容接入模板定下来
2. 再做 `T9`，把回归制度固化
3. 最后做 `T10`，把参数集中化

原因：

- 没有接入模板，扩内容还是会乱
- 没有回归制度，扩内容会越来越危险
- 没有参数集中区，平衡成本会越来越高

最短理解版：

**先把“怎么加”定下来，再把“怎么验”定下来，最后把“怎么调”定下来。**

---

## 7. 推荐拆卡方式

建议把 M3 拆成下面 10 张卡：

1. 角色字段规范卡
2. 武器字段规范卡
3. 新角色接入清单卡
4. 新武器接入清单卡
5. 样板新增内容验证卡
6. 回归项整理卡
7. 固定组合矩阵卡
8. 测试记录模板卡
9. 参数分布盘点卡
10. 参数集中化落地卡

建议单卡控制在 `0.5d - 1.5d`。

---

## 8. 文件级建议

M3 大概率优先关注这些文件：

- [character_database.gd](/E:/MyGame/Fight/scripts/core/character_database.gd)
- [weapon_database.gd](/E:/MyGame/Fight/scripts/core/weapon_database.gd)
- [fighter_assembler.gd](/E:/MyGame/Fight/scripts/core/fighter_assembler.gd)
- [fighter_catalog.gd](/E:/MyGame/Fight/scripts/core/fighter_catalog.gd)
- [dash_config.gd](/E:/MyGame/Fight/scripts/core/dash_config.gd)
- [mvp-test-checklist.md](/E:/MyGame/Fight/docs/mvp-test-checklist.md)

可能新增：

- `docs/new-character-integration-checklist.md`
- `docs/new-weapon-integration-checklist.md`
- `docs/regression-checklist.md`
- `docs/regression-run-template.md`

---

## 9. 阶段验收口径

只有同时满足下面 3 类条件，才建议认为 M3 完成。

### 9.1 扩展准备通过

- 新增角色 / 武器有固定接入方式
- 至少完成一次模板有效性验证

### 9.2 测试制度通过

- 常见改动有固定回归范围
- 有固定测试记录模板

### 9.3 调优基础通过

- 常用参数已有清晰集中区或分组规则
- 后续调平衡不需要频繁跨脚本翻找

---

## 10. 交付物要求

M3 结束时，建议至少交付这些内容：

- 一份 M3 接入与调优主文档
- 新角色 / 新武器接入清单
- 固定回归清单
- 回归记录模板
- 一版参数集中化整理结果

建议同时附带：

- 当前参数仍分散的遗留点
- 后续最适合扩的第一个新角色或新武器建议
- 哪些地方未来值得继续拆成独立资源或编辑器工具

---

## 11. 给持续推进的最后一句话

M3 不是内容爆发期，而是扩展基础设施期。

请优先围绕下面这条主线推进：

**接入模板 -> 回归制度 -> 参数集中**

只要这三件事做扎实，后面不管是加第 3 个角色、第 3 把武器，还是进入更系统的平衡与版本迭代，成本都会降很多。
