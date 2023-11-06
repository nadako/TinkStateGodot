# tink_state - Reactive State Handling for Godot

Uncomplicated library for dealing with mutable state in a nice reactive way.

Features:

 - Lightweight and generic observable state primitives
 - Efficient binding mechanism with support for per-frame batching
 - Derived observables with caching and automatic update propagation

## Setup

1. Copy `addons/tink_state` into your project.
2. Enable the `tink_state` plugin.
3. Enjoy!

## Usage

```gdscript
# create state
var counter := Observable.state(42)

# read and write value
counter.value += 1
print(counter.value) # 43

# bind to changes
var binding := counter.bind(func(value): $Label.text = str(value))

# unbind
binding.cancel()

# create derived observable
var doubled := Observable.auto(func(): return counter.value * 2)

# observe or bind to derived
doubled.bind(func(value): $Label.text = str(value))

print(doubled.value) # 86
counter.value = 10
print(doubled.value) # 20
```
