# 2D 平台格斗游戏冲刺系统技术规格书

## 1. 文档目标

这份文档用于定义 **全角色通用的冲刺系统**，给程序、美术、动画、策划统一参考。

目标是：

- 所有角色都有冲刺能力
- 所有角色共享同一套底层规则
- 每个角色可以通过参数和少量特性形成不同手感
- 冲刺既能服务移动，也能服务战斗
- 程序可以直接按本文档拆模块、建配置、写状态机

本文档默认：

- 游戏为 `2D 平台格斗`
- 逻辑帧率为 `60 FPS`
- 所有帧数参数都以 `60 FPS` 为基准
- 所有位移速度单位都写作 `units/s`

---

## 2. 设计目标

冲刺系统要达到下面 6 个效果：

1. 玩家按下冲刺后，角色要立刻有明显响应。
2. 冲刺要能用于切入、拉扯、追击、回场衔接，而不是只是“跑快一点”。
3. 冲刺必须有风险，不能做成全程无敌的万能逃生。
4. 冲刺要和跳跃、攻击、技能形成自然衔接。
5. 不同角色的冲刺手感应该不同，但基础操作逻辑必须统一。
6. 冲刺要支持后期继续扩展成“冲刺攻击”“冲刺取消”“角色专属冲刺特性”。

推荐设计结论：

- 冲刺属于 **全角色共通基础动作**
- 优先支持 **地面冲刺**
- 空中冲刺先不要和地面冲刺混在第一版里
- 推荐使用 **独立冲刺键**
- 可以保留双击方向触发作为后续可选项

---

## 3. 推荐基础规则

第一版建议采用下面这套规则：

### 3.1 触发规则

- 角色处于 `Idle`、`Run`、`Land` 等可行动地面状态时，可以触发冲刺
- 默认使用独立冲刺键触发
- 如果以后支持双击方向触发，需要额外加双击间隔判定

### 3.2 冲刺阶段

每次冲刺分为 3 段：

1. `DashStartup`
   角色进入冲刺准备，给动画和方向锁定一个短窗口
2. `DashTravel`
   角色高速位移，是冲刺的核心阶段
3. `DashRecovery`
   角色从冲刺中收势，决定动作风险和后续衔接

### 3.3 默认行为

- 冲刺方向在开始时确定
- 冲刺开始后的前几帧默认锁方向
- 冲刺期间默认不能再次冲刺
- 冲刺期间允许在指定窗口内跳跃取消或攻击取消
- 冲刺期间离开地面时，进入 `Fall`，并保留一部分水平速度
- 默认不提供完整无敌

### 3.4 第一版不建议直接做的东西

下面这些内容不要和基础冲刺一起首发，否则系统很容易失控：

- 全角色全程无敌冲刺
- 可无限连按的无后摇冲刺
- 冲刺中直接穿人且没有风险
- 冲刺中无条件取消为任意技能
- 角色专属传送冲刺
- 冲刺带护甲、带反弹、带投射物免疫全部同时存在

---

## 4. 冲刺状态机

### 4.1 核心状态

建议增加以下状态：

- `DashStartup`
- `DashTravel`
- `DashRecovery`

角色已有状态建议至少包含：

- `Idle`
- `Run`
- `Jump`
- `Fall`
- `Land`
- `Attack`
- `Hurt`
- `Knockback`
- `Dead`
- `Respawn`

### 4.2 状态流转

| 当前状态 | 条件 | 下一个状态 | 说明 |
| --- | --- | --- | --- |
| `Idle` / `Run` / `Land` | 按下冲刺且满足条件 | `DashStartup` | 冲刺入口 |
| `DashStartup` | 启动帧结束 | `DashTravel` | 开始高速位移 |
| `DashTravel` | 持续帧结束 | `DashRecovery` | 进入收招 |
| `DashStartup` / `DashTravel` / `DashRecovery` | 命中跳跃取消窗口并按跳跃 | `Jump` | 保留部分冲刺速度 |
| `DashStartup` / `DashTravel` / `DashRecovery` | 命中攻击取消窗口并按攻击 | `Attack` | 进入冲刺攻击或普通攻击分支 |
| `DashTravel` | 离开地面 | `Fall` | 保留部分水平速度 |
| `DashStartup` / `DashTravel` / `DashRecovery` | 被命中 | `Hurt` / `Knockback` | 高优先级中断 |
| `DashRecovery` | 帧结束且无输入 | `Idle` | 冲刺结束 |
| `DashRecovery` | 帧结束且有方向输入 | `Run` | 平滑回到跑动 |

