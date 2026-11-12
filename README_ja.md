# Tategaki Lite for Godot 4

[Tategaki -- Vertical Japanese Text for Godot 4](https://ibuking289.itch.io/tategaki-godot4)（$4）の無料
Lite 版です。完全版はブラウザで試せます: [無料の Web デモ](https://ibuking289.itch.io/japanese-text-godot-demo)。

仕組みの解説（Zenn）: [Godot 4 で日本語の縦書きを表示する（TextServerの縦書きは実は動く）](https://zenn.dev/ibuking289/articles/godot4-tategaki-textserver)。

`Control` ノード（`TategakiLabelLite`）で縦書き（tategaki）レイアウトを
描画します: 右から左への列、上から下への字、`\n` による明示的な改列、
フォントの OpenType `vert`/`vrt2` 機能による正しい縦書き用の句読点・括弧・
小書き文字の字形、そして自動の列の折り返し。

> **このアドオンのコードは AI（Claude）の助けを借りて書かれました。**

## できること (Lite)

- 右から左への列、上から下への字、`\n` による明示的な改列。
- フォントの `vert`/`vrt2` GSUB テーブルによる正しい縦書き句読点
  （、。は字の右上へ、ーは縦の線に回転、小書き仮名は右上へ寄る、括弧/
  引用符は回転）-- full 版と同じ TextServer レベルの仕組みを使います。
- 控え（Control）の高さによる自動の列の折り返し（または固定の
  `max_chars_per_column`）。
- 基本の性質: `font`、`font_size`、`char_spacing`（列内の字の間の隙間）、
  `line_spacing`（列と列の間の隙間）、`font_color`。

## 導入方法

1. `addons/tategaki_lite/` をプロジェクトの `addons/` フォルダにコピー
   （または [Releases](https://github.com/imaiibuki/tategaki-lite-godot4/releases/latest) の `tategaki_lite_v1.0.0.zip` をプロジェクトのフォルダに展開）。
2. プロジェクト設定 > プラグイン で「Tategaki Lite」を有効化（任意 --
   `TategakiLabelLite` は `class_name` により、プラグインを有効にしなくても
   そのまま使えます。有効化すると「ノードを作成」ダイアログに
   `TategakiLabelLite` 用のアイコン/ショートカットが追加されるだけです）。
3. `TategakiLabelLite` ノードを追加し、`vert`/`vrt2` の OpenType 機能を持つ
   `font` を割り当て、`font_size` を設定し、`text` を設定します。

Lite のクラス名（`TategakiLabelLite`、`TategakiLayoutLite`）はいずれも
full 版（`TategakiLabel`、`TategakiLayout`）とは別名にし、アドオンの
フォルダ名も `tategaki_lite`（`tategaki` ではない）にしているため、Lite と
full 版「Tategaki」を同じプロジェクトに両方導入しても `class_name` や
フォルダの衝突は起きません。

## プロパティ (TategakiLabelLite)

| プロパティ | 型 | デフォルト | 説明 |
|---|---|---|---|
| `text` | String（複数行） | `""` | 入力テキスト。`\n` で改列します。 |
| `font` | Font | `null` | 未設定時は `ThemeDB.fallback_font` を使用。正しい縦書き句読点のため `vert`/`vrt2` を持つフォントを推奨。 |
| `font_size` | int | `32` | |
| `font_color` | Color | 濃い灰色 | |
| `line_spacing` | float | `8.0` | 列と列の間の追加の隙間（px）。列の送り幅に加算されます。 |
| `char_spacing` | float | `0.0` | 同じ列内の字と字の間の追加の隙間（px）。行の送り幅に加算されます。 |
| `max_chars_per_column` | int | `0` | 1列あたりの固定の字数。`0` = 自動（控えの高さで折り返し）。 |
| `column_alignment` | HorizontalAlignment | `RIGHT` | 文字がコントロールの幅を使い切らないとき、列のまとまりを水平にどう配置するか。 |
| `padding` | float | `-1.0` | 列・行を配置する前に四辺に適用する余白（px）。`-1`（デフォルト）は `0.5 * font_size`。 |

メソッド: `get_columns_used() -> int`。

## Lite と full 版 Tategaki（$4）の比較

| 機能 | Lite（無料） | full 版（$4） |
|---|---|---|
| 右から左の列・上から下の字・`\n` 改列 | あり | あり |
| フォント `vert`/`vrt2` による縦書き句読点 | あり | あり |
| 自動の列の折り返し | あり | あり |
| 基本の性質（font・font_size・字の間・列の間・色） | あり | あり |
| 禁則処理（行頭のぶら下げ/追い出し、行末） | なし | あり |
| 半角英数字の回転 | なし | あり |
| `[tcy]..[/tcy]` 縦中横 | なし | あり |
| ルビ（ふりがな）/ 圏点 | なし | あり |
| タイプライター表示 (`visible_characters`/`visible_ratio`) / `get_overflow()` | なし | あり |
| 縁取り (`outline_size`/`outline_color`) | なし | あり |

full 版: <https://ibuking289.itch.io/tategaki-godot4>

## 制限事項 (Lite、正直な一覧)

- 禁則処理はありません: full 版ならぶら下げ/追い出しされる句読点・括弧・
  小書き文字が、列の先頭や末尾にそのまま来ることがあります。
- 半角英数字は回転**しません** -- full 版の90度回転ではなく、他の文字と
  同じく縦のまま描画されます。
- `[tcy]..[/tcy]` やルビ記法（`[ruby=よみ]..[/ruby]`、`｜漢字《よみ》` など）
  は認識**しません** -- そのようなテキストは入力したとおり、文字として
  そのまま描画されます。文字が消えることも、エラーになることもありません。
- タイプライター表示や `get_overflow()` によるページングはありません。
- 正しい縦書き句読点には `vert`/`vrt2` の OpenType 機能を持つフォントが
  必要です（full 版と同じ要件 -- フォントのサブセット化に関する注意点は
  full 版の README を参照）。
- 下記のバージョンのみ確認済みです。

## 動作確認済みバージョン

- **Godot 4.7.2-stable** および **Godot 4.3-stable**、Windows x64、
  headless: レイアウトのユニットテスト（`tests/`、配布 zip には含まれません）
  は全てパス、加えてパッケージ化した zip の導入チェック（新規プロジェクトで
  アドオン内の全スクリプトがパースエラーなく読み込まれること）も確認済み。

レンダリングされたスクリーンショットでの目視確認、および上記以外の
Godot 4.x バージョン・レンダラー・OS・エクスポートテンプレート
（モバイル/web）での確認は行っていません。

## ライセンス

MIT（`LICENSE` 参照）。アドオン自体にフォントは必要ありません --
お好きな日本語フォント（例: Noto Serif JP / Noto Sans JP）を `font` に
割り当ててください。デモにはそのまま表示できるよう Noto Serif JP（SIL OFL 1.1）を同梱しています（`NOTICE.md` 参照）。full 版（Tategaki for Godot 4）は別のライセンスで
個別に販売されています。
