{ zsh }:
let
  colorScheme = import ./alacritty-catppuccin-mocha-color-scheme.nix;
in ''
env:
  TERM: alacritty-direct


window:
  dimensions:
    columns: 0
    lines: 0

  startup_mode: 'Maximized'

  padding:
    x: 2
    y: 2

  decorations: full
  dynamic_title: true

draw_bold_text_with_bright_colors: true

font:
  normal:
    family: "FiraCode Nerd Font"
    style: Regular

  bold:
    family: "FiraCode Nerd Font"
    style: Bold

  italic:
    family: "FiraCode Nerd Font"
    style: Italic

  size: 12.0

  offset:
    x: 0
    y: 0

  glyph_offset:
    x: 0
    y: 0

render_timer: false

${colorScheme}

bell:
  animation: EaseOutExpo
  duration: 0

# Background opacity
window.opacity: 1.0

mouse_bindings:
  - { mouse: Middle, action: PasteSelection }

mouse:
  double_click: { threshold: 300 }
  triple_click: { threshold: 300 }

  faux_scrolling_lines: 1

  hide_when_typing: true

selection:
  semantic_escape_chars: ",?`|:\"' ()[]{}<>"
  save_to_clipboard: true


live_config_reload: true

shell:
  program: ${zsh}/bin/zsh
  args:
    - --login

