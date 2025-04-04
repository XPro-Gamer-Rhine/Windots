-- Initialize Configuration
local wezterm = require("wezterm")
local config = wezterm.config_builder()
local opacity = 0.5
local transparent_bg = "rgba(22, 24, 26, " .. opacity .. ")"

--- Get the current operating system
-- @return "windows"| "linux" | "macos"
local function get_os()
    local bin_format = package.cpath:match("%p[\\|/]?%p(%a+)")
    if bin_format == "dll" then
        return "windows"
    elseif bin_format == "so" then
        return "linux"
    elseif bin_format == "dylib" then
        return "macos"
    end
end

local host_os = get_os()

-- Font Configuration
local emoji_font = "Segoe UI Emoji"
config.font = wezterm.font_with_fallback({
    {
        family = "FiraCode Nerd Font",
        style = "Normal",
        weight = "Regular",
        stretch = "Normal",
        harfbuzz_features = firacode_features,
    },
    emoji_font,
})
config.font_size = 10

-- Color Configuration
config.colors = require("cyberdream")
config.force_reverse_video_cursor = true

-- Window Configuration
config.initial_rows = 45
config.initial_cols = 180
-- Remove full path from window title and set a custom title
wezterm.on("format-window-title", function(tab, pane, tabs, panes, config)
    local index = string.format("%02d", tab.tab_index + 1) -- Format as 01, 02, etc.
    local title = "⚡ WɞzŦɞɾɱ - " .. index .. " ⚡"  -- Add some ASCII style

    return title
end)


-- Customize window decorations (remove unnecessary elements)
-- config.window_decorations = "TITLE | RESIZE"
config.window_decorations = 'INTEGRATED_BUTTONS|RESIZE'
config.window_background_opacity = opacity
config.window_background_image = (os.getenv("WEZTERM_CONFIG_FILE") or ""):gsub("wezterm.lua", "bg-blurred.png")
config.window_close_confirmation = "NeverPrompt"
config.win32_system_backdrop = "Acrylic"

-- Performance Settings
config.max_fps = 144
config.animation_fps = 60
config.cursor_blink_rate = 250

-- Tab Bar Configuration
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false
config.show_tab_index_in_tab_bar = true
config.use_fancy_tab_bar = true
config.tab_bar_at_bottom = false
config.colors.tab_bar = {
    background = transparent_bg,
    new_tab = { fg_color = config.colors.background, bg_color = config.colors.brights[6] },
    new_tab_hover = { fg_color = config.colors.background, bg_color = config.colors.foreground },
}

function set_background(config, is_fullscreen)
  if is_fullscreen then
    config.window_background_opacity = nil
    config.background = {
      {
        source = {
          File = wezterm.home_dir .. '/.config/background.jpg',
        },
        attachment = { Parallax = 0.1 },
        repeat_y = 'Mirror',
        horizontal_align = 'Center',
        opacity = 0.4,
        hsb = {
          hue = 1.0,
          saturation = 0.95,
          brightness = 0.5,
        },
      },
    }
  else
    config.window_background_opacity = 0.85
    config.background = nil
  end
end


local TITLEBAR_COLOR = '#333333'
config.window_frame = {
  font = wezterm.font { family = 'FiraCode Nerd Font', weight = 'Regular' },
  font_size = 10.0,
  active_titlebar_bg = TITLEBAR_COLOR,
  inactive_titlebar_bg = TITLEBAR_COLOR,
}

