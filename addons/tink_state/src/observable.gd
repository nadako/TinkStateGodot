class_name Observable
## Reactive observable state primitives
##
## Use static constructor methods to create instances of observable data.
## [br]
## Every observable object has a [code]value[/code] getter
## and a [code]bind(callback)[/code] method to create and return a binding
## which can be later undone by calling its [code]cancel[/code] method.

const _State = preload("./state.gd")
const _Auto = preload("./auto.gd")

## Create an instance of mutable observable state
static func state(initial_value) -> _State:
	return _State.new(initial_value)

## Create an instance of automatic derived observable state
static func auto(compute: Callable) -> _Auto:
	return _Auto.new(compute)
