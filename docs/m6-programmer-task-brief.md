# M6 程序任务简报

## 1. 这份文档的作用

这份文档不是讨论“要不要扩内容”，而是默认：

**M5 已完成，项目正式进入 M6 内容丰富阶段。**

程序侧在 M6 的核心职责是：

- 让新内容能低成本接入
- 让地图与模式扩张不会把现有结构打乱
- 让组合信息和表现层补强有稳定落点

M6 不建议作为“大重构阶段”，而应该作为：

**基于现有架构继续扩内容、补模式、补表现的生产阶段。**

---

## 2. M6 程序工作总目标

程序侧主要完成五件事：

1. 支撑新角色与新武器接入
2. 支撑多地图稳定切换与验证
3. 支撑至少一种新模式落地
4. 支撑菜单中的组合认知信息展示
5. 支撑更完整的局内外反馈表现

---

## 3. M6 推荐执行顺序

1. `T20` 第一波内容接入
2. `T21` 地图池扩张
3. `T22` 轻量模式接入
4. `T23` 组合认知层补强
5. `T24` 表现层补强
6. `T25` 全量回归与阶段评审

---

## 4. T20 第一波内容接入

## T20-C1 新角色 archetype 选型

### 目标

为第 4 名角色确定清晰定位，避免做成已有角色的轻微变体。

### 建议方向

- `trickster`
- `precision`

### 主要输入

- `docs/m4-character-positioning.md`
- `docs/m5-roster-balance-report.md`（完成后）

### 输出

- `docs/m6-character-positioning.md`

### 完成标准

- 新角色和现有三名角色有明确区分

---

## T20-C2 新角色数据接入

### 目标

把第 4 名角色接入现有角色数据库、组装流程和选择流程。

### 主要文件

- [character_database.gd](/E:/MyGame/Fight/scripts/core/character_database.gd)
- [fighter_catalog.gd](/E:/MyGame/Fight/scripts/core/fighter_catalog.gd)
- [fighter_assembler.gd](/E:/MyGame/Fight/scripts/core/fighter_assembler.gd)
- [main.gd](/E:/MyGame/Fight/scripts/main/main.gd)

### 完成标准

- 新角色可在菜单中选择
- 能和全部武器合法组合
- 能进入 `versus` 与 `training`

---

## T20-C3 新武器 archetype 选型

### 目标

为第 4 把武器确定和 `saber / hand_cannon / halberd` 不重复的玩法位置。

### 建议方向

- `gauntlets`
- `bow`
- `chakram`

### 主要输入

- `docs/m4-weapon-positioning.md`
- `docs/m5-roster-balance-report.md`（完成后）

### 输出

- `docs/m6-weapon-positioning.md`

### 完成标准

- 新武器定位清楚，不和旧武器撞位

---

## T20-C4 新武器数据接入

### 目标

把第 4 把武器接入武器数据库与战斗调用链。

### 主要文件

- [weapon_database.gd](/E:/MyGame/Fight/scripts/core/weapon_database.gd)
- [fighter_assembler.gd](/E:/MyGame/Fight/scripts/core/fighter_assembler.gd)
- [main.gd](/E:/MyGame/Fight/scripts/main/main.gd)

### 完成标准

- 新武器可被所有角色合法装配
- 训练模式与正式对局均可调用

---

## T20-C5 内容波回归验证

### 目标

确认从 `3x3` 扩到 `4x4` 后，系统仍稳定。

### 主要文件

- [m4_regression_runner.gd](/E:/MyGame/Fight/scripts/tools/m4_regression_runner.gd)
- [regression-test-checklist.md](/E:/MyGame/Fight/docs/regression-test-checklist.md)

### 完成标准

- 至少完成一轮自动验证
- 新角色、新武器各有人工测试记录

---

## 5. T21 地图池扩张

## T21-C1 第二正式地图接入

### 目标

新增一张偏空战或平台调度型地图。

### 主要文件

- 场景资源文件
- [game_scene.gd](/E:/MyGame/Fight/scripts/game/game_scene.gd)
- [main.gd](/E:/MyGame/Fight/scripts/main/main.gd)

### 完成标准

- 地图可选
- 摄像机、出生点、出界逻辑正常

