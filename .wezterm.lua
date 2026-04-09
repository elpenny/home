local wezterm = require 'wezterm'
local act = wezterm.action

local config = wezterm.config_builder()
local wsl_domains = wezterm.default_wsl_domains()
local windows_powershell = 'C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe'

for _, domain in ipairs(wsl_domains) do
  if domain.name == 'WSL:Ubuntu' then
    domain.default_cwd = '~'
  end
end

local function basename(path)
  if not path or path == '' then
    return nil
  end

  local normalized = path:gsub('/+$', '')
  local name = normalized:match('([^/\\]+)$')
  if name and name ~= '' then
    return name
  end

  return normalized
end

local function shell_args_for_process(process_name)
  if not process_name or process_name == '' then
    return nil
  end

  local normalized = process_name:gsub('\\', '/'):lower()

  if normalized:match('/pwsh%.exe$') then
    return { process_name, '-NoLogo' }
  end

  if normalized:match('/powershell%.exe$') then
    return { process_name, '-NoLogo' }
  end

  if normalized:match('/cmd%.exe$') then
    return { process_name }
  end

  return nil
end

local function smart_split(direction)
  return wezterm.action_callback(function(window, pane)
    local spawn = { domain = 'CurrentPaneDomain' }
    local shell_args = shell_args_for_process(pane:get_foreground_process_name())

    if shell_args then
      spawn.args = shell_args
    end

    if direction == 'Right' then
      window:perform_action(act.SplitHorizontal(spawn), pane)
    else
      window:perform_action(act.SplitVertical(spawn), pane)
    end
  end)
end

wezterm.on('format-tab-title', function(tab)
  local pane = tab.active_pane
  local cwd_uri

  if pane then
    if type(pane.get_current_working_dir) == 'function' then
      cwd_uri = pane:get_current_working_dir()
    else
      cwd_uri = pane.current_working_dir
    end
  end

  if cwd_uri then
    local cwd = type(cwd_uri) == 'userdata' and cwd_uri.file_path or tostring(cwd_uri)
    local dir = basename(cwd)
    if dir then
      return dir
    end
  end

  return pane and pane.title or tab.tab_title
end)

config.wsl_domains = wsl_domains
config.default_domain = 'WSL:Ubuntu'
config.default_prog = { windows_powershell, '-NoLogo' }
config.launch_menu = {
  {
    label = 'Ubuntu',
    domain = { DomainName = 'WSL:Ubuntu' },
  },
  {
    label = 'Windows PowerShell',
    args = {
      windows_powershell,
      '-NoLogo',
    },
  },
  {
    label = 'PowerShell 7',
    args = { 'pwsh.exe', '-NoLogo' },
  },
}

config.keys = {
  { key = '"', mods = 'ALT|CTRL', action = smart_split 'Down' },
  { key = '"', mods = 'SHIFT|ALT|CTRL', action = smart_split 'Down' },
  { key = "'", mods = 'SHIFT|ALT|CTRL', action = smart_split 'Down' },
  { key = '%', mods = 'ALT|CTRL', action = smart_split 'Right' },
  { key = '%', mods = 'SHIFT|ALT|CTRL', action = smart_split 'Right' },
  { key = '5', mods = 'SHIFT|ALT|CTRL', action = smart_split 'Right' },
}

config.font = wezterm.font 'CaskaydiaCove Nerd Font'
config.font_size = 11.0

config.color_scheme = 'Tokyo Night'
config.window_background_opacity = 0.92

return config
