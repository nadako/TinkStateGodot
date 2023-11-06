@tool
extends EditorPlugin

func _enter_tree() -> void:
	add_autoload_singleton("ObservableScheduler", "src/observable_scheduler.gd")

func _exit_tree() -> void:
	remove_autoload_singleton("ObservableScheduler")
