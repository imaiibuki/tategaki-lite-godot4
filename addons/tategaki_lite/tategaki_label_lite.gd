## TategakiLabelLite
##
## Free Lite version of TategakiLabel (see the full "Tategaki" addon:
## https://ibuking289.itch.io/tategaki-godot4). A Control that renders
## Japanese text in tategaki (vertical) layout: right-to-left columns,
## top-to-bottom characters, explicit `\n` for a hard column break, correct
## vertical glyph forms for punctuation/brackets/small kana via the font's
## OpenType `vert`/`vrt2` feature (via TextServer -- same mechanism as the
## full version, see its design-rationale comment), and automatic column
## wrapping. Basic properties: `font`, `font_size`, `char_spacing` (gap
## between characters within a column), `line_spacing` (gap between
## columns), `font_color`.
##
## Not in Lite (see the full version): line-head/line-end kinsoku rules,
## rotation of half-width Latin/digits, `[tcy]..[/tcy]` tate-chu-yoko, ruby
## (furigana)/emphasis dots, and the `visible_characters`/`visible_ratio`
## typewriter reveal / `get_overflow()` pagination. Text using any of those
## notations (e.g. "[tcy]12[/tcy]", "｜漢字《よみ》") is drawn as literal
## characters -- Lite never parses that markup, so it is never dropped and
## never an error.
@tool
class_name TategakiLabelLite
extends Control

const LayoutLite = preload("res://addons/tategaki_lite/layout.gd")

@export_multiline var text: String = "":
	set(value):
		text = value
		_mark_dirty()

@export var font: Font = null:
	set(value):
		font = value
		_mark_dirty()

@export_range(4, 256, 1, "suffix:px") var font_size: int = 32:
	set(value):
		font_size = value
		_mark_dirty()

@export var font_color: Color = Color(0.1, 0.1, 0.1):
	set(value):
		font_color = value
		queue_redraw()

## Gap, in pixels, between columns (adds to font_size to get the column
## pitch). This is the vertical-text equivalent of a horizontal label's
## "line spacing" -- columns are this addon's "lines".
@export_range(-32, 128, 0.5, "suffix:px") var line_spacing: float = 8.0:
	set(value):
		line_spacing = value
		_mark_dirty()

## Gap, in pixels, between characters within the same column.
@export_range(-32, 128, 0.5, "suffix:px") var char_spacing: float = 0.0:
	set(value):
		char_spacing = value
		_mark_dirty()

## Fixed number of characters per column. 0 = auto: wrap by the Control's
## height instead.
@export_range(0, 200, 1) var max_chars_per_column: int = 0:
	set(value):
		max_chars_per_column = value
		_mark_dirty()

## How the block of columns is anchored horizontally within `size` when the
## text doesn't use the full width. Vertical Japanese text conventionally
## starts at the top right, so the default is RIGHT.
@export var column_alignment: HorizontalAlignment = HORIZONTAL_ALIGNMENT_RIGHT:
	set(value):
		column_alignment = value
		queue_redraw()

## Inset, in pixels, applied to all four sides before laying out columns/
## rows. -1 (default) means "0.5 * font_size".
@export_range(-1, 128, 0.5, "suffix:px") var padding: float = -1.0:
	set(value):
		padding = value
		_mark_dirty()

var _dirty: bool = true
var _layout: Dictionary = {}
var _shaped_cells: Array = []  # parallel to _layout["cells"]; {"cell":.., "tl":..}
var _last_size: Vector2 = Vector2(-1, -1)
var _cjk_char_size_cache: Dictionary = {}


func _get_font() -> Font:
	if font != null:
		return font
	return ThemeDB.fallback_font


func _effective_padding() -> float:
	return (font_size * 0.5) if padding < 0.0 else padding


## See TategakiLabel._measure_cjk_char_size() in the full addon for the
## empirical rationale (same font metric: a vertical-oriented TextLine's
## cross-axis extent is ~1.65-1.69x font_size for Noto Sans/Serif JP, not
## font_size itself). Lite measures every character this way -- there is no
## separate rotated-Latin code path to special-case.
func _measure_cjk_char_size(f: Font) -> float:
	var key := str(f.get_instance_id()) + ":" + str(font_size)
	if _cjk_char_size_cache.has(key):
		return _cjk_char_size_cache[key]
	var tl := TextLine.new()
	tl.add_string("あ", f, font_size)
	tl.set_orientation(TextServer.ORIENTATION_VERTICAL)
	var w: float = tl.get_size().x
	if w <= 0.0:
		w = float(font_size)
	_cjk_char_size_cache[key] = w
	return w


func _mark_dirty() -> void:
	_dirty = true
	queue_redraw()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		if size != _last_size:
			_mark_dirty()


func get_columns_used() -> int:
	_ensure_layout()
	return int(_layout.get("columns_used", 0))


func _ensure_layout() -> void:
	if not _dirty and size == _last_size:
		return
	_last_size = size
	_dirty = false
	var f := _get_font()
	var cjk_char_size := _measure_cjk_char_size(f) if f != null else float(font_size)
	var pad := _effective_padding()
	var inner_size := Vector2(max(0.0, size.x - pad * 2.0), max(0.0, size.y - pad * 2.0))
	_layout = LayoutLite.compute_layout(text, font_size, char_spacing, line_spacing, max_chars_per_column, inner_size, cjk_char_size)
	_rebuild_shapes()


func _rebuild_shapes() -> void:
	_shaped_cells.clear()
	var f := _get_font()
	if f == null:
		return
	for cell in _layout["cells"]:
		var tl := TextLine.new()
		tl.add_string(cell["text"], f, font_size)
		tl.set_orientation(TextServer.ORIENTATION_VERTICAL)
		_shaped_cells.append({"cell": cell, "tl": tl})


func _draw() -> void:
	_ensure_layout()
	var f := _get_font()
	if f == null or _shaped_cells.is_empty():
		return

	var row_pitch: float = _layout["row_pitch"]
	var column_pitch: float = _layout["column_pitch"]
	var columns_used: int = _layout["columns_used"]
	var block_width: float = columns_used * column_pitch

	var pad := _effective_padding()
	var inner_width: float = max(0.0, size.x - pad * 2.0)

	var col0_right: float
	match column_alignment:
		HORIZONTAL_ALIGNMENT_LEFT:
			col0_right = block_width
		HORIZONTAL_ALIGNMENT_CENTER:
			col0_right = (inner_width + block_width) * 0.5
		_:
			col0_right = inner_width  # RIGHT / FILL

	var cjk_char_size := _measure_cjk_char_size(f)
	var ci := get_canvas_item()

	for shaped in _shaped_cells:
		var cell: Dictionary = shaped["cell"]
		var col_center_x: float = pad + col0_right - cell["column"] * column_pitch - column_pitch * 0.5
		var row_top_y: float = pad + float(cell["row"]) * row_pitch
		var tl: TextLine = shaped["tl"]
		var pos := Vector2(col_center_x - cjk_char_size * 0.5, row_top_y)
		tl.draw(ci, pos, font_color)
