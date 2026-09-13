------------------------------------------------------------
-- File:
--     hyprland.lua
--
-- Purpose:
--     Main Hyprland window manager configuration. Defines
--     monitors, appearance, animations, input, keybinds,
--     window rules, and autostart applications.
--
-- Location:
--     ~/.config/hypr/hyprland.lua
--
-- Used by:
--     Hyprland (loaded automatically on startup)
--
-- Dependencies:
--     Hyprland Lua config API (hl.*)
--     Waybar (launched via autostart)
--     kitty (default terminal)
--     dolphin (default file manager)
--     rofi (default menu)
--
-- Autostart:
--     Launches Waybar with: waybar &
--
-- Keybinds:
--     SUPER+Q      -> kitty (terminal)
--     SUPER+C      -> close window
--     SUPER+E      -> dolphin (file manager)
--     SUPER+V      -> toggle float
--     SUPER+R      -> hyprlauncher (menu)
--     ALT+Space    -> rofi launcher
--     SUPER+1-9    -> switch workspace
--     SUPER+1-9    -> switch workspace
--     SUPER+SHIFT+1-9 -> move window to workspace
--     ALT+TAB      -> toggle special workspace
--     XF86 keys    -> volume, brightness, media controls
--
-- Author:
--     Auto documented (2026-07-15)
------------------------------------------------------------


------------------
---- MONITORS ----
------------------

-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = "auto",
})

hl.monitor({
    output   = "DP-3",
    mode     = "1920x1080@180",
    position = "auto",
    scale    = "auto",
})


---------------------
---- MY PROGRAMS ----
---------------------

-- Set programs that you use
local terminal    = "kitty"
local fileManager = "kitty -e yazi"
local menu        = "rofi"


-------------------
---- AUTOSTART ----
-------------------

-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

-- Autostart necessary processes (like notifications daemons, status bars, etc.)
hl.on("hyprland.start", function ()
  local home = os.getenv("HOME")
  local wall_img = home .. "/.config/quickshell/background.jpg"

  -- Wrap the path in quotes to handle spaces and spawn swaybg cleanly
  hl.exec_cmd("swaybg -i \"" .. wall_img .. "\" -m fill &")
  
  hl.exec_cmd("unset QT_STYLE_OVERRIDE; unset QT_QPA_PLATFORMTHEME; qs -p " .. home .. "/.config/quickshell/shell.qml &")
  hl.exec_cmd("xbindkeys -f " .. home .. "/.xbindkeysrc &")
end)


-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("XDG_DATA_DIRS", "/usr/local/share:/usr/share:$HOME/.local/share")
hl.env("QT_QPA_PLATFORMTHEME", "kde")
hl.env("QT_STYLE_OVERRIDE", "breeze6")


-----------------------
----- PERMISSIONS -----
-----------------------

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Permissions/
-- Please note permission changes here require a Hyprland restart and are not applied on-the-fly
-- for security reasons

-- hl.config({
--   ecosystem = {
--     enforce_permissions = true,
--   },
-- })

-- hl.permission("/usr/(bin|local/bin)/grim", "screencopy", "allow")
-- hl.permission("/usr/(lib|libexec|lib64)/xdg-desktop-portal-hyprland", "screencopy", "allow")
-- hl.permission("/usr/(bin|local/bin)/hyprpm", "plugin", "allow")


-----------------------
---- LOOK AND FEEL ----
-----------------------