### 4.3 状态优先级

建议优先级如下：

`Dead` > `Knockback` > `Hurt` > `Attack` > `Dash` > `Run/Jump/Idle`

意思是：

- 受击一定能打断冲刺
- 冲刺不能压过死亡和击飞
- 冲刺是否能被攻击打断，取决于你是否支持“攻击优先取消”

---

## 5. 程序实现建议

## 5.1 输入方案

推荐实现：

- 主方案：独立冲刺键
- 备选方案：双击方向触发

如果两种都支持，建议判定顺序：

1. 先判独立冲刺键
2. 再判双击方向

这样可以避免误触。

### 5.2 进入条件

满足以下条件时才允许进入冲刺：

- `is_on_floor == true`
- 当前状态属于可冲刺状态
- 当前不在受击、击飞、死亡、复活状态
- 不在冲刺锁定冷却中
- 没有被其他高优先级动作占用

### 5.3 退出条件

符合任一条件时退出冲刺链路：

- 冲刺阶段自然结束
- 跳跃取消成功
- 攻击取消成功
- 被命中
- 掉出平台进入空中
- 角色死亡

### 5.4 位移实现建议

推荐方式：

- `DashStartup`：速度快速抬升或短暂停顿
- `DashTravel`：向目标速度逼近或直接设定冲刺速度
- `DashRecovery`：快速减速，回到 `Run` 或 `Idle`

推荐使用：

- 状态机 + 状态内帧计时器
- 水平速度单独控制
- 冲刺目标速度与常规跑动速度分离

不推荐：

- 用单次瞬移替代冲刺
- 用修改角色整体时间倍率模拟冲刺
- 把冲刺速度写死在角色脚本里

---

## 6. 数据结构建议

建议给每个角色配置一份 `DashConfig`，由角色控制器读取。

更准确地说，`DashConfig` 应该归属于 **人物模块 / CharacterConfig**，因为冲刺本体属于角色移动能力，而不是武器攻击能力。

```ts
type DashConfig = {
  enabled: boolean;
  useDedicatedButton: boolean;
  allowDoubleTap: boolean;
  inputBufferFrames: number;
  doubleTapMaxGapFrames: number;
  reDashLockoutFrames: number;

  startupFrames: number;
  travelFrames: number;
  recoveryFrames: number;

  dashSpeed: number;
  dashAcceleration: number;
  dashBrake: number;
  directionLockFrames: number;
  airCarryRatioOnExit: number;

  allowJumpCancel: boolean;
  jumpCancelStartFrame: number;
  jumpCancelEndFrame: number;

  allowAttackCancel: boolean;
  attackCancelStartFrame: number;
  attackCancelEndFrame: number;
  dashAttackPreserveSpeedRatio: number;

  allowSkillCancel: boolean;
  skillCancelStartFrame: number;
  skillCancelEndFrame: number;

  hasInvulnerability: boolean;
  invulnStartFrame: number;
  invulnEndFrame: number;
  hurtboxScaleX: number;
  hurtboxScaleY: number;

  runOffLedge: boolean;
  stopAtLedge: boolean;
  landingRecoveryFrames: number;

  enableTrailVfx: boolean;
  dashStartSfxId: string;
  dashLoopSfxId: string;
  dashEndSfxId: string;

  uniqueTraitId: string;
};
```

### 6.1 字段设计原则

