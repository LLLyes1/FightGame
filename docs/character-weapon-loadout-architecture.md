# 人物模块与武器模块自由搭配架构说明

## 1. 文档目标

这份文档用于明确游戏的核心装配架构：

- 游戏角色由 **人物模块** 和 **武器模块** 两部分组成
- 玩家在进入对局前，可以 **自由选择人物和武器进行组合**
- 人物决定角色本体特性
- 武器决定攻击方式和招式结构
- 程序需要支持运行时把两者组装成一个可战斗单位

这份文档面向：

- 程序
- 策划
- 动画
- UI / 交互

---

## 2. 核心结论

这个项目推荐采用下面这套结构：

- `CharacterModule`：决定角色身体和移动特性
- `WeaponModule`：决定角色攻击语言和招式数据
- `FighterLoadout`：决定本局实际使用的“人物 + 武器”组合
- `FighterEntity`：对局中真正生成出来的战斗实体

一句话定义：

**人物负责“怎么动”，武器负责“怎么打”，对局开始前允许玩家自由搭配。**

例如：

- 天使角色可以滑翔
- 忍者角色可以有更多跳跃
- 长枪决定刺击和控距打法
- 大锤决定慢速重击和终结能力

所以：

- `天使 + 长枪`
- `天使 + 大锤`
- `忍者 + 长枪`
- `忍者 + 大锤`

都应该是合法组合，只要资源和动画方案支持。

---

## 3. 模块边界

## 3.1 人物模块负责什么

人物模块只负责 **角色本体属性**，不负责武器招式本身。

推荐归属到 `CharacterModule` 的内容：

- 地面移动速度
- 加速度 / 减速度
- 跳跃高度
- 跳跃次数
- 空中控制
- 快速下落
- 冲刺参数
- 是否可滑翔
- 滑翔下落速度
- 是否可墙跳
- 体重 / 击飞抗性
- 角色体型
- `Hurtbox`
- `Pushbox`
- 角色被动
- 角色移动类特殊能力
- 与身体相关的专属特性

典型例子：

- “可以滑翔” 属于人物模块
- “有 3 段跳” 属于人物模块
- “冲刺更快” 属于人物模块
- “更重，不容易被打飞” 属于人物模块

## 3.2 武器模块负责什么

武器模块只负责 **攻击方式和招式结构**，不负责角色身体本体能力。

推荐归属到 `WeaponModule` 的内容：

- 普攻
- 重攻击
- 上 / 下 / 前方向攻击
- 空中攻击
- 冲刺攻击
- 投射物攻击
- 蓄力攻击
- 招式帧数据
- `Hitbox`
- 攻击角度
- 伤害
- 击飞倍率
- 连段倾向
- 武器攻击特效
- 武器攻击音效
- 弹药 / 过热 / 蓄力等武器资源

典型例子：

- “长枪前攻击是远距离直刺” 属于武器模块
- “弓可以蓄力发射箭矢” 属于武器模块
- “大锤命中后击飞更强” 属于武器模块
- “拳套轻攻击启动更快” 属于武器模块

## 3.3 判断归属的规则

如果一个能力主要改变的是 **身体移动或身体状态**，放到人物模块。

如果一个能力主要改变的是 **攻击判定或攻击行为**，放到武器模块。

快速判断规则：

- 改“移动”看人物
- 改“出招”看武器

---

## 4. 自由搭配的游戏流程

既然人物和武器分开，就要把对局前流程设计成真正的自由装配。

推荐流程：

1. 玩家进入模式选择
2. 玩家进入人物选择界面
3. 玩家选定人物
4. 玩家进入武器选择界面
5. 玩家选定武器
6. 系统显示本局组合预览
7. 玩家确认装配
8. 游戏生成本局 `FighterLoadout`
9. 对局开始，生成组合后的 `FighterEntity`

### 4.1 推荐 UI 信息

人物选择界面建议显示：

- 人物名
- 移动能力
- 跳跃次数
- 是否可滑翔
- 是否擅长空战 / 地战
- 被动特性

武器选择界面建议显示：

- 武器名
- 攻击距离
- 攻击节奏
- 连段倾向
- 击飞能力
- 是否远程
- 武器特殊机制

组合预览界面建议显示：

- 当前人物
- 当前武器
- 最终跳跃次数
- 是否可滑翔
- 冲刺风格
- 攻击风格标签
- 预计上手难度

### 4.2 推荐的交互逻辑

推荐先选人物，再选武器。

原因：

- 玩家更容易先从“我想玩谁”开始
- 人物模块更影响手感基础
- 武器选择像是在该角色基础上决定战斗语言

但程序层不要写死顺序。

底层结构应该支持：

- 先选人物后选武器
- 先选武器后选人物
- 随机人物 + 随机武器
- 上局同组合一键复用

---