---

## T21-C2 第三正式地图接入

### 目标

新增一张偏压边或回场压力型地图。

### 完成标准

- 和第二张地图在平台结构定位上有明显差异

---

## T21-C3 地图选择与地图说明

### 目标

让玩家在进局前知道地图差异，而不是只能靠试。

### 主要文件

- [main.gd](/E:/MyGame/Fight/scripts/main/main.gd)
- [scenes/main/main.tscn](/E:/MyGame/Fight/scenes/main/main.tscn)

### 完成标准

- 菜单能显示地图名称
- 至少有一句地图定位说明

---

## 6. T22 轻量模式建设

## T22-C1 生存/街机模式基础框架

### 目标

提供一个非纯对人对战的可重复游玩入口。

### 建议最小功能

- 玩家选一个组合进入
- 连续进行多局
- 记录胜场或通关层数

### 完成标准

- 能稳定从菜单进入并完成一轮流程

---

## T22-C2 挑战模式基础框架

### 目标

给训练和游玩之间增加一个带目标的轻量模式。

### 建议最小挑战

- 指定组合
- 指定地图
- 指定目标

### 完成标准

- 至少能接入 2-3 个固定挑战

---

## T22-C3 预设组合入口

### 目标

帮助新玩家不用自己理解全部内容，也能快速开始。

### 主要文件

- [main.gd](/E:/MyGame/Fight/scripts/main/main.gd)

### 完成标准

- 至少有 3 组官方预设组合可直接进入

---

## 7. T23 组合认知层补强

## T23-C1 角色与武器定位展示

### 目标

让玩家在选择界面就能理解对象定位。

### 主要文件

- [main.gd](/E:/MyGame/Fight/scripts/main/main.gd)
- [main.tscn](/E:/MyGame/Fight/scenes/main/main.tscn)

### 完成标准

- 每名角色、每把武器至少有一句定位文案

---

## T23-C2 组合推荐标签

### 目标

给组合增加易读标签，帮助玩家理解玩法风格。

### 示例标签

- 压制型
- 回场稳健
- 高机动
- 上手简单
- 高风险高收益

### 完成标准

- 菜单可显示组合标签或摘要

---

## T23-C3 新手推荐组合

### 目标

降低新玩家的首次决策成本。

### 完成标准

- 至少明确 2-3 组推荐组合
- 菜单内能看出“推荐”含义

---

## 8. T24 表现层补强

## T24-C1 选择反馈增强

### 目标

让角色/武器/地图选择更有确认感。

### 建议内容

- 高亮
- 音效
- 简短说明更新

### 完成标准

- 玩家切换选择时有清楚反馈

---

## T24-C2 对局开始与结束反馈增强

### 目标

让每一局更像完整一局，而不是直接硬切开始与结束。

### 主要文件

- [game_scene.gd](/E:/MyGame/Fight/scripts/game/game_scene.gd)
- [hud.gd](/E:/MyGame/Fight/scripts/game/hud.gd)

### 完成标准

- 有更明确的开局提示
- 有更明确的结算信息

---

## T24-C3 局内关键反馈增强

### 目标

提升击中、击飞、回场、终结时的辨识度。

### 完成标准

- 至少一类关键事件反馈明显增强
- 不影响当前训练读数可用性

---

## 9. T25 M6 收口与评审

## T25-C1 新内容验证

### 目标

确认 `4x4` 阵容和 3 图池没有明显结构性问题。

### 完成标准

- 自动验证可跑
- 人工验证有报告

---

## T25-C2 模式验证

### 目标

确认新模式不是只能演示，而是真的能玩完。

### 完成标准

- 生存/挑战至少一项完整可走通

---

## T25-C3 下一阶段评审

### 目标

决定项目是继续扩内容，还是开始偏产品化补强。

### 建议输出

- `docs/m6-gate-review.md`

### 完成标准

- 团队明确知道 M7 是继续扩内容还是转向产品化

---

## 10. 对程序侧的最后一句话

M6 程序工作的重点不是“为了功能而功能”，而是：

**让新角色、新武器、新地图、新模式都能顺利接进现有系统，并且让玩家真正感知到游戏内容正在变丰富。**