- 帧数统一使用整数
- 速度统一使用 `units/s`
- 比例统一使用 `0.0 - 1.0`
- 特效和音效只保存资源标识，不直接耦合具体资源实现
- 角色专属差异优先走 `config`，不要优先走硬编码分支

---

## 7. 参数表

## 7.1 输入与触发参数

| 字段名 | 类型 | 单位 | 推荐默认值 | 推荐范围 | 说明 |
| --- | --- | --- | --- | --- | --- |
| `enabled` | `bool` | - | `true` | `true/false` | 是否启用冲刺 |
| `useDedicatedButton` | `bool` | - | `true` | `true/false` | 是否使用独立冲刺键 |
| `allowDoubleTap` | `bool` | - | `false` | `true/false` | 是否允许双击方向触发 |
| `inputBufferFrames` | `int` | 帧 | `6` | `4-8` | 冲刺输入缓冲帧 |
| `doubleTapMaxGapFrames` | `int` | 帧 | `8` | `6-10` | 双击方向的最大间隔 |
| `reDashLockoutFrames` | `int` | 帧 | `6` | `4-10` | 冲刺结束后再次冲刺的锁定帧 |

## 7.2 核心移动参数

| 字段名 | 类型 | 单位 | 推荐默认值 | 推荐范围 | 说明 |
| --- | --- | --- | --- | --- | --- |
| `startupFrames` | `int` | 帧 | `4` | `3-6` | 冲刺启动帧 |
| `travelFrames` | `int` | 帧 | `10` | `8-14` | 冲刺位移主阶段帧数 |
| `recoveryFrames` | `int` | 帧 | `8` | `6-12` | 冲刺收招帧 |
| `dashSpeed` | `float` | `units/s` | `720` | `600-900` | 冲刺目标速度 |
| `dashAcceleration` | `float` | `units/s²` | `4800` | `3600-6500` | 向冲刺目标速度加速 |
| `dashBrake` | `float` | `units/s²` | `5400` | `4200-7000` | 冲刺结束减速能力 |
| `directionLockFrames` | `int` | 帧 | `6` | `4-8` | 冲刺开始后锁定方向的帧数 |
| `airCarryRatioOnExit` | `float` | 比例 | `0.70` | `0.50-0.85` | 冲刺中离地后保留的水平速度比例 |

## 7.3 取消与战斗参数

| 字段名 | 类型 | 单位 | 推荐默认值 | 推荐范围 | 说明 |
| --- | --- | --- | --- | --- | --- |
| `allowJumpCancel` | `bool` | - | `true` | `true/false` | 是否允许跳跃取消 |
| `jumpCancelStartFrame` | `int` | 帧 | `5` | `4-8` | 跳跃取消起始帧 |
| `jumpCancelEndFrame` | `int` | 帧 | `12` | `8-16` | 跳跃取消结束帧 |
| `allowAttackCancel` | `bool` | - | `true` | `true/false` | 是否允许攻击取消 |
| `attackCancelStartFrame` | `int` | 帧 | `6` | `5-9` | 攻击取消起始帧 |
| `attackCancelEndFrame` | `int` | 帧 | `14` | `10-18` | 攻击取消结束帧 |
| `dashAttackPreserveSpeedRatio` | `float` | 比例 | `0.35` | `0.20-0.50` | 冲刺接攻击时保留的水平速度比例 |
| `allowSkillCancel` | `bool` | - | `false` | `true/false` | 是否允许技能取消 |
| `skillCancelStartFrame` | `int` | 帧 | `8` | `6-12` | 技能取消起始帧 |
| `skillCancelEndFrame` | `int` | 帧 | `14` | `10-18` | 技能取消结束帧 |

## 7.4 防御与风险参数

