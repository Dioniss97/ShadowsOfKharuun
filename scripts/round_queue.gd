class_name KhRoundQueue
extends RefCounted

signal action_started(order: Dictionary)
signal action_impact(order: Dictionary)
signal action_finished(order: Dictionary)
const CAPACITY = 4
var pending: Array = []
var current: Dictionary = {}
var round_seconds = 2.6
var round_left = 0.0
var elapsed = 0.0
var impact_at = 0.42
var impact_done = false
var impact_times: Array = []
var next_impact = 0
var started_count = 0
var impact_count = 0
var finished_count = 0

func enqueue(order: Dictionary) -> bool:
	if pending.size() >= CAPACITY: return false
	pending.append(order.duplicate())
	return true

func cancel(index: int) -> bool:
	if index < 0 or index >= pending.size(): return false
	pending.remove_at(index)
	return true

func clear_pending() -> void:
	pending.clear()

func start(order: Dictionary) -> bool:
	if round_left > 0 or not current.is_empty(): return false
	current = order.duplicate()
	round_left = round_seconds
	elapsed = 0
	impact_done = false
	next_impact = 0
	impact_times = []
	for contact in order.get("impact_times",[impact_at]):
		impact_times.append(clampf(float(contact),0.0,round_seconds))
	impact_times.sort()
	impact_done = impact_times.is_empty()
	started_count += 1
	action_started.emit(current)
	return true

func advance(delta: float) -> void:
	if round_left <= 0: return
	delta = maxf(0.0,delta)
	elapsed += delta
	round_left = maxf(0,round_left-delta)
	# Several contacts can share one round; each keeps the original recipient.
	while not current.is_empty() and next_impact < impact_times.size() and elapsed >= impact_times[next_impact]:
		var contact_order = current.duplicate()
		contact_order["impact_index"] = next_impact
		next_impact += 1
		impact_done = next_impact >= impact_times.size()
		impact_count += 1
		action_impact.emit(contact_order)
	if round_left <= 0 and not current.is_empty():
		var finished = current
		current = {}
		finished_count += 1
		action_finished.emit(finished)

func interrupt() -> void:
	# Interruption cancels the hit, but preserves recovery until this round ends.
	current = {}
	impact_done = true
	next_impact = impact_times.size()

func reset() -> void:
	pending.clear()
	current = {}
	round_left = 0
	elapsed = 0
	impact_done = false
	impact_times.clear()
	next_impact = 0
