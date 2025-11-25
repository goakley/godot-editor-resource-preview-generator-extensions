@tool
extends EditorPlugin

const MyCustomResourceEditorResourcePreviewGenerator := preload("res://addons/example_editor_resource_preview_generator_2d/my_custom_resource_editor_resource_preview_generator.gd")

var _my_custom_resource_editor_resource_preview_generator: EditorResourcePreviewGenerator


func _enable_plugin() -> void:
	pass


func _disable_plugin() -> void:
	pass


func _enter_tree() -> void:
	_my_custom_resource_editor_resource_preview_generator = MyCustomResourceEditorResourcePreviewGenerator.new()
	EditorInterface.get_resource_previewer().add_preview_generator(_my_custom_resource_editor_resource_preview_generator)


func _exit_tree() -> void:
	EditorInterface.get_resource_previewer().remove_preview_generator(_my_custom_resource_editor_resource_preview_generator)
