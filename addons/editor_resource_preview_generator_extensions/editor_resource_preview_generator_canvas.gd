@tool
class_name EditorResourcePreviewGeneratorCanvas
extends Object
## Helper for generating previews using canvas drawing methods.
##
## Provides an interface for using the familiar [CanvasItem] drawing methods
## to generate a [Texture2D].
## This class should not be used directly;
## an instance will be provided to
## [method EditorResourcePreviewGenerator2D._generate_2d].

const _DEFAULT_SIZE: int = 128

var _size: Vector2i
var _viewport: RID
var _canvas: RID
var _canvas_item: RID
var _viewport_texture: RID
var _thread: Thread


func _init(target_size: Vector2i = Vector2i(_DEFAULT_SIZE, _DEFAULT_SIZE)) -> void:
	_size = target_size
	_viewport = RenderingServer.viewport_create()
	RenderingServer.viewport_set_update_mode(_viewport, RenderingServer.VIEWPORT_UPDATE_DISABLED)
	RenderingServer.viewport_set_size(_viewport, _size.x, _size.y)
	RenderingServer.viewport_set_transparent_background(_viewport, true)
	RenderingServer.viewport_set_active(_viewport, true)
	_canvas = RenderingServer.canvas_create()
	RenderingServer.viewport_attach_canvas(_viewport, _canvas)
	_canvas_item = RenderingServer.canvas_item_create()
	RenderingServer.canvas_item_set_parent(_canvas_item, _canvas)
	_viewport_texture = RenderingServer.viewport_get_texture(_viewport)
	_thread = Thread.new()


func _draw() -> Texture2D:
	if OS.get_thread_caller_id() == OS.get_main_thread_id():
		var main_loop := Engine.get_main_loop()
		assert(main_loop is SceneTree)
		var root_vp := (main_loop as SceneTree).root.get_viewport_rid()
		RenderingServer.viewport_set_active(root_vp, false)
		RenderingServer.viewport_set_update_mode(_viewport, RenderingServer.VIEWPORT_UPDATE_ONCE)
		RenderingServer.force_draw(false)
		RenderingServer.viewport_set_active(root_vp, true)
	else:
		var semaphore := Semaphore.new()
		var frame_pre_draw_callback = func():
			RenderingServer.viewport_set_update_mode(_viewport, RenderingServer.VIEWPORT_UPDATE_ONCE)
		var request_frame_drawn_callback = func():
			semaphore.post()
		RenderingServer.frame_pre_draw.connect(frame_pre_draw_callback, ConnectFlags.CONNECT_ONE_SHOT)
		RenderingServer.request_frame_drawn_callback(request_frame_drawn_callback)
		semaphore.wait()
	var image := RenderingServer.texture_2d_get(_viewport_texture)
	RenderingServer.canvas_item_clear(_canvas_item)
	image.convert(Image.FORMAT_RGBA8)
	assert(_size == image.get_size(), "EditorResourcePreviewGeneratorCanvas size differs from image size")
	return ImageTexture.create_from_image(image)


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		RenderingServer.free_rid(_viewport_texture)
		RenderingServer.free_rid(_canvas_item)
		RenderingServer.free_rid(_canvas)
		RenderingServer.free_rid(_viewport)


## Get the size of the canvas on which drawing occurs.
## Drawing calls that operate outside of the canvas will not be visible.
func get_size() -> Vector2i:
	return _size


## See [method CanvasItem.draw_animation_slice].
func draw_animation_slice(animation_length: float, slice_begin: float, slice_end: float, offset: float = 0.0) -> void:
	RenderingServer.canvas_item_add_animation_slice(_canvas_item, animation_length, slice_begin, slice_end, offset)


# Missing: `draw_arc`


## See [method CanvasItem.draw_char].
func draw_char(font: Font, pos: Vector2, char: String, font_size: int = 16, modulate: Color = Color(1, 1, 1, 1), oversampling: float = 0.0) -> void:
	if font and not char.is_empty():
		font.draw_char(_canvas_item, pos, char.unicode_at(0), font_size, modulate, oversampling)


## See [method CanvasItem.draw_char_outline].
func draw_char_outline(font: Font, pos: Vector2, char: String, font_size: int = 16, size: int = -1, modulate: Color = Color(1, 1, 1, 1), oversampling: float = 0.0) -> void:
	if font and not char.is_empty():
		font.draw_char_outline(_canvas_item, pos, char.unicode_at(0), font_size, size, modulate, oversampling)


