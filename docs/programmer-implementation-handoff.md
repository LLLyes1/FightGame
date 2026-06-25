# 2D 平台格斗项目程序施工文档

## 1. 项目一句话目标

制作一个 `2D 平台格斗游戏` 原型。

玩家在开局前可以自由选择：

- `人物`
- `武器`

进入对局后，人物和武器组合成一个完整战斗单位。

核心规则：

- 人物决定移动能力和身体特性
- 武器决定攻击方式和招式结构
- 对局前自由搭配人物与武器
- 第一版只做本地 `1v1` 原型

---

## 2. 第一版 MVP 范围

第一版只需要完成能验证核心玩法的最小版本。

必须做：

- 本地 `1v1`
- 2 个人物
- 2 把武器
- 1 张测试地图
- 人物与武器自由搭配
- 基础移动
- 跳跃和多段跳
- 冲刺
- 至少 1 个特殊移动能力，例如滑翔
- 地面攻击
- 空中攻击
- 冲刺攻击
- 近战武器判定
- 远程武器投射物
- 受击
- 伤害累计
- 击飞
- 出界死亡
- 复活
- 简单胜负规则
- 基础 UI
- 调试显示

第一版不要做：

- 联网
- 剧情
- 装备成长
- 技能树
- 大量角色
- 大量地图
- 复杂 AI
- 排位系统
- 皮肤商城

第一版目标不是内容量，而是验证：

**人物 + 武器自由搭配后，移动、攻击、受击、击飞是否好玩。**

---

## 3. 核心架构

项目拆成 4 个核心概念。

| 名称 | 作用 |
| --- | --- |
| `CharacterModule` | 人物模块，决定怎么动 |
| `WeaponModule` | 武器模块，决定怎么打 |
| `FighterLoadout` | 本局玩家选择的人物和武器组合 |
| `FighterEntity` | 对局中生成出来的实际战斗实体 |

一句话：

**人物是底盘，武器是战斗风格，`FighterLoadout` 是装配单。**

---

## 4. 模块边界

## 4.1 人物模块负责什么

`CharacterModule` 只负责人物本体能力。

包含：

- 移动速度
- 加速度
- 刹车速度
- 跳跃高度
- 跳跃次数
- 空中控制
- 快速下落
- 冲刺参数
- 是否可滑翔
- 滑翔下落速度
- 是否可墙跳
- 体重
- 抗击飞
- 角色体型
- `Hurtbox`
- `Pushbox`
- 人物被动
- 人物特殊移动能力

例子：

- 天使可以滑翔
- 忍者有 3 段跳
- 重甲角色更重，不容易被打飞
- 拳斗型人物冲刺更快

这些都属于人物模块。

## 4.2 武器模块负责什么

`WeaponModule` 只负责攻击方式。

包含：

- 轻攻击
- 重攻击
- 上攻击
- 下攻击
- 冲刺攻击
- 空中攻击
- 特殊攻击
- 投射物
- 招式帧数据
- 攻击判定 `Hitbox`
- 伤害
- 击飞角度
- 击飞倍率
- 攻击特效
- 攻击音效
- 弹药
- 过热
- 蓄力

例子：

- 长枪的前攻击是直刺
- 大锤攻击慢但击飞强
- 弓可以蓄力射箭
- 手炮有装填或过热限制

这些都属于武器模块。

## 4.3 容易混淆的边界

| 内容 | 归属 | 原因 |
| --- | --- | --- |
| 多段跳 | 人物 | 身体移动能力 |
| 滑翔 | 人物 | 身体移动能力 |
| 冲刺本体 | 人物 | 移动能力 |
| 冲刺攻击 | 武器 | 攻击动作 |
| 体重 | 人物 | 身体属性 |
| 受击盒 | 人物 | 体型属性 |
| 攻击盒 | 武器 | 攻击判定 |
| 投射物 | 武器 | 攻击行为 |
| 弹药 | 武器 | 武器资源 |

判断规则：

**改移动看人物，改出招看武器。**

---

## 5. 游戏流程

第一版对局流程：

1. 进入主菜单
2. 进入本地对战
3. 玩家 1 选择人物
4. 玩家 1 选择武器
5. 玩家 2 选择人物
6. 玩家 2 选择武器
7. 显示双方组合预览
8. 进入地图
9. 根据 `FighterLoadout` 生成双方 `FighterEntity`
10. 开始战斗
11. 出界或击杀后复活
12. 达到胜负条件后结算

第一版推荐胜负规则：

- 每人 `3` 条命
- 出界扣 1 条命
- 生命归零判负

---

## 6. 数据结构建议

## 6.1 CharacterConfig

人物配置表。

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

## 6.2 WeaponConfig

武器配置表。

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

## 6.3 FighterLoadout

本局装配数据。

