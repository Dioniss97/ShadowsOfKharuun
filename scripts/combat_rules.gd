class_name KhCombatRules
extends RefCounted

static func hit_result(roll: int, attack_bonus: int, defence: int) -> Dictionary:
	var critical = roll == 20
	var hit = roll != 1 and (critical or roll+attack_bonus >= defence)
	return {"hit":hit,"critical":critical,"roll":roll,"total":roll+attack_bonus,"defence":defence}

static func scaled_damage(base: float, result: Dictionary) -> float:
	if not result.hit: return 0.0
	return base*(1.5 if result.critical else 1.0)
