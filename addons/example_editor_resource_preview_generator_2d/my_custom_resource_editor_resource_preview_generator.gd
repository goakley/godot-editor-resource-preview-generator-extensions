@tool
class_name MyCustomResourceEditorResourcePreviewGenerator
extends EditorResourcePreviewGenerator2D
## Generates a preview for a `MyCustomResource`,
## which is just a circle using the color from the resource.


func _handles(type: String) -> bool:
	# GDScript resource subclasses are still of the `Resource` type
	return type == "Resource"


func _generate_2d(resource: Resource, canvas: EditorResourcePreviewGeneratorCanvas, metadata: Dictionary) -> bool:
	if resource is not MyCustomResource:
		return false
	var color := (resource as MyCustomResource).color
	canvas.draw_circle(canvas.get_size() / 2.0, canvas.get_size().x / 2.0, color, false)
	print("PREVIEWING")
	return true
