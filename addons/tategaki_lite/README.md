# Tategaki Lite for Godot 4

Free Lite version of [Tategaki -- Vertical Japanese Text for Godot 4](https://ibuking289.itch.io/tategaki-godot4).

A `Control` node (`TategakiLabelLite`) that renders Japanese text in
tategaki (vertical) layout: right-to-left columns, top-to-bottom
characters, explicit `\n` for a hard column break, correct vertical glyph
forms for punctuation/brackets/small kana (via the font's OpenType
`vert`/`vrt2` feature), and automatic column wrapping.

> **This addon's code was written with the help of AI (Claude).**

## What it does (Lite)

- Right-to-left columns, top-to-bottom characters, explicit `\n` for a hard
  column break.
- Correct vertical punctuation via the font's `vert`/`vrt2` GSUB table (、。
  move to the top-right of their cell, ー rotates to a vertical stroke,
  small kana shift, brackets/quotes rotate) -- same TextServer-level
  mechanism the full version uses.
- Automatic column wrapping by the control's height (or a fixed
  `max_chars_per_column`).
- Basic properties: `font`, `font_size`, `char_spacing` (gap between
  characters within a column), `line_spacing` (gap between columns),
  `font_color`.

## Install

1. Copy `addons/tategaki_lite/` into your project's `addons/` folder.
2. Project Settings > Plugins > enable "Tategaki Lite" (optional --
   `TategakiLabelLite` works immediately via `class_name` even with the
   plugin disabled; enabling it just adds a `TategakiLabelLite` icon/
   shortcut to the "Create Node" dialog).
3. Add a `TategakiLabelLite` node, assign a `font` that has `vert`/`vrt2`
   OpenType features, set `font_size`, and set `text`.

Lite's classes (`TategakiLabelLite`, `TategakiLayoutLite`) are both renamed
from the full version's (`TategakiLabel`, `TategakiLayout`), and its addon
folder is `tategaki_lite` (not `tategaki`), so Lite and the full "Tategaki"
addon can both be installed in the same project without any `class_name` or
folder conflict.

## Properties (TategakiLabelLite)

| Property | Type | Default | Description |
|---|---|---|---|
| `text` | String (multiline) | `""` | Source text. `\n` forces a column break. |
| `font` | Font | `null` | Falls back to `ThemeDB.fallback_font` if unset. Should carry `vert`/`vrt2` for correct vertical punctuation. |
| `font_size` | int | `32` | |
| `font_color` | Color | dark gray | |
| `line_spacing` | float | `8.0` | Extra gap, in px, between columns. Added to the per-column pitch. |
| `char_spacing` | float | `0.0` | Extra gap, in px, between characters within the same column. Added to the per-row pitch. |
| `max_chars_per_column` | int | `0` | Fixed rows per column. `0` = auto: wrap by the control's height instead. |
| `column_alignment` | HorizontalAlignment | `RIGHT` | How the block of columns is anchored horizontally when the text doesn't fill the full width. |
| `padding` | float | `-1.0` | Inset, in px, applied to all four sides before laying out columns/rows. `-1` (default) means `0.5 * font_size`. |

Method: `get_columns_used() -> int`.

## Lite vs full Tategaki ($4)

| Feature | Lite (free) | Full ($4) |
|---|---|---|
| Right-to-left columns, top-to-bottom characters, `\n` break | Yes | Yes |
| Vertical punctuation via font `vert`/`vrt2` | Yes | Yes |
| Automatic column wrapping | Yes | Yes |
| Basic properties (font/font_size/char_spacing/line_spacing/color) | Yes | Yes |
| Kinsoku (line-head burasage/oidashi, line-end) | No | Yes |
| Half-width Latin/digit rotation | No | Yes |
| `[tcy]..[/tcy]` tate-chu-yoko | No | Yes |
| Ruby (furigana) / emphasis dots (bouten) | No | Yes |
| Typewriter reveal (`visible_characters`/`visible_ratio`) / `get_overflow()` | No | Yes |
| Outline (`outline_size`/`outline_color`) | No | Yes |

Full version: <https://ibuking289.itch.io/tategaki-godot4>

## Limitations (Lite, honest list)

- No kinsoku: punctuation/brackets/small kana may start or end a column
  where the full version would hang or push them back.
- Half-width Latin/digits are **not** rotated -- they render upright, like
  any other character, instead of the full version's 90-degree rotation.
- `[tcy]..[/tcy]` and ruby markup (`[ruby=よみ]..[/ruby]`, `｜漢字《よみ》`,
  ...) are **not** recognized -- any such text is drawn exactly as typed,
  character by character. Never dropped, never an error.
- No typewriter reveal and no `get_overflow()` pagination.
- Requires a font with `vert`/`vrt2` OpenType features for correct vertical
  punctuation (same requirement as the full version -- see its README for
  details on font subsetting caveats).
- Tested only on the versions listed below.

## Tested versions

- **Godot 4.7.2-stable** and **Godot 4.3-stable**, Windows x64, headless:
  layout unit tests (`tests/`, not included in the distributed zip) all
  passing, plus a packaged-zip install check (fresh project, every script
  in the addon loading with no parse errors).

No rendered-screenshot/visual check and no other Godot 4.x version,
renderer, OS, or export template (mobile/web) has been verified for Lite.

## License

MIT (see `LICENSE.txt`). No font is required by the addon -- assign your
own Japanese font (e.g. Noto Serif JP / Noto Sans JP) via `font`. The full
version (Tategaki for Godot 4) is sold separately under its own license.