| 字段名 | 类型 | 单位 | 推荐默认值 | 推荐范围 | 说明 |
| --- | --- | --- | --- | --- | --- |
| `hasInvulnerability` | `bool` | - | `false` | `true/false` | 是否带无敌 |
| `invulnStartFrame` | `int` | 帧 | `-1` | `0-6` | 无敌起始帧，`-1` 为禁用 |
| `invulnEndFrame` | `int` | 帧 | `-1` | `1-10` | 无敌结束帧，`-1` 为禁用 |
| `hurtboxScaleX` | `float` | 比例 | `1.00` | `0.90-1.05` | 冲刺时受击盒横向缩放 |
| `hurtboxScaleY` | `float` | 比例 | `1.00` | `0.90-1.05` | 冲刺时受击盒纵向缩放 |
| `runOffLedge` | `bool` | - | `true` | `true/false` | 是否允许冲刺中离开平台 |
| `stopAtLedge` | `bool` | - | `false` | `true/false` | 是否在边缘自动停下 |
| `landingRecoveryFrames` | `int` | 帧 | `4` | `0-8` | 冲刺中离地后落地附加恢复 |

### 7.5 表现参数

| 字段名 | 类型 | 单位 | 推荐默认值 | 说明 |
| --- | --- | --- | --- | --- |
| `enableTrailVfx` | `bool` | - | `true` | 是否显示残影或拖尾 |
| `dashStartSfxId` | `string` | - | `"dash_start_default"` | 冲刺起始音效 |
| `dashLoopSfxId` | `string` | - | `""` | 冲刺持续音效，可为空 |
| `dashEndSfxId` | `string` | - | `"dash_end_default"` | 冲刺结束音效 |
| `uniqueTraitId` | `string` | - | `"none"` | 角色专属冲刺特性标识 |

---

## 8. 推荐默认配置

下面是一份适合作为第一版原型的基准配置。

```json
{
  "enabled": true,
  "useDedicatedButton": true,
  "allowDoubleTap": false,
  "inputBufferFrames": 6,
  "doubleTapMaxGapFrames": 8,
  "reDashLockoutFrames": 6,
  "startupFrames": 4,
  "travelFrames": 10,
  "recoveryFrames": 8,
  "dashSpeed": 720.0,
  "dashAcceleration": 4800.0,
  "dashBrake": 5400.0,
  "directionLockFrames": 6,
  "airCarryRatioOnExit": 0.70,
  "allowJumpCancel": true,
  "jumpCancelStartFrame": 5,
  "jumpCancelEndFrame": 12,
  "allowAttackCancel": true,
  "attackCancelStartFrame": 6,
  "attackCancelEndFrame": 14,
  "dashAttackPreserveSpeedRatio": 0.35,
  "allowSkillCancel": false,
  "skillCancelStartFrame": 8,
  "skillCancelEndFrame": 14,
  "hasInvulnerability": false,
  "invulnStartFrame": -1,
  "invulnEndFrame": -1,
  "hurtboxScaleX": 1.00,
  "hurtboxScaleY": 1.00,
  "runOffLedge": true,
  "stopAtLedge": false,
  "landingRecoveryFrames": 4,
  "enableTrailVfx": true,
  "dashStartSfxId": "dash_start_default",
  "dashLoopSfxId": "",
  "dashEndSfxId": "dash_end_default",
  "uniqueTraitId": "none"
}
```

---

## 9. 角色差异化建议

所有角色都应该拥有冲刺，但差异建议控制在 **参数差异 + 1 个小特性**，不要一上来就做完全不同的系统。

### 9.1 允许差异化的维度

- 冲刺启动速度
- 冲刺距离
- 冲刺收招长短
- 跳跃取消窗口
- 攻击取消窗口
- 冲刺离地后的速度保留比例
- 冲刺残影和音效表现
- 一个小型角色专属冲刺特性

### 9.2 第一版不建议开放过大的差异

- 不建议有人瞬移、有人普通冲刺
- 不建议有人全程无敌、有人完全没有防护
- 不建议有人能任意取消，别人完全不能
- 不建议冲刺直接绑定复杂资源系统

### 9.3 四种角色原型示例