wezterm.on('update-status', function(window, pane)
  local cells = {}

  -- **Current Directory**
  local hostname = wezterm.hostname()
  local cwd_uri = pane:get_current_working_dir()
  if cwd_uri and cwd_uri.host then
    hostname = cwd_uri.host
  end
  table.insert(cells, '  ' .. hostname) 
  
  -- **Git Branch**
  local git_branch = ""
  local success, stdout, _ = wezterm.run_child_process({ "pwsh", "-NoProfile", "-Command", "git rev-parse --abbrev-ref HEAD 2>$null" })
  if success and stdout and stdout ~= "" then
    git_branch = ' ' .. stdout:gsub("\n", "") -- Git branch icon
    table.insert(cells, git_branch)
  end

  -- **Current Time (12-hour format)**
  local date_time = wezterm.strftime(' %a %b %-d %I:%M %p') -- Date & Time with 12-hour format
  table.insert(cells, date_time)

  -- **Battery Status**
  local batt_icons = {' ', ' ', ' ', ' ', ' '}
  for _, b in ipairs(wezterm.battery_info()) do
    local curr_batt_icon = batt_icons[math.ceil(b.state_of_charge * #batt_icons)]
    table.insert(cells, string.format('%s %.0f%%', curr_batt_icon, b.state_of_charge * 100))
  end

  -- **Detect Current Shell**
  local shell_icon = "" -- Default: Bash icon
  local shell = pane:get_foreground_process_name() or ""

  if shell:match("pwsh") then
    shell_icon = " " -- PowerShell icon
  elseif shell:match("cmd.exe") then
    shell_icon = " " -- CMD icon
  elseif shell:match("zsh") then
    shell_icon = " " -- Zsh icon
  elseif shell:match("fish") then
    shell_icon = "󰈺 " -- Fish shell icon
  end
  table.insert(cells, shell_icon)

  -- **Keyboard Layout**
  table.insert(cells, '  ENG')

  -- **Apply Colors**
  local text_fg = '#c0c0c0'
 local colors = {
  '#333333', '#7c5295', '#663a82', '#52307c', '#9c1361', '#6c1361'
}

  local elements = {}
  while #cells > 0 and #colors > 1 do
    local text = table.remove(cells, 1)
    local prev_color = table.remove(colors, 1)
    local curr_color = colors[1]

    table.insert(elements, { Background = { Color = prev_color } })
    table.insert(elements, { Foreground = { Color = curr_color } })
    table.insert(elements, { Text = '' })
    table.insert(elements, { Background = { Color = curr_color } })
    table.insert(elements, { Foreground = { Color = text_fg } })
    table.insert(elements, { Text = ' ' .. text .. ' ' })
  end

  window:set_right_status(wezterm.format(elements))
end)


local tabs_settings = {}  -- Define the table first

function tabs_settings.apply_to_config(config)
    config.use_fancy_tab_bar = true
    config.show_new_tab_button_in_tab_bar = true
    config.tab_and_split_indices_are_zero_based = false
    local LEFT_END = utf8.char(0xE0B6)
    local RIGHT_END = utf8.char(0xE0B4)
    local active_tab_bg_color = '#FFA066'
    local inactive_tab_text_color = '#526F76'
    local active_tab_fg_color = '#22222B'
    local inactive_tab_bg_color = '#22222B'

    local function tab_title(tab_info)
        local title = tab_info.tab_title
        if title and #title > 0 then
            return title
        end
        return tab_info.active_pane.title
    end

    wezterm.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)
        local title = tab_title(tab)
        title = wezterm.truncate_right(title, max_width - 2)

        local main_bg_color = '#22222B'
        local background = '#22222B'
        local tab_icon_inactive = '#495267'
        local tab_icon_inactive_icon = wezterm.nerdfonts.md_ghost_off_outline
        local tab_icon_active_icon = wezterm.nerdfonts.md_ghost
        local icon_text = ''
        local tab_icon_color = ''
        local tab_text_color = ''
        local tab_background_color = ''

        if tab.is_active then
            tab_icon_color = active_tab_fg_color
            tab_text_color = active_tab_fg_color
            tab_background_color = active_tab_bg_color
            icon_text = tab_icon_active_icon
        else
            tab_icon_color = tab_icon_inactive
            tab_text_color = inactive_tab_text_color
            icon_text = tab_icon_inactive_icon
            tab_background_color = inactive_tab_bg_color
        end

        return {
            { Background = { Color = main_bg_color } },
            { Foreground = { Color = tab_background_color } },
            { Text = LEFT_END },
            { Background = { Color = tab_background_color } },
            { Foreground = { Color = tab_icon_color } },
            { Text = ' ' .. icon_text .. ' ' },
            { Background = { Color = tab_background_color } },
            { Foreground = { Color = tab_text_color } },
            { Text = title .. '  ' },
            { Background = { Color = background } },
            { Foreground = { Color = tab_background_color } },
            { Text = RIGHT_END },
        }
    end)
end


tabs_settings.apply_to_config(config)

-- Tab Formatting
-- wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
--     local title = tab.active_pane.title
    
--     -- Truncate long titles
--     if #title > 20 then
--         title = title:sub(1, 17) .. "..."
--     end
    
--     -- Color configuration
--     local background = config.colors.brights[1]  -- Inactive tab background
--     local foreground = config.colors.foreground  -- Inactive tab text
    
--     -- Active tab styling
--     if tab.is_active then
--         background = config.colors.brights[4]  -- More vibrant active tab color
--         foreground = config.colors.background  -- Contrasting text color
--     elseif hover then
--         background = config.colors.brights[2]  -- Hover state color
--         foreground = config.colors.foreground
--     end
    
--     -- Custom tab style with nice separators
--     return {
--         { Background = { Color = background } },
--         { Foreground = { Color = foreground } },
--         { Text = " " .. title .. " " },  -- Add some padding
--     }
-- end)

-- Tab Bar Style
config.colors.tab_bar = {
    background = transparent_bg,  -- Use the existing transparent background
    
    -- Styling for new tab button
    new_tab = { 
        bg_color = config.colors.brights[3], 
        fg_color = config.colors.background 
    },
    new_tab_hover = { 
        bg_color = config.colors.foreground, 
        fg_color = config.colors.background 
    },
}

-- Keybindings
config.keys = {
    -- Existing paste shortcut
    { key = "v", mods = "CTRL", action = wezterm.action({ PasteFrom = "Clipboard" }) },
    
    -- Open new tab at current working directory
    { key = "d", mods = "CTRL", action = wezterm.action({ SpawnTab = "CurrentPaneDomain" }) },
    
    -- OS-dependent quit/close action
    { 
        key = "q", 
        mods = "CTRL", 
        action = wezterm.action_callback(function(window, pane)
            if host_os == "macos" then
                -- For macOS, use QuitApplication
                window:perform_action(wezterm.action.QuitApplication, pane)
            else
                -- For Windows and Linux, close the window
                window:perform_action(wezterm.action.CloseCurrentTab{confirm=false}, pane)
            end
        end)
    },
    
    { 
        key = "m", 
        mods = "CTRL", 
        action = wezterm.action_callback(function(window, pane)
            window:perform_action(wezterm.action.Hide, pane)
        end) 
    },
}
-- Default Shell Configuration
config.default_prog = { "pwsh", "-NoLogo" }

-- OS-Specific Overrides
if host_os == "linux" then
    emoji_font = "Noto Color Emoji"
    config.default_prog = { "zsh" }
    config.front_end = "WebGpu"
    config.window_background_image = os.getenv("HOME") .. "/.config/wezterm/bg-blurred.png"
    config.window_decorations = nil -- use system decorations
end

return config
