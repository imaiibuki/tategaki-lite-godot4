## Pure layout logic for TategakiLabelLite -- no Font/TextServer/rendering
## calls here, only string + integer/float math, so this can be unit-tested
## headlessly without loading a font or opening a window (see
## tests/test_layout.gd).
##
## Lite cut: every character (CJK or half-width Latin/ASCII) is placed the
## same way, top-to-bottom within a column, right-to-left across columns.
## No kinsoku (line-head/line-end) rules, no Latin/digit rotation, no
## `[tcy]..[/tcy]` tate-chu-yoko, no ruby. None of those notations is parsed
## specially here -- a string like "[tcy]12[/tcy]" or "｜漢字《よみ》" is
## tokenized character-by-character like any other text and drawn as
## literal characters, never dropped and never an error. See the full
## "Tategaki" addon (https://ibuking289.itch.io/tategaki-godot4) for those
## features.
@tool
class_name TategakiLayoutLite
extends RefCounted


## Tokenizes `text` into an Array of Dictionaries:
##   {"type": "char", "text": <1 char>}
##   {"type": "newline"}
## Every character is its own "char" token, including the ASCII brackets/
## pipes the full version's `[tcy]`/ruby notation uses -- Lite does not
## recognize that markup, so it is tokenized and drawn exactly like any
## other literal character.
static func tokenize(text: String) -> Array:
	var tokens: Array = []
	for i in text.length():
		var ch := text[i]
		if ch == "\n":
			tokens.append({"type": "newline"})
		else:
			tokens.append({"type": "char", "text": ch})
	return tokens


## Main entry point. `size` is the Control's pixel size. Returns a
## Dictionary:
##   "cells": Array of {text, column, row, logical_index} -- only cells that
##            fit inside `size` (columns_available) are included.
##   "columns_used": highest column index actually containing a fitting
##            cell, + 1 (0 if nothing fit)
##   "columns_available": how many columns fit in `size.x`
##   "rows_per_column": rows per column used for this layout
##   "row_pitch": per-character advance down a column
##   "column_pitch": per-column advance across the block
##   "total_chars": total characters in `text` (newlines excluded)
##
## `column_char_size`: optional override for the per-column "character
## width" used to compute column_pitch (column_pitch = column_char_size +
## line_spacing). Defaults to -1, meaning "use font_size" (what every
## headless unit test below assumes). The renderer passes the real measured
## cross-axis size of a vertical-oriented TextLine here (see
## tategaki_label_lite.gd), because that is what actually needs to fit
## between column centers without clipping; row pitch (the
## character-to-character advance within a column) is unaffected: a
## vertical-oriented TextLine's extent *along* the flow axis is font_size.
static func compute_layout(
	text: String,
	font_size: int,
	char_spacing: float,
	line_spacing: float,
	max_chars_per_column: int,
	size: Vector2,
	column_char_size: float = -1.0
) -> Dictionary:
	var row_pitch: float = max(1.0, font_size + char_spacing)
	var effective_column_char: float = column_char_size if column_char_size > 0.0 else float(font_size)
	var column_pitch: float = max(1.0, effective_column_char + line_spacing)

	var rows_per_column: int
	if max_chars_per_column > 0:
		rows_per_column = max_chars_per_column
	else:
		rows_per_column = max(1, int(floor(size.y / row_pitch)))

	var columns_available: int = max(1, int(floor(size.x / column_pitch)))

	var tokens := tokenize(text)
	var cells: Array = []
	var logical_index := 0
	var column := 0
	var row := 0

	for tok in tokens:
		if tok["type"] == "newline":
			column += 1
			row = 0
			continue
		var cell := {
			"text": tok["text"],
			"column": column, "row": row,
			"logical_index": logical_index,
		}
		cells.append(cell)
		logical_index += 1
		row += 1
		if row >= rows_per_column:
			column += 1
			row = 0

	var total_chars := logical_index

	# Only the column axis (derived from size.x) determines what fits; a
	# column's row count is fixed by rows_per_column above, so no cell ever
	# overflows the row axis.
	var fitting_cells: Array = []
	var columns_used := 0
	for cell in cells:
		if cell["column"] < columns_available:
			fitting_cells.append(cell)
			columns_used = max(columns_used, int(cell["column"]) + 1)

	return {
		"cells": fitting_cells,
		"columns_used": columns_used,
		"columns_available": columns_available,
		"rows_per_column": rows_per_column,
		"row_pitch": row_pitch,
		"column_pitch": column_pitch,
		"total_chars": total_chars,
	}
