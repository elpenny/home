local wezterm = require 'wezterm'
local act = wezterm.action

local config = wezterm.config_builder()
local wsl_domains = wezterm.default_wsl_domains()
local windows_powershell = 'C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe'

local function windows_powershell_args()
  return { windows_powershell, '-NoLogo', '-ExecutionPolicy', 'Bypass' }
end

for _, domain in ipairs(wsl_domains) do
  if domain.name == 'WSL:Ubuntu' then
    domain.default_cwd = '~'
  end
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
    return { process_name, '-NoLogo', '-ExecutionPolicy', 'Bypass' }
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

config.wsl_domains = wsl_domains
config.default_domain = 'WSL:Ubuntu'
config.launch_menu = {
  {
    label = 'Ubuntu',
    domain = { DomainName = 'WSL:Ubuntu' },
  },
  {
    label = 'Windows PowerShell',
    domain = { DomainName = 'local' },
    args = windows_powershell_args(),
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