## 5. 程序架构总览

推荐运行时结构如下：

```text
PlayerInput
    -> LoadoutSelection
    -> FighterAssembler
        -> CharacterModule
        -> WeaponModule
        -> SharedStateMachine
        -> CombatResolver
        -> AnimationBridge
        -> VfxSfxBridge
```

### 5.1 组件职责

| 组件 | 责任 |
| --- | --- |
| `LoadoutSelection` | 保存玩家本局选的人物和武器 |
| `FighterAssembler` | 根据 `characterId + weaponId` 组装角色 |
| `CharacterModule` | 提供移动、跳跃、冲刺、滑翔、被动等能力 |
| `WeaponModule` | 提供攻击表、判定、武器资源、攻击表现 |
| `SharedStateMachine` | 管理 `Idle/Run/Jump/Fall/Attack/Hurt/Dash` 等通用状态 |
| `CombatResolver` | 处理命中、受击、击飞、伤害计算 |
| `AnimationBridge` | 根据人物和武器组合切动画 |
| `VfxSfxBridge` | 播放对应武器或人物的表现资源 |

### 5.2 关键原则

- 状态机尽量共享，不要每个角色各写一套
- 人物和武器都尽量数据驱动
- 组合逻辑集中在 `FighterAssembler`
- 对局内不要频繁改动模块边界

---

## 6. 数据结构建议

推荐至少有下面 3 张核心数据表：

1. `CharacterConfig`
2. `WeaponConfig`
3. `FighterLoadout`

### 6.1 CharacterConfig

```ts
type CharacterConfig = {
  id: string;
  displayName: string;

  moveSpeed: number;
  moveAcceleration: number;
  moveBrake: number;

  jumpCount: number;
  jumpVelocity: number;
  airAcceleration: number;
  fastFallSpeed: number;

  canGlide: boolean;
  glideFallSpeed: number;
  glideHorizontalControl: number;

  canWallJump: boolean;
  wallJumpPower: number;

  weight: number;
  knockbackResistance: number;

  hurtboxProfileId: string;
  pushboxProfileId: string;

  dashConfigId: string;

  passiveTraitIds: string[];
  movementTraitIds: string[];
  uniqueSkillIds: string[];

  animationRigId: string;
  voicePackId: string;
};
```

### 6.2 WeaponConfig

```ts
type WeaponConfig = {
  id: string;
  displayName: string;
  weaponType: string;

  isRanged: boolean;
  rangeClass: "short" | "mid" | "long";

  lightGroundAttackId: string;
  heavyGroundAttackId: string;
  upGroundAttackId: string;
  downGroundAttackId: string;
  dashAttackId: string;

  neutralAirAttackId: string;
  forwardAirAttackId: string;
  upAirAttackId: string;
  downAirAttackId: string;

  specialNeutralId: string;
  specialSideId: string;
  specialUpId: string;
  specialDownId: string;

  projectileSetId: string;
  ammoRuleId: string;
  heatRuleId: string;

  attackVfxSetId: string;
  attackSfxSetId: string;
};
```

### 6.3 FighterLoadout

```ts
type FighterLoadout = {
  playerSlot: number;
  characterId: string;
  weaponId: string;
  skinId: string;
  colorId: string;
};
```

### 6.4 运行时实体

```ts
type FighterEntity = {
  loadout: FighterLoadout;
  character: CharacterConfig;
  weapon: WeaponConfig;
  runtimeState: FighterRuntimeState;
};
```

---

## 7. 运行时装配逻辑

程序建议按下面逻辑装配：

1. 读取玩家本局 `FighterLoadout`
2. 根据 `characterId` 读取 `CharacterConfig`
3. 根据 `weaponId` 读取 `WeaponConfig`
4. 创建 `FighterEntity`
5. 把人物移动参数注入角色控制器
6. 把武器攻击数据注入攻击控制器
7. 把人物与武器资源分别绑定给动画和特效桥接层
8. 进入对局

### 7.1 装配伪代码

```ts
function buildFighter(loadout: FighterLoadout): FighterEntity {
  const character = CharacterDatabase.get(loadout.characterId);
  const weapon = WeaponDatabase.get(loadout.weaponId);

  return {
    loadout,
    character,
    weapon,
    runtimeState: createRuntimeState(character, weapon),
  };
}
```

### 7.2 控制器注入示例

```ts
movementController.applyCharacterConfig(character);
combatController.applyWeaponConfig(weapon);
dashController.applyDashConfig(DashDatabase.get(character.dashConfigId));
```

这个结构说明：

- 滑翔来自人物
- 多段跳来自人物
- 冲刺来自人物
- 攻击动作来自武器
- 冲刺攻击属于武器动作，但冲刺本体属于人物动作

---

## 8. 什么内容放哪边

下面这张表是最重要的程序边界表。

