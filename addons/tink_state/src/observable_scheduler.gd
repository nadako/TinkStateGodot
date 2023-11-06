extends Node
## Binding scheduler singleton, must be added to the project's autoload list.
## Used internally by the binding mechanism

const PROCESS_MAX_MSECS: int = 100

var _scheduled: bool
var _queue: Array

func _process(_delta):
	if !_scheduled: return

	var end = Time.get_ticks_msec() + PROCESS_MAX_MSECS
	while true:
		var queue := _queue
		_queue = []
		for schedulable in queue:
			schedulable._run()
		if _queue.is_empty() || Time.get_ticks_msec() > end:
			break

	if _queue.is_empty():
		_scheduled = false

func schedule(schedulable):
	_queue.append(schedulable)
	_scheduled = true
