# EditorResourcePreviewGenerator Extensions

A Godot 4 plugin that extends the functionality of [`EditorResourcePreviewGenerator`](https://docs.godotengine.org/en/stable/classes/class_editorresourcepreviewgenerator.html) to simplify preview generation.
Fully compatible with Godot's existing [`EditorResourcePreview`](https://docs.godotengine.org/en/stable/classes/class_editorresourcepreview.html) functionality.

## Features

The `EditorResourcePreviewGenerator2D` class allows for generating previews using [`CanvasItem`-style drawing calls](https://docs.godotengine.org/en/stable/tutorials/2d/custom_drawing_in_2d.html).
It is an `EditorResourcePreviewGenerator`, but its `_generate_2d()` method replaces the parent class's `_generate()` method and passes in an object that allows for calling drawing methods (`draw_circle`, `draw_polyline`, etc).

## Examples

Basic usage can be found in the built-in documentation for the plugin's classes.
Full runnable examples can be found in the `addons/` directory (named `example_*`).
Open this repository in the Godot editor to play with the full examples.

<img src="screenshots/dice.png"></img>