-- Refer to https://wiki.hypr.land/Configuring/Basics/Variables/
-- =========================================================================
-- 1. DE GECORRIGEERDE CUSTOM LAYOUT (Met box tabel `{}`)
-- =========================================================================
-- =========================================================================
-- 1. ULTIEME CUSTOM LAYOUT (Met Focus & Swap Matrix)
-- =========================================================================
hl.layout.register("quad_grid", {
    recalculate = function(ctx)
        local n = #ctx.targets
        if n == 0 then return end

        local area = ctx.area
        local half_w = math.floor(area.w / 2)
        local half_h = math.floor(area.h / 2)

        for i, target in ipairs(ctx.targets) do
            if n == 1 then
                target:place({ x = area.x, y = area.y, w = area.w, h = area.h })
            elseif n == 2 then
                if i == 1 then
                    target:place({ x = area.x, y = area.y, w = half_w, h = area.h })
                elseif i == 2 then
                    target:place({ x = area.x + half_w, y = area.y, w = half_w, h = area.h })
                end
            elseif n == 3 then
                if i == 1 then
                    target:place({ x = area.x, y = area.y, w = half_w, h = area.h })
                elseif i == 2 then
                    target:place({ x = area.x + half_w, y = area.y, w = half_w, h = half_h })
                elseif i == 3 then
                    target:place({ x = area.x + half_w, y = area.y + half_h, w = half_w, h = half_h })
                end
            elseif n >= 4 then
                if i == 1 then
                    target:place({ x = area.x, y = area.y, w = half_w, h = half_h })
                elseif i == 2 then
                    target:place({ x = area.x + half_w, y = area.y, w = half_w, h = half_h })
                elseif i == 3 then
                    target:place({ x = area.x, y = area.y + half_h, w = half_w, h = half_h })
                elseif i == 4 then
                    target:place({ x = area.x + half_w, y = area.y + half_h, w = half_w, h = half_h })
                else
                    target.window:set_floating(true)
                end
            end
        end
    end,

    layout_msg = function(ctx, msg, param)
        -- Accepteer zowel "focus" als "swap" commando's via layoutmsg
        local is_swap = (msg == "swap")
        if msg ~= "focus" and msg ~= "swap" then return false end
        
        local n = #ctx.targets
        if n <= 1 then return false end

        local active_win = hl.get_active_window()
        local current_idx = nil
        for i, target in ipairs(ctx.targets) do
            if target.window == active_win then
                current_idx = i
                break
            end
        end
        if not current_idx then return false end

        local target_idx = nil

        -- Navigatie Logica
        if n == 2 then
            if param == "l" or param == "r" then target_idx = (current_idx == 1) and 2 or 1 end
        elseif n == 3 then
            if current_idx == 1 and param == "r" then target_idx = 2
            elseif current_idx == 2 then
                if param == "l" then target_idx = 1
                elseif param == "d" then target_idx = 3 
                end
            elseif current_idx == 3 then
                if param == "l" then target_idx = 1
                elseif param == "u" then target_idx = 2 
                end
            end
        elseif n >= 4 then
            if current_idx == 1 then
                if param == "r" then target_idx = 2
                elseif param == "d" then target_idx = 3
                end
            elseif current_idx == 2 then
                if param == "l" then target_idx = 1
                elseif param == "d" then target_idx = 4
                end
            elseif current_idx == 3 then
                if param == "u" then target_idx = 1
                elseif param == "r" then target_idx = 4
                end
            elseif current_idx == 4 then
                if param == "u" then target_idx = 2
                elseif param == "l" then target_idx = 3
                end
            end
        end

        -- Voer de actie uit (Focus OF Fysieke Swap)
        if target_idx and ctx.targets[target_idx] then
            if is_swap then
                -- Wissel de posities om in de layout boomstructuur
                local temp = ctx.targets[current_idx].window
                ctx.targets[current_idx].window = ctx.targets[target_idx].window
                ctx.targets[target_idx].window = temp
                -- Herbereken direct de posities op het scherm
                ctx:recalculate()
            else
                -- Focus het doelvenster
                ctx.targets[target_idx].window:focus()
            end
            return true
        end

        return false
    end
})

-- =========================================================================
-- 2. APPLY THE CONFIGURATION
-- =========================================================================
hl.config({
    general = {
        gaps_in = 7,
        gaps_out = 10,

        border_size = 1,

        col = {
            active_border = {
                colors = {
                    "rgba(3FD0DCff)",
                    "rgba(2BB1BBff)",
                    "rgba(219BA4cc)",
                    "rgba(3FD0DCff)"
                },
                angle = 45
            },
            inactive_border = "rgba(12424C88)",
        },

        resize_on_border = true,
        allow_tearing = false,
        layout = "dwindle",
    },
    
    scrolling = {
        fullscreen_on_one_column = true,
        column_width = 0.5,
        direction = "right",
    },

    dwindle = {
        force_split = 2
    },

    decoration = {
        rounding       = 18,
        rounding_power = 2,

        active_opacity   = 1,
        inactive_opacity = 1,

        shadow = {
            enabled      = true,
            range        = 18,
            render_power = 3,
            color        = 0xcc0d1640,
        },

        blur = {
            enabled   = true,
            size      = 6,
            passes    = 3,
            vibrancy  = 0.12,
            vibrancy_darkness = 0.15,
            xray      = true,
        },
    },

    animations = {
        enabled = true,
    },
})


-- Default curves and animations, see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/w
hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1}    } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1}    } })
hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1}       } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1}    } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1}     } })
hl.curve("morph",          { type = "bezier", points = { {0.34, 1.56}, {0.64, 1}    } })

-- Default springs
hl.curve("easy",           { type = "spring", mass = 1, stiffness = 71.2633, dampening = 15.8273644 })
hl.curve("springy",        { type = "spring", mass = 0.8, stiffness = 120, dampening = 14 })