## See [method CanvasItem.draw_circle], except the circle will be filled.
func draw_circle(position: Vector2, radius: float, color: Color, antialiased: bool = false) -> void:
	# NOTE: no support for filled/width
	RenderingServer.canvas_item_add_circle(_canvas_item, position, radius, color, antialiased)


# Missing: `draw_colored_polygon`


# Missing: `draw_dashed_line`


# Missing: `draw_end_animation`


## See [method CanvasItem.draw_lcd_texture_rect_region].
func draw_lcd_texture_rect_region(texture: Texture2D, rect: Rect2, src_rect: Rect2, modulate: Color = Color(1, 1, 1, 1)) -> void:
	RenderingServer.canvas_item_add_lcd_texture_rect_region(_canvas_item, rect, texture.get_rid(), src_rect, modulate)


## See [method CanvasItem.draw_line].
func draw_line(from: Vector2, to: Vector2, color: Color, width: float = -1.0, antialiased: bool = false) -> void:
	RenderingServer.canvas_item_add_line(_canvas_item, from, to, color, width, antialiased)


## See [method CanvasItem.draw_mesh].
func draw_mesh(mesh: Mesh, texture: Texture2D, transform: Transform2D = Transform2D(Vector2(1, 0), Vector2(0, 1), Vector2(0, 0)), modulate: Color = Color(1, 1, 1, 1)) -> void:
	RenderingServer.canvas_item_add_mesh(_canvas_item, mesh.get_rid(), transform, modulate, texture.get_rid())


## See [method CanvasItem.draw_msdf_texture_rect_region].
func draw_msdf_texture_rect_region(texture: Texture2D, rect: Rect2, src_rect: Rect2, modulate: Color = Color(1, 1, 1, 1), outline: float = 0.0, pixel_range: float = 4.0, scale: float = 1.0) -> void:
	RenderingServer.canvas_item_add_msdf_texture_rect_region(_canvas_item, rect, texture.get_rid(), src_rect, modulate, roundi(outline), pixel_range, scale)


## See [method CanvasItem.draw_multiline].
func draw_multiline(points: PackedVector2Array, color: Color, width: float = -1.0, antialiased: bool = false) -> void:
	var colors := PackedColorArray()
	colors.resize(roundi(points.size() / 2))
	for i in roundi(points.size() / 2):
		colors[i] = color
	RenderingServer.canvas_item_add_multiline(_canvas_item, points, colors, width, antialiased)


## See [method CanvasItem.draw_multiline_colors].
func draw_multiline_colors(points: PackedVector2Array, colors: PackedColorArray, width: float = -1.0, antialiased: bool = false) -> void:
	RenderingServer.canvas_item_add_multiline(_canvas_item, points, colors, width, antialiased)


## See [method CanvasItem.draw_multiline_string].
func draw_multiline_string(font: Font, pos: Vector2, text: String, alignment: HorizontalAlignment = 0, width: float = -1, font_size: int = 16, max_lines: int = -1, modulate: Color = Color(1, 1, 1, 1), brk_flags: TextServer.LineBreakFlag = 3, justification_flags: TextServer.JustificationFlag = 3, direction: TextServer.Direction = 0, orientation: TextServer.Orientation = 0, oversampling: float = 0.0) -> void:
	# NOTE: BitField annotation for `justification_flags` and `brk_flags` isn't available in GDScript
	if font:
		font.draw_multiline_string(_canvas_item, pos, text, alignment, width, font_size, max_lines, modulate, brk_flags, justification_flags, direction, orientation, oversampling)


## See [method CanvasItem.draw_multiline_string_outline].
func draw_multiline_string_outline(font: Font, pos: Vector2, text: String, alignment: HorizontalAlignment = 0, width: float = -1, font_size: int = 16, max_lines: int = -1, size: int = 1, modulate: Color = Color(1, 1, 1, 1), brk_flags: TextServer.LineBreakFlag = 3, justification_flags: TextServer.JustificationFlag = 3, direction: TextServer.Direction = 0, orientation: TextServer.Orientation = 0, oversampling: float = 0.0) -> void:
	# NOTE: BitField annotation for `justification_flags` and `brk_flags` isn't available in GDScript
	if font:
		font.draw_multiline_string_outline(_canvas_item, pos, text, alignment, width, font_size, max_lines, size, modulate, brk_flags, justification_flags, direction, orientation, oversampling)


