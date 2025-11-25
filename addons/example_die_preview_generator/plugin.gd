@tool
extends EditorPlugin

const DieResourcePreviewGenerator := preload("res://addons/example_die_preview_generator/die_resource_preview_generator.gd")

var _die_resource_preview_generator: EditorResourcePreviewGenerator


func _enable_plugin() -> void:
	pass


func _disable_plugin() -> void:
	pass


func _enter_tree() -> void:
	_die_resource_preview_generator = DieResourcePreviewGenerator.new()
	EditorInterface.get_resource_previewer().add_preview_generator(_die_resource_preview_generator)


func _exit_tree() -> void:
	EditorInterface.get_resource_previewer().remove_preview_generator(_die_resource_preview_generator)
