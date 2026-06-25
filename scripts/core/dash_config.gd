extends RefCounted
class_name DashConfig

const DEFAULTS := {
	"enabled": true,
	"useDedicatedButton": true,
	"allowDoubleTap": false,
	"inputBufferFrames": 6,
	"doubleTapMaxGapFrames": 8,
	"reDashLockoutFrames": 6,
	"allowAirDash": true,
	"maxAirDashes": 1,
	"startupFrames": 4,
	"travelFrames": 10,
	"recoveryFrames": 8,
	"dashSpeed": 800.0,
	"dashAcceleration": 5600.0,
	"dashBrake": 6200.0,
	"airDashSpeedMultiplier": 1.10,
	"airDashGravityScale": 0.12,
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
	"hurtboxScaleX": 1.0,
	"hurtboxScaleY": 1.0,
	"runOffLedge": true,
	"stopAtLedge": false,
	"landingRecoveryFrames": 4,
	"enableTrailVfx": true,
	"dashStartSfxId": "dash_start_default",
	"dashLoopSfxId": "",
	"dashEndSfxId": "dash_end_default",
	"uniqueTraitId": "none",
}

static func build(overrides: Dictionary = {}) -> Dictionary:
	var config: Dictionary = DEFAULTS.duplicate(true)
	for key in overrides.keys():
		config[key] = overrides[key]
	return config
