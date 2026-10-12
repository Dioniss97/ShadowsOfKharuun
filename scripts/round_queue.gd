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
	started_count += 1
	action_started.emit(current)
	return true

func advance(delta: float) -> void:
	if round_left <= 0: return
	elapsed += delta
	round_left = maxf(0,round_left-delta)
	if not current.is_empty() and not impact_done and elapsed >= impact_at:
		impact_done = true
		impact_count += 1
		action_impact.emit(current)
	if round_left <= 0 and not current.is_empty():
		var finished = current
		current = {}
		finished_count += 1
		action_finished.emit(finished)

func interrupt() -> void:
	# Interruption cancels the hit, but preserves recovery until this round ends.
	current = {}
	impact_done = true

func reset() -> void:
	pending.clear()
	current = {}
	round_left = 0
	elapsed = 0
	impact_done = false
