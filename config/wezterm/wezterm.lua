local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- ── Default shell: PowerShell 7 (pwsh), not the legacy 5.1 (powershell.exe) ──
config.default_prog = { 'pwsh.exe', '-NoLogo' }

-- ── Everforest Dark (same hexes as the Windows Terminal scheme) ────────────
config.colors = {
  foreground    = '#D3C6AA',
  background    = '#272E33',
  cursor_bg     = '#F3F5D9',
  cursor_fg     = '#272E33',
  cursor_border = '#F3F5D9',
  selection_bg  = '#F3F5D9',
  selection_fg  = '#272E33',
  ansi = {
    '#272E33', '#E67E80', '#A7C080', '#DBBC7F',
    '#7FBBB3', '#D699B6', '#83C092', '#D3C6AA',
  },
  brights = {
    '#54646E', '#EC9EA0', '#BDD0A0', '#E4CD9F',
    '#9FCCC6', '#E0B3C8', '#A2D0AD', '#DED4BF',
  },
  tab_bar = {
    background         = '#272E33',
    active_tab         = { bg_color = '#A7C080', fg_color = '#272E33' },
    inactive_tab       = { bg_color = '#2E383C', fg_color = '#859289' },
    inactive_tab_hover = { bg_color = '#374247', fg_color = '#D3C6AA' },
    new_tab            = { bg_color = '#272E33', fg_color = '#859289' },
    new_tab_hover      = { bg_color = '#374247', fg_color = '#D3C6AA' },
  },
}

-- ── Font ────────────────────────────────────────────────────────────────────
-- Family names come from `wezterm ls-fonts --list-system`.
config.font = wezterm.font_with_fallback {
  'JetBrainsMono NF',
  'Cascadia Mono',
}
config.font_size = 11.0
config.line_height = 1.05

-- ── Window ──────────────────────────────────────────────────────────────────
config.window_decorations = 'RESIZE'        -- no title bar, keep resize edges
config.window_padding = { left = 14, right = 14, top = 12, bottom = 8 }
-- Transparency (blur shows on the focused window; Windows drops it when unfocused).
config.window_background_opacity = 0.5      -- lower = glassier; below ~0.5 risks contrast
config.win32_system_backdrop = 'Acrylic'    -- 'Acrylic' = frosted blur | 'Mica' = wallpaper tint | delete line = sharp see-through

-- ── Tab bar ──────────────────────────────────────────────────────────────────
config.use_fancy_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true
config.window_frame = {
  font = wezterm.font { family = 'JetBrainsMono NF', weight = 'Regular' },
  font_size = 10.0,
  active_titlebar_bg = '#272E33',
  inactive_titlebar_bg = '#272E33',
}

-- ── Cursor / misc ────────────────────────────────────────────────────────────
config.default_cursor_style = 'SteadyBar'
config.cursor_blink_rate = 0
config.inactive_pane_hsb = { saturation = 0.9, brightness = 0.7 }
config.scrollback_lines = 10000
config.audible_bell = 'Disabled'

return config