hl.animation({ leaf = "global",        enabled = true,  speed = 10,   bezier = "default" })
hl.animation({ leaf = "border",        enabled = true,  speed = 5.39, bezier = "morph" })
hl.animation({ leaf = "windows",       enabled = true,  speed = 4.79, spring = "springy" })
hl.animation({ leaf = "windowsIn",     enabled = true,  speed = 4.1,  spring = "springy",     style = "popin 90%" })
hl.animation({ leaf = "windowsOut",    enabled = true,  speed = 1.49, bezier = "linear",      style = "popin 90%" })
hl.animation({ leaf = "fadeIn",        enabled = true,  speed = 0.1, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",       enabled = true,  speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade",          enabled = true,  speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers",        enabled = true,  speed = 3.81, bezier = "morph" })
hl.animation({ leaf = "layersIn",      enabled = true,  speed = 6,    bezier = "morph",     style = "slide" })
hl.animation({ leaf = "layersOut",     enabled = true,  speed = 4,    bezier = "morph",     style = "slide" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true,  speed = 0.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true,  speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces",    enabled = true,  speed = 1.94, bezier = "almostLinear", style = "slidefade 25%" })
hl.animation({ leaf = "workspacesIn",  enabled = true,  speed = 1.21, bezier = "almostLinear", style = "slidefade 25%" })
hl.animation({ leaf = "workspacesOut", enabled = true,  speed = 1.94, bezier = "almostLinear", style = "slidefade 25%" })
hl.animation({ leaf = "zoomFactor",    enabled = true,  speed = 7,    bezier = "quick" })

-- Ref https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/
-- "Smart gaps" / "No gaps when only"
-- uncomment all if you wish to use that.
-- hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })
-- hl.workspace_rule({ workspace = "f[1]",   gaps_out = 0, gaps_in = 0 })
-- hl.window_rule({
--     name  = "no-gaps-wtv1",
--     match = { float = false, workspace = "w[tv1]" },
--     border_size = 0,
--     rounding    = 0,
-- })
-- hl.window_rule({
--     name  = "no-gaps-f1",
--     match = { float = false, workspace = "f[1]" },
--     border_size = 0,
--     rounding    = 0,
-- })

-- See https://wiki.hypr.land/Configuring/Layouts/Dwindle-Layout/ for more
hl.config({
    dwindle = {
        preserve_split = true, -- You probably want this
    },
})

-- See https://wiki.hypr.land/Configuring/Layouts/Master-Layout/ for more
hl.config({
    master = {
        new_status = "master",
    },
})

-- See https://wiki.hypr.land/Configuring/Layouts/Scrolling-Layout/ for more
hl.config({
    scrolling = {
        fullscreen_on_one_column = true,
    },
})

----------------
----  MISC  ----
----------------

hl.config({
    misc = {
        force_default_wallpaper = -1,    -- Set to 0 or 1 to disable the anime mascot wallpapers
        disable_hyprland_logo   = false, -- If true disables the random hyprland logo / anime girl background. :(
    },
})


---------------
---- INPUT ----
---------------

hl.config({
    input = {
        kb_layout  = "be",
        kb_variant = "",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",

        follow_mouse = 1,

        accel_profile = "flat",

        sensitivity = 0, -- -1.0 - 1.0, 0 means no modification.

        touchpad = {
            natural_scroll = true,
        },
    },
})

hl.gesture({
    fingers = 7,
    direction = "horizontal",
    action = "workspace"
})


-- Example per-device config
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Devices/ for more
hl.device({
    name        = "epic-mouse-v1",
    sensitivity = -0.5,
})


---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "SUPER" -- Sets "Windows" key as main modifier

-- Take a section screenshot and copy it to clipboard on PrintScreen
hl.bind("Print", hl.dsp.exec_cmd("grim -g \"$(slurp)\" - | wl-copy"))

-- Example binds, see https://wiki.hypr.land/Configuring/Basics/Binds/ for more
hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(terminal))
local closeWindowBind = hl.bind(mainMod .. " + C", hl.dsp.window.close())
-- closeWindowBind:set_enabled(false)
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(menu))
hl.bind("ALT + Space", hl.dsp.exec_cmd('XDG_DATA_DIRS="$HOME/.nix-profile/share:/run/current-system/sw/share:$XDG_DATA_DIRS" rofi -show drun'))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + comma", hl.dsp.exec_cmd("touch /tmp/qs-settings"))

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

hl.bind(mainMod .. " + CTRL + J",  hl.dsp.window.move({ direction = "l" }))
hl.bind(mainMod .. " + CTRL + L", hl.dsp.window.move({ direction = "r" }))
hl.bind(mainMod .. " + CTRL + I",    hl.dsp.window.move({ direction = "u" }))
hl.bind(mainMod .. " + CTRL + K",  hl.dsp.window.move({ direction = "d" }))

-- Custom Pijltjestoetsen (Alt + JKLI) met lege modifier tabel
hl.bind("ALT + J", hl.dsp.send_shortcut({ mods = "", key = "left", target = "activewindow" }), { repeating = true })
hl.bind("ALT + K", hl.dsp.send_shortcut({ mods = "", key = "down", target = "activewindow" }), { repeating = true })
hl.bind("ALT + L", hl.dsp.send_shortcut({ mods = "", key = "right", target = "activewindow" }), { repeating = true })
hl.bind("ALT + I", hl.dsp.send_shortcut({ mods = "", key = "up", target = "activewindow" }), { repeating = true })

-- Move focus with Super + IJKL
hl.bind(mainMod .. " + I", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "down" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }))

