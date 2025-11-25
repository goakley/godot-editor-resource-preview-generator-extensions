@tool
class_name DieResourcePreviewGenerator
extends EditorResourcePreviewGenerator2D
## Generates a preview for a `MyCustomResource`,
## which is just a circle using the color from the resource.


func _handles(type: String) -> bool:
	# GDScript resource subclasses are still of the `Resource` type
	return type == "Resource"


func _generate_2d(resource: Resource, canvas: EditorResourcePreviewGeneratorCanvas, metadata: Dictionary) -> bool:
	if resource is not DieResource:
		return false
	# determine which pips need to be drawn based on the resource value
	var pips := clampi((resource as DieResource).pips, 1, 6)
	var positions: Array[Vector2] = []
	if pips >= 2:
		positions.append(Vector2(0.25, 0.25)) # top left
		positions.append(Vector2(0.75, 0.75)) # bottom right
	if pips >= 4:
		positions.append(Vector2(0.25, 0.75)) # top right
		positions.append(Vector2(0.75, 0.25)) # bottom left
	if pips == 6:
		positions.append(Vector2(0.25, 0.5)) # middle left
		positions.append(Vector2(0.75, 0.5)) # middle right
	if pips % 2 == 1:
		positions.append(Vector2(0.5, 0.5)) # middle
	# draw each pip in its correct location
	var size := Vector2(canvas.get_size())
	var pip_size := size.x * 0.075
	var color := EditorInterface.get_editor_theme().get_color("accent_color", "Editor")
	for position in positions:
		canvas.draw_circle(size * position, pip_size, color, true)
	return true
