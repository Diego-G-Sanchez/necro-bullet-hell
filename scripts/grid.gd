extends Node2D

# Plain reference grid so movement is readable before there's a real level.

@export var cell := 64.0
@export var extent := 4000.0
@export var line_color := Color(1, 1, 1, 0.05)
@export var axis_color := Color(1, 1, 1, 0.12)


func _draw() -> void:
	var steps := int(extent / cell)
	for i in range(-steps, steps + 1):
		var p := i * cell
		var color := axis_color if i == 0 else line_color
		draw_line(Vector2(p, -extent), Vector2(p, extent), color, 1.0)
		draw_line(Vector2(-extent, p), Vector2(extent, p), color, 1.0)