-- Lock screen (SUPER + SHIFT + X) -> triggers hyprlock system password lock
hl.bind("SUPER + SHIFT + X", hl.dsp.exec_cmd("hyprlock"))

-- Next workspace ID, spawns empty workspace if needed (SUPER + SHIFT + L)
hl.bind("SUPER + SHIFT + L", hl.dsp.focus({ workspace = "+1" }))

-- Previous workspace ID (SUPER + SHIFT + J)
hl.bind("SUPER + SHIFT + J", hl.dsp.focus({ workspace = "-1" }))

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
--for i = 1, 10 do
    --local key = i % 10 -- 10 maps to key 0
    --hl.bind(mainMod .. " + " .. key,             hl.dsp.focus({ workspace = i}))
    --hl.bind(mainMod .. " + SHIFT + " .. key,     hl.dsp.window.move({ workspace = i }))
--end

hl.bind("SUPER + SHIFT + ALT + L", hl.dsp.window.move({ workspace = "+1" }))
hl.bind("SUPER + SHIFT + ALT + J", hl.dsp.window.move({ workspace = "-1" }))

-- Example special workspace (scratchpad)
hl.bind("ALT + TAB",hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Modern Lua API format
-- Toggle standard full screen (SUPER + F)
hl.bind("SUPER + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))

-- Or if you prefer Maximized mode (keeps gaps & bar visible):
-- hl.bind("SUPER + F", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))

-- Laptop multimedia keys for volume and LCD brightness
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  { locked = true, repeating = true })

-- Requires playerctl
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })


--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- and https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

-- Example window rules that are useful

local suppressMaximizeRule = hl.window_rule({
    -- Ignore maximize requests from all apps. You'll probably like this.
    name  = "suppress-maximize-events",
    match = { class = ".*" },

    suppress_event = "maximize",
})
-- suppressMaximizeRule:set_enabled(false)

hl.window_rule({
    -- Fix some dragging issues with XWayland
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },

    no_focus = true,
})

-- Layer rules also return a handle.
-- local overlayLayerRule = hl.layer_rule({
--     name  = "no-anim-overlay",
--     match = { namespace = "^my-overlay$" },
--     no_anim = true,
-- })
-- overlayLayerRule:set_enabled(false)

-- Hyprland-run windowrule
hl.window_rule({
    name  = "move-hyprland-run",
    match = { class = "hyprland-run" },

    move  = "20 monitor_h-120",
    float = true,
})

-- Rofi launcher (Modern Blur style)
hl.layer_rule({
    match        = { namespace = "^rofi$" },
    blur         = true,
    ignore_alpha = 0.1,
})

--- Match VSCodium window class
hl.window_rule({
    opacity = "0.92 0.90",
    match = { class = "^(codium|codium-url-handler|VSCodium|code)$" }
})

-- Hyprland Gaussian Blur
decoration = {
    blur = {
        enabled = true,
        size = 10,
        passes = 3,
        new_optimizations = true,
        ignore_opacity = true,
    },
}
-- Nothing OS waybar popups: float + anchor under the bar (right side), no focus steal
for _, pop in ipairs({ "waybar_calendar", "waybar_wifi", "waybar_bluetooth", "waybar_power" }) do
  hl.window_rule({
    name  = "float-" .. pop,
    match = { class = "^" .. pop .. "\\.py$" },

    float            = true,
    move             = { "monitor_w - window_w - 12", "58" },
    no_focus         = true,
    no_initial_focus = true,
    stay_focused     = true,
  })
end





-------------------------------
---- NORD SETTINGS OVERRIDES ---
--------------------------------

-- Apply persisted keyword overrides from Nord Settings panel
hl.on("hyprland.start", function()
  hl.exec_cmd([==[sh -c 'while IFS= read -r line; do case "$line" in "#"*|"") continue;; esac; if [[ "$line" == "eval|"* ]]; then hyprctl eval "${line#eval|}" 2>/dev/null; else hyprctl keyword "$line" 2>/dev/null; fi; done < ~/.config/hypr/overrides.conf']==])
  -- Firefox blur
  hl.exec_cmd("windowrule = blur,firefox")
  hl.exec_cmd("windowrule = blur,dolphin")
  hl.exec_cmd("windowrule = blur,kitty")
end)
