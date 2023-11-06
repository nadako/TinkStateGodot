## Auto-observable tracking module

const _Auto = preload("./auto.gd")

static var _current: _Auto

static func _track(observable):
	if _current != null && observable._can_fire():
		return _current._subscribe_to(observable)
	else:
		return observable._get_current_value()

static func _compute_for(observable: _Auto, compute: Callable):
	var prev := _current
	_current = observable
	var result = compute.call()
	_current = prev
	return result
