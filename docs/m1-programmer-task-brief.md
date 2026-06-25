# M1 程序任务书

## 1. 这份文档是给谁的

这份文档是给当前阶段负责实现的程序同学的。

目标不是解释整个项目，而是明确：

- 当前阶段要做什么
- 按什么顺序做
- 大概会改哪些文件
- 做到什么程度算完成

如果和其他文档冲突，当前阶段以这份任务书的优先级更高；玩法方向仍以总策划和装配架构文档为准。

相关参考：

- [2d-platform-fighter-design.md](/E:/MyGame/Fight/docs/2d-platform-fighter-design.md)
- [character-weapon-loadout-architecture.md](/E:/MyGame/Fight/docs/character-weapon-loadout-architecture.md)
- [programmer-implementation-handoff.md](/E:/MyGame/Fight/docs/programmer-implementation-handoff.md)
- [project-management-roadmap.md](/E:/MyGame/Fight/docs/project-management-roadmap.md)
- [mvp-test-checklist.md](/E:/MyGame/Fight/docs/mvp-test-checklist.md)

---

## 2. 当前代码现状

当前项目已经有一个可玩的战斗原型，但还没有真正进入“自由搭配 MVP”。

已具备：

- 主菜单
- 对战 / 训练模式入口
- 基础地图
- 2 个原型战斗风格
- 移动、跳跃、空中移动
- 冲刺
- 近战 / 远程攻击
- 投射物
- 受击、伤害、击飞
- 出界、复活、结算
- HUD

当前最关键的问题：

1. `scripts/core/fighter_catalog.gd` 里把人物参数和武器攻击数据写在一起了。
2. `scripts/game/game_scene.gd` 里仍然写死生成两名 fighter。
3. 还没有“选人物 -> 选武器 -> 组合预览 -> 开局”的赛前流程。
4. 文档里定义了 `CharacterModule / WeaponModule / FighterLoadout`，但代码里还没真正落地。

一句话：

**当前要做的不是继续丰富战斗内容，而是把“人物 + 武器自由搭配”这条主链路做通。**

---

## 3. 当前阶段目标

本阶段目标是完成 `M1 可演示 MVP` 的程序主链路。

程序侧必须达成这 4 件事：

1. 拆开人物数据和武器数据
2. 做出 `FighterLoadout`
3. 让战斗场景根据 loadout 生成角色
4. 打通最小赛前装配流程

完成后，至少应支持以下 4 个组合进入战斗：

- 人物 A + 武器 A
- 人物 A + 武器 B
- 人物 B + 武器 A
- 人物 B + 武器 B

---

## 4. 本阶段不要做什么

为了避免跑偏，这一阶段先不要做这些事：

- 不新增联网
- 不新增复杂 AI
- 不新增大量角色或武器
- 不重做完整美术 UI
- 不扩展复杂资源系统
- 不做大规模平衡重构

原则：

**先把主路径跑通，再考虑扩内容和打磨。**

---

## 5. 程序任务拆分

## T1. 拆分人物配置与武器配置

### 目标

把当前 fighter 的一体化配置拆成独立的“人物层”和“武器层”。

### 建议输出

- `CharacterConfig` 结构
- `WeaponConfig` 结构
- `FighterLoadout` 结构

### 现有文件重点

- [fighter_catalog.gd](/E:/MyGame/Fight/scripts/core/fighter_catalog.gd)

### 建议处理方式

- 保留当前两种原型风格，但不要再直接输出完整 fighter 数据
- 改为分别输出：
  - 人物配置
  - 武器配置
  - 默认测试组合
- 冲刺配置、移动能力、体重、跳跃等归人物
- 攻击表、投射物参数、攻击判定等归武器

### 验收标准

- 配置层存在清晰的人物和武器边界
- 同一个人物可搭配不同武器
- 同一个武器可搭配不同人物

---

## T2. 实现 FighterLoadout 与装配器

### 目标

把“人物配置 + 武器配置”装配成战斗中可直接使用的 fighter runtime data。

### 建议输出

- `FighterLoadout`
- `FighterAssembler` 或等价装配逻辑

### 建议新增文件

- `scripts/core/fighter_loadout.gd`
- `scripts/core/fighter_assembler.gd`

### 职责建议

- `FighterLoadout`：保存本局选择结果
- `FighterAssembler`：把人物配置和武器配置合并成 fighter 可消费的运行时字典或对象

### 验收标准

- fighter 实体初始化不再直接依赖一整块写死数据
- runtime data 来自显式装配过程

---

## T3. 改造 GameScene 生成逻辑

### 目标

让对局角色生成不再写死，而是读取 loadout 结果。

### 现有文件重点

- [game_scene.gd](/E:/MyGame/Fight/scripts/game/game_scene.gd)

