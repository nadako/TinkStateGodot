extends _Dispatcher
## Mutable observable state. Create with [member Observable.state].

const _Dispatcher = preload("./dispatcher.gd")
const _Binding = preload("./binding.gd")
const _AutoTrack = preload("./auto_track.gd")

## Current value of this observable state.
## Setting a different value will trigger bindings and auto-observable updates.
var value:
	get:
		return _AutoTrack._track(self)
	set(new_value):
		if new_value != _value:
			_value = new_value
			_fire()

var _value

func _init(initial_value):
	super()
	_value = initial_value

## Subscribe to value changes and attach given [code]callback[/code] to be
## invoked when the value is updated.
func bind(callback: Callable) -> _Binding:
	return _Binding.new(self, callback)

func _get_current_value():
	return _value

func _get_revision() -> int:
	return _revision
