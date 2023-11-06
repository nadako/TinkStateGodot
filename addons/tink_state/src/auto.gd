extends _Dispatcher

const _Dispatcher = preload("./dispatcher.gd")
const _AutoTrack = preload("./auto_track.gd")
const _Binding = preload("./binding.gd")

enum Status { Fresh, Dirty, Computing, Computed }

var value:
	get:
		return _AutoTrack._track(self)

var _compute: Callable
var _status: Status
var _last_value
var _deps: Dictionary
var _sub_head: _Sub
var _sub_tail: _Sub
var _subscribed: bool

func _init(compute: Callable):
	super()
	_compute = compute
	_status = Status.Fresh

func bind(callback: Callable) -> _Binding:
	return _Binding.new(self, callback)

func _get_current_value():
	return _calc_current_value(false)

func _get_revision() -> int:
	if _subscribed:
		return _revision

	if _status == Status.Fresh:
		_calc_current_value(true)

	var sub := _sub_head
	while sub != null:
		if sub.source._get_revision() > _revision:
			_revision = _Revision.next()
			break
		sub = sub.next

	return _revision

func _calc_current_value(force: bool):
	const max_iterations := 100
	var count := 0
	while force || !_is_valid():
		force = false
		count += 1

		if count > max_iterations: assert(false, "No result after %s attemps" % max_iterations)

		if _status == Status.Fresh:
			_do_compute()
		else:
			var valid := true
			var sub := _sub_head
			while sub != null:
				if sub.has_changed():
					valid = false
					break
				sub = sub.next
			if valid:
				_status = Status.Computed
			else:
				_do_compute()

	return _last_value

func _do_compute():
	_status = Status.Computing

	var sub := _sub_head
	while sub != null:
		sub.used = false
		sub = sub.next

	_last_value = _AutoTrack._compute_for(self, _compute)

	if _status == Status.Computing:
		_status = Status.Computed

	sub = _sub_head
	while sub != null:
		if !sub.used:
			var source = sub.source
			_deps.erase(source)
			if _subscribed: source._unsubscribe(self)
			if sub == _sub_head: _sub_head = sub.next
			if sub == _sub_tail: _sub_tail = sub.prev
			if sub.prev != null: sub.prev.next = sub.next
			if sub.next != null: sub.next.prev = sub.prev
			var next = sub.next
			sub.next = null
			sub.prev = null
			sub = next
		else:
			sub = sub.next

	if _sub_head == null:
		_dispose()

func _is_valid() -> bool:
	return _status == Status.Computed && (_subscribed || _subs_valid())

func _subs_valid() -> bool:
	var sub := _sub_head
	while sub != null:
		if !sub.is_valid(): return false
		sub = sub.next
	return true

func _subscribe_to(source):
	var sub: _Sub = _deps.get(source)
	if sub == null:
		sub = _Sub.new(source)
		if _subscribed: source._subscribe(self)
		_deps[source] = sub
		if _sub_head == null:
			_sub_head = sub
			_sub_tail = sub
		else:
			_sub_tail.next = sub
			sub.prev = _sub_tail
			_sub_tail = sub
		return sub.last_value
	else:
		if !sub.used:
			sub.reuse()
			return sub.last_value
		else:
			# TODO: also return sub.last_value?
			return source._get_current_value()

func _on_subscribed_changed(subscribed: bool):
	_subscribed = subscribed
	if subscribed:
		var sub := _sub_head
		while sub != null:
			sub.source._subscribe(self)
			sub = sub.next
		_calc_current_value(true)
		_get_revision()
	else:
		var sub := _sub_head
		while sub != null:
			sub.source._unsubscribe(self)
			sub = sub.next

func _notify():
	match _status:
		Status.Computed:
			_status = Status.Dirty
			_fire()
		Status.Computing:
			_status = Status.Dirty

class _Sub:
	var prev: _Sub
	var next: _Sub
	var used: bool
	var source
	var last_value
	var last_revision: int

	func _init(src):
		source = src
		last_revision = src._get_revision()
		last_value = src._get_current_value()
		used = true

	func is_valid() -> bool:
		return source._get_revision() == last_revision

	func has_changed() -> bool:
		var next_revision: int = source._get_revision()
		if next_revision == last_revision: return false
		last_revision = next_revision
		var prev_value = last_value
		last_value = source._get_current_value()
		return prev_value != last_value

	func reuse():
		used = true
		last_value = source._get_current_value()
		last_revision = source._get_revision()