| 角色原型 | `startupFrames` | `travelFrames` | `recoveryFrames` | `dashSpeed` | `jumpCancel` | `attackCancel` | `airCarryRatioOnExit` | 专属特性建议 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 基础剑士 | `4` | `10` | `8` | `720` | `5-12` | `6-14` | `0.70` | 无额外功能，作为基准 |
| 拳套斗士 | `3` | `9` | `7` | `780` | `4-11` | `5-12` | `0.78` | 冲刺接轻攻击更快 |
| 长枪守卫 | `5` | `11` | `10` | `680` | `7-12` | `8-16` | `0.62` | 冲刺后更适合接突刺 |
| 远程炮手 | `4` | `8` | `9` | `650` | `6-10` | `8-13` | `0.68` | 冲刺后可接后撤射击 |

---

## 10. 推荐专属冲刺特性做法

如果你想让“每个角色都有自己的冲刺效果”，推荐做成下面这种轻量结构：

### 10.1 结构建议

- 公共冲刺系统负责移动与状态机
- 角色专属特性只挂在冲刺的某个节点上
- 每个角色最多只挂 1 个冲刺特性

### 10.2 推荐挂点

- `on_dash_start`
- `on_dash_travel_enter`
- `on_dash_attack_cancel`
- `on_dash_end`

### 10.3 推荐特性示例

| `uniqueTraitId` | 触发时机 | 效果 | 风险 |
| --- | --- | --- | --- |
| `none` | - | 无 | 无 |
| `quick_jab_bonus` | `on_dash_attack_cancel` | 冲刺接轻攻击启动更快 `2` 帧 | 只对轻攻击生效 |
| `pierce_ready` | `on_dash_end` | 冲刺结束后短时间强化突刺判定 | 收招略长 |
| `backstep_shot` | `on_dash_attack_cancel` | 冲刺接射击时附加后退速度 | 近身压制能力变弱 |
| `guard_ready` | `on_dash_start` | 启动阶段受击盒横向缩小 | 不是无敌，只是更难被打中 |

建议第一版只做下面两类：

- 攻击衔接类
- 小幅判定或速度修正类

不要第一版就做：

- 完整反击技
- 带伤害的冲刺本体
- 带护甲和投射物反弹的冲刺

---

## 11. 位移计算建议

## 11.1 简化实现

如果你需要快速原型，可以直接在 `DashTravel` 阶段使用固定水平速度：

```ts
velocity.x = facing * dashSpeed;
```

优点：

- 实现快
- 手感直接
- 好调试

缺点：

- 启动和结束变化不够柔和

## 11.2 标准实现

推荐在 `DashStartup` 和 `DashRecovery` 阶段加入速度逼近：

```ts
velocity.x = moveToward(velocity.x, facing * dashSpeed, dashAcceleration * dt);
```

```ts
velocity.x = moveToward(velocity.x, targetRunSpeed, dashBrake * dt);
```

### 11.3 离开地面时的处理

当角色在 `DashTravel` 中离开地面：

- 进入 `Fall`
- 保留水平速度：

```ts
velocity.x *= airCarryRatioOnExit;
```

这样做的好处是：

- 冲刺可以自然衔接回场
- 从平台冲出时不会显得突然断速
- 角色手感会更顺

---

## 12. 取消规则建议

### 12.1 跳跃取消

建议：

- 在 `DashTravel` 中后段开放跳跃取消
- 不建议第 `1` 帧就能取消，否则冲刺存在感太弱

推荐效果：

- 冲刺接跳跃可以形成更灵活的切入和追击
- 跳跃取消后保留一部分水平速度

### 12.2 攻击取消

建议：

- 冲刺攻击优先进入专用 `dash_attack` 分支
- 如果没有专用冲刺攻击，再回退到普通攻击

推荐逻辑：

1. 玩家在攻击取消窗口输入攻击
2. 检查武器是否存在 `dash_attack`
3. 有就进入 `dash_attack`
4. 没有就进入普通地面攻击

### 12.3 技能取消

第一版建议默认关闭。

原因：

- 很容易导致角色无脑切入
- 会显著放大平衡难度
- 程序实现也更容易把状态优先级写乱