```ts
type FighterLoadout = {
  playerSlot: number;
  characterId: string;
  weaponId: string;
  skinId: string;
  colorId: string;
};
```

## 6.4 FighterEntity

对局中的实际战斗实体。

```ts
type FighterEntity = {
  loadout: FighterLoadout;
  character: CharacterConfig;
  weapon: WeaponConfig;
  runtimeState: FighterRuntimeState;
};
```

## 6.5 装配伪代码

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

控制器注入：

```ts
movementController.applyCharacterConfig(character);
combatController.applyWeaponConfig(weapon);
dashController.applyDashConfig(DashDatabase.get(character.dashConfigId));
```

---

## 7. 统一攻击槽位

为了支持人物和武器自由搭配，所有武器都必须提供统一攻击槽位。

第一版建议槽位：

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

如果某把武器暂时没有某个动作，也要给占位动作或空动作，避免控制逻辑写特殊分支。

---

## 8. 状态机

第一版角色状态至少包含：

- `Idle`
- `Run`
- `Jump`
- `Fall`
- `Land`
- `DashStartup`
- `DashTravel`
- `DashRecovery`
- `Attack`
- `Hurt`
- `Knockback`
- `Dead`
- `Respawn`

推荐优先级：

`Dead` > `Knockback` > `Hurt` > `Attack` > `Dash` > `Jump/Fall` > `Run/Idle`

说明：

- 死亡最高
- 受击和击飞可以打断大部分动作
- 攻击可以覆盖移动
- 冲刺属于移动动作
- 普通移动优先级最低

---

## 9. 角色移动系统

第一版必须完成：

- 左右移动
- 加速
- 减速
- 面向切换
- 跳跃
- 多段跳
- 空中横向控制
- 快速下落
- 落地切换
- 冲刺
- 至少一种人物特殊移动能力，例如滑翔

推荐手感辅助：

- `Coyote Time`
- `Jump Buffer`
- `Variable Jump`
- `Fast Fall`

人物差异来自 `CharacterConfig`：

- 有的人 `jumpCount = 2`
- 有的人 `jumpCount = 3`
- 有的人 `canGlide = true`
- 有的人 `moveSpeed` 更快
- 有的人 `weight` 更重

---

## 10. 冲刺系统

冲刺属于人物模块。

第一版冲刺分 3 段：

1. `DashStartup`
2. `DashTravel`
3. `DashRecovery`

基础规则：

- 只先做地面冲刺
- 使用独立冲刺键
- 冲刺方向开始时锁定
- 冲刺期间可以在窗口内跳跃取消
- 冲刺期间可以在窗口内攻击取消
- 冲刺本体默认不全程无敌
- 冲刺攻击由武器模块提供

推荐默认参数：

| 参数 | 默认值 | 说明 |
| --- | --- | --- |
| `startupFrames` | `4` | 启动帧 |
| `travelFrames` | `10` | 位移帧 |
| `recoveryFrames` | `8` | 收招帧 |
| `dashSpeed` | `720` | 冲刺速度 |
| `inputBufferFrames` | `6` | 输入缓冲 |
| `airCarryRatioOnExit` | `0.70` | 离地保留水平速度比例 |

---

## 11. 武器攻击系统

第一版至少要支持：

- 近战攻击
- 远程投射物
- 地面轻攻击
- 地面重攻击
- 冲刺攻击
- 空中攻击
- 招式前摇
- 招式有效帧
- 招式后摇
- 攻击命中判定
- 攻击击飞参数

判定盒至少拆成：

- `Hitbox`：攻击判定
- `Hurtbox`：受击判定
- `Pushbox`：实体碰撞

建议所有招式数据都配置化，不要写死在角色脚本里。

---

## 12. 受击与击飞系统

第一版必须支持：

- 伤害累计
- 受击硬直
- 击退强度
- 击飞角度
- 高伤害击飞更远
- 出界判负
- 复活

基础公式可以先用：

```text
最终击飞 = 基础击飞 + 当前伤害系数 + 招式倍率 + 方向修正
```

第一版重点不是公式复杂，而是：

- 低伤时能继续打
- 高伤时真的危险
- 靠近边缘时有压迫感

---

## 13. 地图与相机

第一版地图：

- 1 个主平台
- 2 个副平台
- 左右出界区
- 上下出界区
- 2 个出生点
- 2 个复活点

平台系统需要：

- 地面碰撞
- 单向平台
- 出界检测
- 复活点

相机第一版目标：

- 同时框住两名玩家
- 玩家接近边缘时能看清局势
- 不需要复杂镜头演出

---

## 14. UI

第一版 UI 只做必要内容：

- 人物选择界面
- 武器选择界面
- 组合预览
- 对局生命数
- 伤害值
- 胜负提示
- 暂停菜单

组合预览需要显示：