| 内容 | 归属模块 | 原因 |
| --- | --- | --- |
| `jumpCount` | `CharacterModule` | 属于身体移动能力 |
| `canGlide` | `CharacterModule` | 属于身体移动能力 |
| `glideFallSpeed` | `CharacterModule` | 属于滑翔特性 |
| `dashConfigId` | `CharacterModule` | 冲刺本体是角色移动能力 |
| `weight` | `CharacterModule` | 决定身体抗击飞属性 |
| `hurtboxProfileId` | `CharacterModule` | 角色体型属性 |
| `lightGroundAttackId` | `WeaponModule` | 攻击来自武器 |
| `dashAttackId` | `WeaponModule` | 冲刺攻击是攻击动作，不是移动动作 |
| `projectileSetId` | `WeaponModule` | 投射物来自武器攻击 |
| `ammoRuleId` | `WeaponModule` | 武器资源 |
| `attackVfxSetId` | `WeaponModule` | 攻击表现属于武器 |

### 8.1 处理争议内容的规则

有些能力会看起来像跨模块，比如：

- “滑翔时可以发射箭”
- “冲刺结束后下一次攻击更强”
- “空中多跳后下劈范围变大”

处理规则建议是：

- 行为触发条件属于人物，就在人物模块发事件
- 攻击表现和命中效果属于武器，就在武器模块消费事件

也就是：

- 人物模块负责“我现在能不能这样动”
- 武器模块负责“我这样动之后怎么打”

---

## 9. 自由搭配下的设计要求

既然人物和武器可以自由组合，程序和资源就必须提前统一规范。

### 9.1 必须统一的东西

- 动作槽位命名
- 攻击输入槽位
- 角色骨骼挂点
- 武器挂点
- `Hitbox` 命名规则
- 攻击数据格式

### 9.2 推荐统一的攻击槽位

建议所有武器都支持这些槽位：

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

这样自由搭配才不会让控制逻辑爆炸。

### 9.3 动画层的注意事项

自由搭配最难的通常不是代码，而是动画和表现。

至少要统一：

- 人物骨架标准
- 武器挂点命名
- 攻击动画触发时机
- 判定盒锚点

如果这些不统一，就会出现：

- 武器拿在手上的位置不对
- 攻击动作和判定对不上
- 某些人物装某把武器后动作穿模

---

## 10. 兼容性规则建议

如果你坚持完全自由搭配，第一版建议：

- 默认所有人物都能装备所有武器
- 先不要加复杂的装备限制
- 平衡问题先用参数调，不要先用禁配规则处理

如果后期组合数太多不好控，可以加可选兼容层：

```ts
type CompatibilityRule = {
  characterId: string;
  weaponId: string;
  allowed: boolean;
  reason: string;
};
```

但建议：

- 第一版默认不启用
- 只作为后期补救工具

---

## 11. 程序开发顺序建议

如果按这个架构开工，程序建议按下面顺序做：

1. 建 `CharacterConfig` 数据表
2. 建 `WeaponConfig` 数据表
3. 建 `FighterLoadout` 数据结构
4. 做人物选择界面
5. 做武器选择界面
6. 做 `FighterAssembler`
7. 做人物移动能力注入
8. 做武器攻击能力注入
9. 让 `CharacterModule` 和 `WeaponModule` 跑通一套共享状态机
10. 做组合预览界面
11. 做自由搭配测试
12. 最后再调平衡

---

## 12. 示例组合

### 12.1 天使 + 长枪

- 人物模块提供：滑翔、2 段跳、中等冲刺
- 武器模块提供：中远距离刺击、对空优势
- 最终打法：空中控距 + 回场稳定

### 12.2 天使 + 大锤

- 人物模块提供：滑翔、2 段跳、中等冲刺
- 武器模块提供：慢速重击、高击飞
- 最终打法：空中停留骗位后找终结

### 12.3 忍者 + 长枪

- 人物模块提供：3 段跳、高机动、短冲
- 武器模块提供：中远距离直刺
- 最终打法：高机动切入 + 长距离点杀

### 12.4 忍者 + 大锤

- 人物模块提供：3 段跳、高机动、短冲
- 武器模块提供：慢速大范围重击
- 最终打法：靠机动补足武器笨重

这几个例子本质上说明了一件事：

**人物模块和武器模块的组合，会直接形成角色打法。**

---

## 13. 最终建议

你现在这套项目最合理的程序架构就是：

- 角色拆成人物模块和武器模块
- 对局前允许自由搭配
- 人物决定移动和身体特性
- 武器决定攻击方式
- 对局中通过 `FighterLoadout` 组装成真正的战斗单位

一句话总结：

**不要把“人物 = 武器”绑死，应该让“人物是底盘，武器是战斗风格”，然后让玩家在开局前自由组合。**
