{ zsh }:''
env:
  TERM: screen-256color

window:
  dimensions:
    columns: 80
    lines: 24

  padding:
    x: 2
    y: 2

  decorations: false

tabspaces: 4

draw_bold_text_with_bright_colors: true

font:
  normal:
    family: Menlo
    style: Regular

  bold:
    family: Menlo
    style: Bold

  italic:
    family: Menlo
    style: Italic

  size: 12.0

  offset:
    x: 0
    y: 0

  glyph_offset:
    x: 0
    y: 0

  scale_with_dpi: true

  use_thin_strokes: true

render_timer: false

custom_cursor_colors: false

# Base16 Default Dark 256 - alacritty color config
# Chris Kempson (http://chriskempson.com)
colors:
  # Default colors
  primary:
    background: '0x181818'
    foreground: '0xd8d8d8'

  # Colors the cursor will use if `custom_cursor_colors` is true
  cursor:
    text: '0x181818'
    cursor: '0xd8d8d8'

  # Normal colors
  normal:
    black:   '0x181818'
    red:     '0xab4642'
    green:   '0xa1b56c'
    yellow:  '0xf7ca88'
    blue:    '0x7cafc2'
    magenta: '0xba8baf'
    cyan:    '0x86c1b9'
    white:   '0xd8d8d8'

  # Bright colors
  bright:
    black:   '0x585858'
    red:     '0xab4642'
    green:   '0xa1b56c'
    yellow:  '0xf7ca88'
    blue:    '0x7cafc2'
    magenta: '0xba8baf'
    cyan:    '0x86c1b9'
    white:   '0xd8d8d8'

visual_bell:
  animation: EaseOutExpo
  duration: 0

# Background opacity
background_opacity: 1.0

mouse_bindings:
  - { mouse: Middle, action: PasteSelection }

mouse:
  double_click: { threshold: 300 }
  triple_click: { threshold: 300 }

  faux_scrollback_lines: 1

selection:
  semantic_escape_chars: ",?`|:\"' ()[]{}<>"

dynamic_title: true

hide_cursor_when_typing: true

cursor_style: Block

unfocused_hollow_cursor: true

live_config_reload: true

shell:
  program: ${zsh}/bin/zsh
  args:
    - --login
''