### 当前问题

当前 `_start_match()` 内部仍然直接指定：

- `sword_fighter()`
- `gunner_fighter()`

这会卡死整个自由搭配链路。

### 改造要求

- `versus` 模式从赛前选择结果读取双方 loadout
- `training` 模式允许走默认测试组合，或者后续接指定组合
- fighter 生成逻辑只消费“装配后的运行时结果”

### 验收标准

- 不改代码也能切换不同组合开局
- 至少 4 个基础组合都能正常进入战斗

---

## T4. 做最小可用赛前流程

### 目标

先做一个可运行、可验证、可演示的赛前装配流程。

### 最小流程

`主菜单 -> 玩家1选人物 -> 玩家1选武器 -> 玩家2选人物 -> 玩家2选武器 -> 组合预览 -> 开始对局`

### UI 要求

- 不要求最终美术
- 可以是简化按钮或临时列表
- 重点是能选、能看、能确认、能进局

### 可能涉及文件

- [main.gd](/E:/MyGame/Fight/scripts/main/main.gd)
- [main.tscn](/E:/MyGame/Fight/scenes/main/main.tscn)
- 新增一个临时 loadout/menu 脚本或场景

### 验收标准

- 双方都能完成选择
- 组合预览能正确显示人物和武器
- 开局结果与预览一致

---

## T5. 对接 HUD 和训练模式基础信息

### 目标

让当前 UI 至少知道本局组合是什么，方便后续测试和调试。

### 建议内容

- HUD 显示 fighter 名称时，能体现当前人物 / 武器组合
- 训练模式可保留默认组合入口
- 为后续显示剩余冲刺、当前武器等信息预留接口

### 现有文件重点

- [hud.gd](/E:/MyGame/Fight/scripts/game/hud.gd)

### 验收标准

- 玩家能看出当前两边使用的组合
- 训练模式不会因为装配改造而失效

---

## 6. 推荐实现顺序

请按下面顺序做，不建议乱序穿插：

1. 重构 `fighter_catalog.gd`，拆出人物配置和武器配置
2. 新建 `fighter_loadout.gd`
3. 新建 `fighter_assembler.gd`
4. 改 `game_scene.gd`，接入装配结果
5. 做临时赛前选择界面
6. 接预览和开局确认
7. 调整 HUD 文案和基础显示
8. 跑 4 组基础组合测试

最短理解版：

**先拆数据，再接装配，再接生成，再补 UI。**

---

## 7. 文件级建议

本阶段建议优先关注这些文件：

- [fighter_catalog.gd](/E:/MyGame/Fight/scripts/core/fighter_catalog.gd)
- [game_scene.gd](/E:/MyGame/Fight/scripts/game/game_scene.gd)
- [main.gd](/E:/MyGame/Fight/scripts/main/main.gd)
- [hud.gd](/E:/MyGame/Fight/scripts/game/hud.gd)

本阶段大概率会新增这些文件：

- `scripts/core/fighter_loadout.gd`
- `scripts/core/fighter_assembler.gd`
- 一个赛前选择流程脚本
- 可能对应一个新的菜单 / 选择场景

如果程序想进一步整理，也可以新增：

- `scripts/core/character_catalog.gd`
- `scripts/core/weapon_catalog.gd`

但不是硬性要求，只要边界拆清楚即可。

---

## 8. 交付物要求

本阶段交付给策划 / PM 时，至少需要这些内容：

- 可运行项目
- 人物配置和武器配置已拆分
- fighter 装配逻辑已接入
- 赛前选择流程可走通
- 可实际验证 4 种组合进入战斗
- UI 能看到组合结果

建议附带：

- 关键改动文件列表
- 当前已知问题列表
- 哪些地方是临时实现

---

## 9. 程序验收口径

只有同时满足下面 3 类条件，才算这一阶段通过。

### 9.1 流程通过

- 能从主菜单进入装配流程
- 双方能完成选择
- 能看到组合预览
- 能进入战斗
- 对局结束后能回菜单

### 9.2 架构通过

- 人物能力不再和武器攻击混写
- fighter 由装配逻辑生成
- `GameScene` 不再写死 fighter 组合

### 9.3 战斗通过

- 4 个基础组合都能跑
- 近战和远程都正常
- 受击、击飞、出界、复活正常
- 不出现明显卡死或无法结算

---

## 10. 给程序的最后一句话

这阶段不是做“更炫的战斗”，而是做“更完整的产品主路径”。

请优先把：

**人物配置 -> 武器配置 -> FighterLoadout -> FighterAssembler -> 赛前选择 -> 对局生成**

这条链路完整做通。只要这条链路通了，后面扩人物、扩武器、做平衡、做 UI 都会容易很多。
