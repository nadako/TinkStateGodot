const _Revision = preload("./revision.gd")

var _revision: int
var _observers: Array
var _firing: bool
var _modification: _Modification
var _disposed: bool

func _init():
	_revision = _Revision.next()

func _subscribe(observer):
	if _firing:
		if _modification == null: _modification = _Modification.new()
		_modification.added.append(observer)
	else:
		var was_empty = _observers.is_empty()
		if _add_observer(observer) && was_empty:
			_on_subscribed_changed(true)

func _unsubscribe(observer):
	if _firing:
		if _modification == null: _modification = _Modification.new()
		_modification.removed.append(observer)
	else:
		var was_empty = _observers.is_empty()
		if !was_empty && _remove_observer(observer):
			if _observers.is_empty(): _on_subscribed_changed(false)

func _add_observer(observer) -> bool:
	if observer in _observers: return false
	_observers.append(observer)
	return true

func _remove_observer(observer) -> bool:
	var index = _observers.find(observer)
	if index == -1: return false
	_observers.remove_at(index)
	return true

func _on_subscribed_changed(_subscribed: bool):
	pass

func _fire():
	_revision = _Revision.next()
	if _observers.is_empty(): return

	_firing = true
	for observer in _observers:
		observer._notify()
	_firing = false

	if _modification != null:
		for observer in _modification.added:
			_add_observer(observer)
		for observer in _modification.removed:
			_remove_observer(observer)
		_modification = null
		if _observers.is_empty(): _on_subscribed_changed(false)

func _can_fire() -> bool:
	return !_disposed

func _dispose():
	_disposed = true
	_observers.clear()
	_modification = null

class _Modification:
	var added: Array
	var removed: Array
