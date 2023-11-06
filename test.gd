extends Control

func _ready():
	var counter := Observable.state(42)
	#var binding := counter.bind(func(value): $Label.text = str(value))

	var template := Observable.state("Value is %s")
	template.bind(func(value): if $TextEdit.text != value: $TextEdit.text = value)
	$TextEdit.text_changed.connect(func(): template.value = $TextEdit.text)
	var derived := Observable.auto(func(): return template.value % counter.value)
	var binding := derived.bind(func(value): $Label.text = value)

	$Button.pressed.connect(func(): counter.value += 1)
	$UnbindButton.pressed.connect(binding.cancel)
