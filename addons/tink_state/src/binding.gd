enum Status { Valid, Invalid, Disposed }

var _observable
var _callback: Callable
var _status: Status
var _last_value

func _init(observable, callback: Callable):
	_observable = observable
	_callback = callback
	_status = Status.Valid
	
	observable._subscribe(self)
	
	_last_value = observable._get_current_value()
	callback.call(_last_value)

func _notify():
	if !_check_valid(): return
	
	if _status == Status.Valid:
		_status = Status.Invalid
		ObservableScheduler.schedule(self)

func _run():
	if _status != Status.Invalid: return
	if !_check_valid(): return

	_status = Status.Valid

	var can_fire: bool = _observable._can_fire()

	var last_value = _last_value
	var new_value = _observable._get_current_value()
	_last_value = new_value

	if new_value != last_value:
		_callback.call(new_value)

	if !can_fire:
		cancel()

func cancel():
	if _status == Status.Disposed: return
	_status = Status.Disposed
	_observable._unsubscribe(self)
	_observable = null
	_callback = Callable()
	
func _check_valid() -> bool:
	# TODO: can we track exact moment when callback becomes invalid?
	if !_callback.is_valid():
		cancel()
		return false
	return true
	