## See [method CanvasItem.draw_multimesh].
func draw_multimesh(multimesh: MultiMesh, texture: Texture2D) -> void:
	RenderingServer.canvas_item_add_multimesh(_canvas_item, multimesh.get_rid(), texture.get_rid())


# Missing: `draw_polygon`


## See [method CanvasItem.draw_polyline].
func draw_polyline(points: PackedVector2Array, color: Color, width: float = -1.0, antialiased: bool = false) -> void:
	var colors := PackedColorArray()
	colors.resize(points.size())
	for i in points.size():
		colors[i] = color
	RenderingServer.canvas_item_add_polyline(_canvas_item, points, colors, width, antialiased)


## See [method CanvasItem.draw_polyline_colors].
func draw_polyline_colors(points: PackedVector2Array, colors: PackedColorArray, width: float = -1.0, antialiased: bool = false) -> void:
	RenderingServer.canvas_item_add_polyline(_canvas_item, points, colors, width, antialiased)


## See [method CanvasItem.draw_primitive].
func draw_primitive(points: PackedVector2Array, colors: PackedColorArray, uvs: PackedVector2Array, texture: Texture2D = null) -> void:
	var texture_rid := RID()
	if texture:
		texture_rid = texture.get_rid()
	RenderingServer.canvas_item_add_primitive(_canvas_item, points, colors, uvs, texture_rid)


## See [method CanvasItem.draw_rect], except the rect will be filled.
func draw_rect(rect: Rect2, color: Color, antialiased: bool = false) -> void:
	# NOTE: no support for filled/width
	RenderingServer.canvas_item_add_rect(_canvas_item, rect, color, antialiased)


# Missing: `draw_set_transform`


## See [method CanvasItem.draw_set_transform_matrix].
func draw_set_transform_matrix(xform: Transform2D) -> void:
	RenderingServer.canvas_item_add_set_transform(_canvas_item, xform)


## See [method CanvasItem.draw_string].
func draw_string(font: Font, pos: Vector2, text: String, alignment: HorizontalAlignment = 0, width: float = -1, font_size: int = 16, modulate: Color = Color(1, 1, 1, 1), justification_flags: TextServer.JustificationFlag = 3, direction: TextServer.Direction = 0, orientation: TextServer.Orientation = 0, oversampling: float = 0.0) -> void:
	# NOTE: BitField annotation for `justification_flags` isn't available in GDScript
	if font:
		font.draw_string(_canvas_item, pos, text, alignment, width, font_size, modulate, justification_flags, direction, orientation, oversampling)


## See [method CanvasItem.draw_string_outline].
func draw_string_outline(font: Font, pos: Vector2, text: String, alignment: HorizontalAlignment = 0, width: float = -1, font_size: int = 16, size: int = 1, modulate: Color = Color(1, 1, 1, 1), justification_flags: TextServer.JustificationFlag = 3, direction: TextServer.Direction = 0, orientation: TextServer.Orientation = 0, oversampling: float = 0.0) -> void:
	# NOTE: BitField annotation for `justification_flags` isn't available in GDScript
	if font:
		font.draw_string_outline(_canvas_item, pos, text, alignment, width, font_size, size, modulate, justification_flags, direction, orientation, oversampling)


## See [method CanvasItem.draw_style_box].
func draw_style_box(style_box: StyleBox, rect: Rect2) -> void:
	if style_box:
		style_box.draw(_canvas_item, rect)


# Missing: `draw_texture`


## See [method CanvasItem.draw_texture_rect].
func draw_texture_rect(texture: Texture2D, rect: Rect2, tile: bool, modulate: Color = Color(1, 1, 1, 1), transpose: bool = false) -> void:
	RenderingServer.canvas_item_add_texture_rect(_canvas_item, rect, texture.get_rid(), tile, modulate, transpose)


## See [method CanvasItem.draw_texture_rect_region].
func draw_texture_rect_region(texture: Texture2D, rect: Rect2, src_rect: Rect2, modulate: Color = Color(1, 1, 1, 1), transpose: bool = false, clip_uv: bool = true) -> void:
	RenderingServer.canvas_item_add_texture_rect_region(_canvas_item, rect, texture.get_rid(), src_rect, modulate, transpose, clip_uv)