- 当前人物
- 当前武器
- 跳跃次数
- 是否可滑翔
- 冲刺风格
- 攻击距离
- 攻击节奏

---

## 15. 调试工具

第一版必须尽早做调试显示。

必须显示：

- 当前状态
- 当前速度
- 当前伤害
- 剩余跳跃次数
- 是否正在滑翔
- 是否正在冲刺
- `Hitbox`
- `Hurtbox`
- `Pushbox`
- 输入历史

推荐功能：

- 一键重开
- 慢速播放
- 暂停逐帧
- 一键切换人物
- 一键切换武器

调试工具越早做，后面调手感越省时间。

---

## 16. 程序施工顺序

建议严格按下面顺序做。

1. 建项目基础工程
2. 建 `CharacterConfig`
3. 建 `WeaponConfig`
4. 建 `FighterLoadout`
5. 做人物选择和武器选择的临时界面
6. 做 `FighterAssembler`
7. 生成 `FighterEntity`
8. 做基础移动
9. 做跳跃和多段跳
10. 做冲刺
11. 做滑翔
12. 做平台碰撞
13. 做相机和出界判定
14. 做近战攻击
15. 做远程投射物
16. 做受击和击飞
17. 做死亡和复活
18. 做胜负规则
19. 做基础 UI
20. 做调试工具
21. 做第二个人物
22. 做第二把武器
23. 做自由搭配测试
24. 做音效和特效
25. 做手感和平衡调整

最短记忆版：

**先装配，再移动，再攻击，再受击击飞，再 UI 调试，最后调手感。**

---

## 17. 第一版验收标准

程序完成第一版时，需要满足下面条件。

## 17.1 装配验收

- 可以选择人物
- 可以选择武器
- 可以任意组合人物与武器
- `人物 A + 武器 A` 可进入对局
- `人物 A + 武器 B` 可进入对局
- `人物 B + 武器 A` 可进入对局
- `人物 B + 武器 B` 可进入对局
- 不同人物的移动参数不同
- 不同武器的攻击方式不同

## 17.2 移动验收

- 角色可以左右移动
- 角色可以跳跃
- 多段跳正常
- 冲刺正常
- 滑翔正常
- 落地后跳跃次数重置
- 冲刺可接跳跃
- 冲刺可接攻击

## 17.3 战斗验收

- 近战攻击能命中
- 远程投射物能命中
- 命中后能造成伤害
- 命中后能产生击飞
- 伤害越高击飞越明显
- 出界会死亡
- 死亡后能复活
- 生命归零后能判定胜负

## 17.4 调试验收

- 能看到角色状态
- 能看到速度
- 能看到伤害
- 能看到剩余跳跃次数
- 能看到判定盒
- 能看到输入历史

---

## 18. 第一版推荐测试组合

先做这 4 个组合：

| 组合 | 用途 |
| --- | --- |
| 人物 1 + 近战武器 | 验证标准战斗 |
| 人物 1 + 远程武器 | 验证同人物换武器 |
| 人物 2 + 近战武器 | 验证同武器换人物 |
| 人物 2 + 远程武器 | 验证完整自由搭配 |

人物建议：

- 人物 1：标准人物，2 段跳，无滑翔
- 人物 2：机动人物，3 段跳，可滑翔

武器建议：

- 武器 1：剑或拳套，近战
- 武器 2：弓或手炮，远程

---

## 19. 风险点

最容易出问题的地方：

- 人物和武器边界混乱
- 攻击写死在人物脚本里
- 移动能力写进武器脚本里
- 没有统一攻击槽位
- 没有调试判定盒
- 冲刺过强导致无脑切入
- 远程武器过强导致近战无法接近
- 滑翔过强导致回场无风险
- 多段跳太强导致守边失去意义

处理原则：

- 身体能力放人物
- 攻击能力放武器
- 跨模块能力用事件连接
- 平衡优先调参数
- 第一版少做特殊规则

---

## 20. 交付物清单

程序第一阶段交付时，至少应包含：

- 可运行项目
- 2 个人物配置
- 2 把武器配置
- 1 张测试地图
- 人物选择界面
- 武器选择界面
- 组合预览
- 本地双人对战
- 移动系统
- 冲刺系统
- 滑翔系统
- 攻击系统
- 投射物系统
- 受击击飞系统
- 复活与胜负系统
- 基础 UI
- 调试显示

---

## 21. 最终开发原则

这份项目第一阶段最重要的原则：

1. 先把人物和武器自由搭配跑通
2. 人物只管身体能力
3. 武器只管攻击方式
4. 所有关键数值都走配置
5. 先做 2 人物 + 2 武器 + 1 地图
6. 先验证手感，再扩内容

最终一句话：

**程序先搭“人物模块 + 武器模块 + 装配系统”，再做移动、攻击、受击和击飞；只要这条主链路跑通，后面扩角色和武器才会稳。**