---

## 13. 与其他系统的交互规则

## 13.1 与武器系统

- 近战角色可以把冲刺接普攻做成切入手段
- 远程角色的冲刺更适合拉扯和重置距离
- `dash_attack` 建议作为武器动作配置的一部分

### 13.2 与跳跃系统

- 冲刺接跳跃必须保留部分水平惯性
- 允许与短跳、长跳、快速下落自然衔接

### 13.3 与受击系统

- 冲刺默认不能无条件穿过攻击
- 被命中后必须按正常受击规则走
- 除非角色专属特性明确配置，否则不要给隐藏减伤

### 13.4 与平台系统

- 冲刺经过单向平台时，不应该意外掉落
- 如果支持 `runOffLedge`，冲刺冲出边缘时必须平滑进入空中
- 如果支持 `stopAtLedge`，要防止角色在边缘抖动

---

## 14. 动画与表现要求

冲刺动作至少要有下面这些反馈：

- 起步重心变化
- 位移残影或速度线
- 地面摩擦尘土或脚底拖影
- 起始音效
- 结束音效
- 必要时的轻微镜头拉伸或角色 squash/stretch

程序需要留出这些事件：

- `dash_start`
- `dash_travel_enter`
- `dash_cancel_jump`
- `dash_cancel_attack`
- `dash_end`
- `dash_interrupted`

如果没有这些事件，后续动画和特效会非常难接。

---

## 15. 调参优先级

调冲刺手感时，建议按下面顺序调：

1. `startupFrames`
2. `dashSpeed`
3. `travelFrames`
4. `recoveryFrames`
5. `jumpCancel` 窗口
6. `attackCancel` 窗口
7. `airCarryRatioOnExit`

调参原则：

- 冲刺觉得“迟钝”，优先减 `startupFrames`
- 冲刺觉得“滑过头”，优先减 `travelFrames` 或 `dashSpeed`
- 冲刺太无脑，优先加 `recoveryFrames`
- 冲刺接战斗不丝滑，优先调取消窗口
- 冲刺出平台后太假，优先调 `airCarryRatioOnExit`

---

## 16. 开发任务拆分建议

程序可以按下面顺序实现：

1. 新增 `DashStartup / DashTravel / DashRecovery` 状态
2. 接入冲刺输入判断和进入条件
3. 做基础位移和计时器
4. 做离地转 `Fall`
5. 做跳跃取消
6. 做攻击取消
7. 接入 `DashConfig`
8. 接动画事件和特效事件
9. 做角色参数差异
10. 最后再加专属冲刺特性

---

## 17. 测试清单

### 17.1 功能测试

- 地面站立时可以冲刺
- 跑动中可以冲刺
- 受击中不能冲刺
- 冲刺后不能无限立刻再次冲刺
- 冲刺可正常进入跳跃取消
- 冲刺可正常进入攻击取消
- 冲刺中离开平台会进入空中
- 冲刺结束后可正常回到 `Idle` 或 `Run`

### 17.2 手感测试

- 玩家是否觉得冲刺按下就有响应
- 冲刺距离是否容易控制
- 冲刺是否太像“瞬移”
- 冲刺是否太像“跑步加速”
- 冲刺接攻击是否顺手
- 冲刺接跳跃是否自然

### 17.3 平衡测试

- 冲刺是否让远程角色太容易拉开距离
- 冲刺是否让近战角色太容易无脑贴脸
- 是否有角色因为冲刺参数过强而失衡
- 是否有人物因为收招太长而几乎不想用冲刺

---

## 18. 最终建议

第一版最稳的方案是：

- 所有人共用一套冲刺状态机
- 所有人都有冲刺键
- 先做地面冲刺
- 先不做全局无敌
- 先做跳跃取消和攻击取消
- 角色差异先走参数和一个小特性

一句话总结：

**冲刺应该是“共通基础动作 + 参数差异 + 轻量角色特性”，而不是每个角色各写一套独立系统。**
