## Global revision counter used internally by observables

static var _next: int = 0

static func next() -> int:
	var revision = _next
	_next += 1
	return revision