key_bindings:
  - { key: V,        mods: Command, action: Paste                        }
  - { key: C,        mods: Command, action: Copy                         }
  - { key: Paste,                   action: Paste                        }
  - { key: Copy,                    action: Copy                         }
  - { key: H,        mods: Command, action: Hide                         }
  - { key: Q,        mods: Command, action: Quit                         }
  - { key: W,        mods: Command, action: Quit                         }
  - { key: Home,                    chars: "\x1bOH",   mode: AppCursor   }
  - { key: Home,                    chars: "\x1b[H",   mode: ~AppCursor  }
  - { key: End,                     chars: "\x1bOF",   mode: AppCursor   }
  - { key: End,                     chars: "\x1b[F",   mode: ~AppCursor  }
  - { key: Key0,     mods: Command, action: ResetFontSize                }
  - { key: Equals,   mods: Command, action: IncreaseFontSize             }
  - { key: Minus,    mods: Command, action: DecreaseFontSize             }
  - { key: K,        mods: Command, chars: "\x0c"                        }
  - { key: PageUp,   mods: Shift,   chars: "\x1b[5;2~"                   }
  - { key: PageUp,   mods: Control, chars: "\x1b[5;5~"                   }
  - { key: PageUp,                  chars: "\x1b[5~"                     }
  - { key: PageDown, mods: Shift,   chars: "\x1b[6;2~"                   }
  - { key: PageDown, mods: Control, chars: "\x1b[6;5~"                   }
  - { key: PageDown,                chars: "\x1b[6~"                     }
  - { key: Tab,      mods: Shift,   chars: "\x1b[Z"                      }
  - { key: Back,                    chars: "\x7f"                        }
  - { key: Back,     mods: Alt,     chars: "\x1b\x7f"                    }
  - { key: Insert,                  chars: "\x1b[2~"                     }
  - { key: Delete,                  chars: "\x1b[3~"                     }
  - { key: Left,     mods: Shift,   chars: "\x1b[1;2D"                   }
  - { key: Left,     mods: Control, chars: "\x1b[1;5D"                   }
  - { key: Left,     mods: Alt,     chars: "\x1b[1;3D"                   }
  - { key: Left,                    chars: "\x1b[D",   mode: ~AppCursor  }
  - { key: Left,                    chars: "\x1bOD",   mode: AppCursor   }
  - { key: Right,    mods: Shift,   chars: "\x1b[1;2C"                   }
  - { key: Right,    mods: Control, chars: "\x1b[1;5C"                   }
  - { key: Right,    mods: Alt,     chars: "\x1b[1;3C"                   }
  - { key: Right,                   chars: "\x1b[C",   mode: ~AppCursor  }
  - { key: Right,                   chars: "\x1bOC",   mode: AppCursor   }
  - { key: Up,       mods: Shift,   chars: "\x1b[1;2A"                   }
  - { key: Up,       mods: Control, chars: "\x1b[1;5A"                   }
  - { key: Up,       mods: Alt,     chars: "\x1b[1;3A"                   }
  - { key: Up,                      chars: "\x1b[A",   mode: ~AppCursor  }
  - { key: Up,                      chars: "\x1bOA",   mode: AppCursor   }
  - { key: Down,     mods: Shift,   chars: "\x1b[1;2B"                   }
  - { key: Down,     mods: Control, chars: "\x1b[1;5B"                   }
  - { key: Down,     mods: Alt,     chars: "\x1b[1;3B"                   }
  - { key: Down,                    chars: "\x1b[B",   mode: ~AppCursor  }
  - { key: Down,                    chars: "\x1bOB",   mode: AppCursor   }
  - { key: F1,                      chars: "\x1bOP"                      }
  - { key: F2,                      chars: "\x1bOQ"                      }
  - { key: F3,                      chars: "\x1bOR"                      }
  - { key: F4,                      chars: "\x1bOS"                      }
  - { key: F5,                      chars: "\x1b[15~"                    }
  - { key: F6,                      chars: "\x1b[17~"                    }
  - { key: F7,                      chars: "\x1b[18~"                    }
  - { key: F8,                      chars: "\x1b[19~"                    }
  - { key: F9,                      chars: "\x1b[20~"                    }
  - { key: F10,                     chars: "\x1b[21~"                    }
  - { key: F11,                     chars: "\x1b[23~"                    }
  - { key: F12,                     chars: "\x1b[24~"                    }
  - { key: F1,       mods: Shift,   chars: "\x1b[1;2P"                   }
  - { key: F2,       mods: Shift,   chars: "\x1b[1;2Q"                   }
  - { key: F3,       mods: Shift,   chars: "\x1b[1;2R"                   }
  - { key: F4,       mods: Shift,   chars: "\x1b[1;2S"                   }
  - { key: F5,       mods: Shift,   chars: "\x1b[15;2~"                  }
  - { key: F6,       mods: Shift,   chars: "\x1b[17;2~"                  }
  - { key: F7,       mods: Shift,   chars: "\x1b[18;2~"                  }
  - { key: F8,       mods: Shift,   chars: "\x1b[19;2~"                  }
  - { key: F9,       mods: Shift,   chars: "\x1b[20;2~"                  }
  - { key: F10,      mods: Shift,   chars: "\x1b[21;2~"                  }
  - { key: F11,      mods: Shift,   chars: "\x1b[23;2~"                  }
  - { key: F12,      mods: Shift,   chars: "\x1b[24;2~"                  }
  - { key: F1,       mods: Control, chars: "\x1b[1;5P"                   }
  - { key: F2,       mods: Control, chars: "\x1b[1;5Q"                   }
  - { key: F3,       mods: Control, chars: "\x1b[1;5R"                   }
  - { key: F4,       mods: Control, chars: "\x1b[1;5S"                   }
  - { key: F5,       mods: Control, chars: "\x1b[15;5~"                  }
  - { key: F6,       mods: Control, chars: "\x1b[17;5~"                  }
  - { key: F7,       mods: Control, chars: "\x1b[18;5~"                  }
  - { key: F8,       mods: Control, chars: "\x1b[19;5~"                  }
  - { key: F9,       mods: Control, chars: "\x1b[20;5~"                  }
  - { key: F10,      mods: Control, chars: "\x1b[21;5~"                  }
  - { key: F11,      mods: Control, chars: "\x1b[23;5~"                  }
  - { key: F12,      mods: Control, chars: "\x1b[24;5~"                  }
  - { key: F1,       mods: Alt,     chars: "\x1b[1;6P"                   }
  - { key: F2,       mods: Alt,     chars: "\x1b[1;6Q"                   }
  - { key: F3,       mods: Alt,     chars: "\x1b[1;6R"                   }
  - { key: F4,       mods: Alt,     chars: "\x1b[1;6S"                   }
  - { key: F5,       mods: Alt,     chars: "\x1b[15;6~"                  }
  - { key: F6,       mods: Alt,     chars: "\x1b[17;6~"                  }
  - { key: F7,       mods: Alt,     chars: "\x1b[18;6~"                  }
  - { key: F8,       mods: Alt,     chars: "\x1b[19;6~"                  }
  - { key: F9,       mods: Alt,     chars: "\x1b[20;6~"                  }
  - { key: F10,      mods: Alt,     chars: "\x1b[21;6~"                  }
  - { key: F11,      mods: Alt,     chars: "\x1b[23;6~"                  }
  - { key: F12,      mods: Alt,     chars: "\x1b[24;6~"                  }
  - { key: F1,       mods: Command, chars: "\x1b[1;3P"                   }
  - { key: F2,       mods: Command, chars: "\x1b[1;3Q"                   }
  - { key: F3,       mods: Command, chars: "\x1b[1;3R"                   }
  - { key: F4,       mods: Command, chars: "\x1b[1;3S"                   }
  - { key: F5,       mods: Command, chars: "\x1b[15;3~"                  }
  - { key: F6,       mods: Command, chars: "\x1b[17;3~"                  }
  - { key: F7,       mods: Command, chars: "\x1b[18;3~"                  }
  - { key: F8,       mods: Command, chars: "\x1b[19;3~"                  }
  - { key: F9,       mods: Command, chars: "\x1b[20;3~"                  }
  - { key: F10,      mods: Command, chars: "\x1b[21;3~"                  }
  - { key: F11,      mods: Command, chars: "\x1b[23;3~"                  }
  - { key: F12,      mods: Command, chars: "\x1b[24;3~"                  }
  - { key: NumpadEnter,             chars: "\n"                          }
''
