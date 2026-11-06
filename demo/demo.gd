## Demo: a short vertical (tategaki) text sample using TategakiLabelLite.
## Click / press any key to advance to the next sample.
extends Control

## Ships the same demo font as the full version's demo (NotoSerifJP, OFL --
## see demo/font/OFL.txt) so the sample displays correctly out of the box.
const FONT_PATH := "res://demo/font/NotoSerifJP-Regular.ttf"

var samples: Array = [
	{
		"title": "ノベル風本文 (右から左の列・上から下の字)",
		"text": "「あなたは、本当にそれでいいのですか」と彼女は静かに尋ねた。\n　窓の外では、雪が降り続いている。",
		"size": 28,
	},
	{
		"title": "基本の性質 (font_size・字の間・列の間)",
		"text": "縦書きのレイアウト\nGodot4で動く",
		"size": 32, "char_spacing": 4.0, "line_spacing": 20.0,
	},
	{
		"title": "Lite が入れない記法はそのまま字で出る",
		"text": "午後[tcy]12[/tcy]時、｜漢字《よみ》はエラーにならない。",
		"size": 24,
	},
]

var label: TategakiLabelLite
var title_label: Label
var current_index := -1


func _ready() -> void:
	var font: Font = load(FONT_PATH)

	var vbox := VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 16)
	add_child(vbox)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_right", 24)
	vbox.add_child(margin)

	title_label = Label.new()
	title_label.add_theme_font_override("font", font)
	title_label.add_theme_font_size_override("font_size", 18)
	margin.add_child(title_label)

	var panel := ColorRect.new()
	panel.color = Color(0.1, 0.1, 0.13)
	panel.custom_minimum_size = Vector2(460, 420)
	vbox.add_child(panel)

	label = TategakiLabelLite.new()
	label.custom_minimum_size = Vector2(440, 400)
	label.position = Vector2(10, 10)
	panel.add_child(label)

	var hint := Label.new()
	hint.add_theme_font_override("font", font)
	hint.add_theme_font_size_override("font_size", 14)
	hint.text = "クリックまたは何かキーを押すと次の例へ / click or press a key for the next sample"
	var hint_margin := MarginContainer.new()
	hint_margin.add_theme_constant_override("margin_left", 24)
	hint_margin.add_child(hint)
	vbox.add_child(hint_margin)

	_show_sample(0)


func _show_sample(i: int) -> void:
	current_index = i
	var sample: Dictionary = samples[i]
	title_label.text = "%d/%d  %s" % [i + 1, samples.size(), sample["title"]]
	label.font = load(FONT_PATH)
	label.font_size = sample["size"]
	label.char_spacing = sample.get("char_spacing", 0.0)
	label.line_spacing = sample.get("line_spacing", 8.0)
	label.font_color = Color(0.92, 0.92, 0.92)
	label.text = sample["text"]


func _unhandled_input(event: InputEvent) -> void:
	if (event is InputEventMouseButton and event.pressed) or (event is InputEventKey and event.pressed):
		_show_sample((current_index + 1) % samples.size())
