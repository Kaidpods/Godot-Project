extends Node2D

@export var sprite_sheet: Texture2D
@export var columns: int = 8
@export var rows: int = 8
@export var save_path: String = "res://occluders/"  # Make sure this folder exists

var frame_width: int
var frame_height: int

func _ready() -> void:
	slice_and_generate_polygons()

func slice_and_generate_polygons() -> void:
	var image: Image = sprite_sheet.get_image()
	frame_width = image.get_width() / columns
	frame_height = image.get_height() / rows

	var idx: int = 0
	for row in range(rows):
		for col in range(columns):
			var region_rect := Rect2(col * frame_width, row * frame_height, frame_width, frame_height)
			var frame_img := image.get_region(region_rect)

			var poly := generate_occluder_polygon(frame_img)

			if poly.polygon.size() >= 3:
				var occluder := LightOccluder2D.new()
				occluder.name = "occluder_%02d" % idx
				occluder.occluder = poly
				occluder.visible = true
				occluder.position = Vector2(col * frame_width, row * frame_height)
				add_child(occluder)

				# Save polygon resource
				var file_path := "%soccluder_%02d.tres" % [save_path, idx]
				var err := ResourceSaver.save(poly, file_path)
				if err != OK:
					push_error("Failed to save polygon: %s" % file_path)

			idx += 1

func generate_occluder_polygon(image: Image) -> OccluderPolygon2D:
	var polygon := OccluderPolygon2D.new()
	var points := PackedVector2Array()
	var alpha_threshold := 0.1

	# Collect all opaque pixels
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			if image.get_pixel(x, y).a > alpha_threshold:
				points.append(Vector2(x, y))

	if points.size() >= 3:
		var hull := Geometry2D.convex_hull(points)
		polygon.polygon = shrink_polygon(hull, 0.95)
	else:
		polygon.polygon = []

	return polygon

func shrink_polygon(points: PackedVector2Array, factor: float) -> PackedVector2Array:
	var center := Vector2.ZERO
	for p in points:
		center += p
	center /= points.size()

	var shrunk := PackedVector2Array()
	for p in points:
		shrunk.append(center + (p - center) * factor)

	return shrunk
