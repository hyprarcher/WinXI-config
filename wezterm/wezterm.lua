local wezterm = require 'wezterm'
local config = wezterm.config_builder()

------------------------------------------------------------------------
-- Transparency settings
------------------------------------------------------------------------
local TRANSLUCENT = true -- master switch for the see-through window
local BLUR = false -- true = frosted Acrylic blur behind the window
local OPACITY = 0.75    -- 0.0 = fully transparent, 1.0 = solid

-- Shell: PowerShell 7
config.default_prog = { 'pwsh.exe', '-NoLogo' }

------------------------------------------------------------------------
-- Startup: centered window, 1600 x 1000 px
------------------------------------------------------------------------
local WIN_W, WIN_H = 1600, 1000

wezterm.on('gui-startup', function(cmd)
  local _, _, window = wezterm.mux.spawn_window(cmd or {})
  local gui = window:gui_window()
  local screen = wezterm.gui.screens().active

  local w = math.min(WIN_W, screen.width)
  local h = math.min(WIN_H, screen.height)

  gui:set_inner_size(w, h)
  gui:set_position(
    math.floor(screen.x + (screen.width - w) / 2),
    math.floor(screen.y + (screen.height - h) / 2)
  )
end)

------------------------------------------------------------------------
-- Theme: planet_blue (palette sampled from Pictures/planet_blue.jpg)
--   deep-space black, electric arc blue, ice highlights, solar glint
------------------------------------------------------------------------
local P = {
  ink = '#00060c', -- text on bright fills
  ground = '#01050a', -- blue-black space
  panel = '#07121f', -- raised dark blue
  hair = '#14304a', -- separators and dim lines
  dim = '#4b6c8a', -- steel blue, secondary text
  text = '#c7ddf0', -- pale ice-blue, main text
  bright = '#eaf5ff', -- ice highlight
  ice = '#ffffff', -- arc core
  azure = '#14a9fd', -- most saturated pixel on the arc
  glow = '#0070c0', -- mid arc blue
  deep = '#004080', -- outer glow blue
  solar = '#ffbc49', -- warm glint where the arc bends
}

local scheme = {
  foreground = P.text,
  background = '#000000',
  cursor_bg = P.azure,
  cursor_border = P.azure,
  cursor_fg = P.ink,
  selection_fg = P.ice,
  selection_bg = P.deep,
  scrollbar_thumb = P.hair,
  split = P.hair,
  compose_cursor = P.solar,
  ansi = {
    '#08131f', -- black
    '#e5747e', -- red
    '#6fbf9b', -- green
    '#d8b471', -- yellow
    P.azure, -- blue
    '#9c8cd8', -- magenta
    '#6fd3e8', -- cyan
    P.text, -- white
  },
  brights = {
    '#3b566e', -- bright black
    '#ff9299', -- bright red
    '#95dbc0', -- bright green
    '#ffd98e', -- bright yellow
    '#62c9ff', -- bright blue
    '#c0b3f5', -- bright magenta
    '#a5e8f5', -- bright cyan
    P.ice, -- bright white
  },
}

local BAR_BG = TRANSLUCENT and 'rgba(0,0,0,0)' or P.ground

scheme.tab_bar = {
  background = BAR_BG,
  active_tab = { bg_color = P.azure, fg_color = P.ink },
  inactive_tab = { bg_color = BAR_BG, fg_color = P.dim },
  inactive_tab_hover = { bg_color = P.glow, fg_color = P.ice },
  new_tab = { bg_color = BAR_BG, fg_color = P.dim },
  new_tab_hover = { bg_color = P.panel, fg_color = P.bright },
}
config.colors = scheme

------------------------------------------------------------------------
-- Look: 2px padding, no border, clean dark transparency
------------------------------------------------------------------------
config.front_end = 'OpenGL' -- compositing path where Windows transparency works
config.prefer_egl = true   -- use ANGLE/EGL instead of WGL; WGL drops window alpha on this GPU
config.font = wezterm.font_with_fallback {
  'IoskeleyMonoTerm Nerd Font Mono',
  'IoskeleyMonoTerm Nerd Font',
}
config.font_size = 14.0
config.line_height = 1.25
config.default_cursor_style = 'SteadyBlock'
config.audible_bell = 'Disabled'
config.enable_scroll_bar = false
config.scrollback_lines = 10000

config.window_decorations = 'RESIZE'

config.window_padding = {
  left = 8,
  right = 8,
  top = 8,
  bottom = 8,
}

if TRANSLUCENT then
  config.window_background_opacity = OPACITY
end
config.inactive_pane_hsb = { saturation = 0.9, brightness = 0.7 }

------------------------------------------------------------------------
-- Top bar: WEZTERM label (left), white rectangle tabs, HOST / TIME (right)
------------------------------------------------------------------------
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = false
config.show_new_tab_button_in_tab_bar = false
config.tab_max_width = 28
config.status_update_interval = 5000

local function tab_label(pane)
  if not pane then
    return 'SHELL'
  end
  local exe = pane.foreground_process_name
  if exe and #exe > 0 then
    local name = exe:match('([^/\\]+)$') or exe
    name = name:gsub('%.exe$', '')
    if #name > 0 then
      return name:upper()
    end
  end
  local title = pane.title or 'SHELL'
  return (title:gsub('%.exe$', '')):upper()
end

wezterm.on('format-tab-title', function(tab, _, _, _, hover, max_width)
  local active = tab.is_active
  local bg = active and P.azure or (hover and P.panel or BAR_BG)
  local fg = active and P.ink or (hover and P.bright or P.dim)
  local idx = tostring(tab.tab_index + 1)
  local title = tab_label(tab.active_pane)
  title = wezterm.truncate_right(title, math.max(max_width - (#idx + 5), 1))

  return {
    { Background = { Color = bg } },
    { Foreground = { Color = fg } },
    { Attribute = { Intensity = active and 'Bold' or 'Normal' } },
    { Text = ' ' .. idx .. '  ' .. title .. ' ' },
    { Attribute = { Intensity = 'Normal' } },
    { Background = { Color = BAR_BG } },
    { Text = ' ' },
  }
end)

wezterm.on('update-status', function(window, _)
  window:set_left_status(wezterm.format {
    { Background = { Color = BAR_BG } },
    { Foreground = { Color = P.azure } },
    { Attribute = { Intensity = 'Bold' } },
    { Text = ' >> WEZTERM << ' },
    { Attribute = { Intensity = 'Normal' } },
    { Foreground = { Color = P.hair } },
  })

  local host = wezterm.hostname():gsub('%..*$', ''):upper()
  window:set_right_status(wezterm.format {
    { Background = { Color = BAR_BG } },
    { Foreground = { Color = P.bright } },
    { Attribute = { Intensity = 'Bold' } },
    { Text = ' HOST ' .. host .. ' ' },
    { Attribute = { Intensity = 'Normal' } },
    { Foreground = { Color = P.hair } },
    { Text = '│' },
    { Foreground = { Color = P.azure } },
    { Attribute = { Intensity = 'Bold' } },
    { Text = ' TIME ' .. wezterm.strftime('%H:%M') .. ' ' },
  })
end)

return config
