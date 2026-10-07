function cat(args)
    return table.concat(args, " + ")
end

local shell    = "dms"

---- ARGS ----
local mainMod  = "SUPER"
local terminal = "ghostty"
local menu
if shell == "noctalia" then
    menu = "noctalia-shell ipc call launcher toggle"
elseif shell == "dms" then
    menu = "dms ipc launcher toggle"
end

local hostname = io.popen("hostname"):read("*l")


---- MONITORS ----
local configs = {
    ["nix-machine"] = {
        {
            output = "desc:Microstep G274QPX CC2HA03901674",
            mode = "2560x1440@240",
            position = "0x0",
            scale = 1,
            bitdepth = 10,
            transform = 0,
        },
    },

    ["kitayoza"] = {
        {
            output   = "eDP-1",
            mode     = "2880x1800@120",
            scale    = 1.5,
            bitdepth = 10,
        },
    },
}

for _, cfg in ipairs(configs[hostname] or {}) do
    hl.monitor(cfg)
end


---- AUTOSTART ----
hl.on("hyprland.start", function()
    if shell == "noctalia" then
        hl.exec_cmd("noctalia-shell")
    elseif shell == "dms" then
        hl.exec_cmd("dms run")
    end
    hl.exec_cmd("noctalia-shell")
    hl.exec_cmd("nm-applet")
    hl.exec_cmd("blueman-applet")
end)


---- ENVIRONMENT VARIABLES ----
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")


---- ANIMATIONS -------
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("default", { type = "bezier", points = { { 0.35, 0.15 }, { 0.25, 1 } } })
hl.curve("easeIn", { type = "bezier", points = { { 0.3, 0.82 }, { 0.42, 1 } } })
hl.curve("easeOut", { type = "bezier", points = { { 0, 0 }, { 0.58, 1 } } })

hl.animation({ leaf = "windows", enabled = true, speed = 2, bezier = "default", style = "popin" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 2, bezier = "default", style = "popin" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 3, bezier = "default", style = "popin" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 2, bezier = "default", style = "popin" })

hl.animation({ leaf = "layersIn", enabled = true, speed = 3, bezier = "default", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 3, bezier = "default", style = "fade" })

hl.animation({ leaf = "fade", enabled = false, speed = 10, bezier = "default" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 5, bezier = "default" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 2, bezier = "default" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 5, bezier = "default" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 2, bezier = "default" })

hl.animation({ leaf = "border", enabled = true, speed = 1, bezier = "default" })
hl.animation({ leaf = "borderangle", enabled = false, speed = 30, bezier = "default", style = "loop" })

hl.animation({ leaf = "workspacesIn", enabled = true, speed = 2, bezier = "default", style = "slidevert" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 2, bezier = "default", style = "slidevert" })
hl.animation({ leaf = "specialWorkspaceIn", enabled = true, speed = 3, bezier = "default", style = "slidefadevert" })
hl.animation({ leaf = "specialWorkspaceOut", enabled = true, speed = 3, bezier = "default", style = "slidefadevert" })


---- WINDOW SIZE TOGGLE ----
local window_sizes = { 1, 0.5, 0.33 }
local window_size_state = {}

hl.bind(cat({ mainMod, "B" }), function()
    local win = hl.get_active_window()
    if not win then
        return
    end

    local addr = win.address
    if not addr then
        return
    end

    local idx = ((window_size_state[addr] or 1) % #window_sizes) + 1
    window_size_state[addr] = idx

    hl.dispatch(
        hl.dsp.layout(
            "colresize -conf"
        )
    )
end)


---- WORKSPACE PADDING ----
local function compute_horizontal_gap(coef)
    local cfg = configs[hostname]
    if not cfg or #cfg == 0 then return 0 end
    local mon = cfg[1]
    local mode = mon.mode or "1920"
    local scale = mon.scale or 1
    local w = tonumber(mode:match("^(%d+)")) or 1920
    return math.floor(w / scale * coef) or 0
end
local horizontal_gap = compute_horizontal_gap(0.04)


---- CONFIG ----
hl.config({
    general = {
        gaps_in = {
            top = 7,
            bottom = 7,
            left = 10,
            right = 10,
        },
        gaps_out = {
            top = 10,
            bottom = 10,
            left = horizontal_gap,
            right = horizontal_gap,
        },
        border_size = 1,
        allow_tearing = true,
        layout = "scrolling",
    },

    decoration = {
        rounding = 5,
        rounding_power = 2,
        active_opacity = 1.0,
        inactive_opacity = 1.0,
        fullscreen_opacity = 1.0,
        shadow = {
            enabled = true,
            range = 50,
            render_power = 5,
            offset = { 1, 1 },
            color = "#06060677",
        },
        blur = {
            enabled = true,
            size = 7,
            passes = 3,
            ignore_opacity = true,
            new_optimizations = true,
            xray = false,
        },
    },

    scrolling = {
        fullscreen_on_one_column = true,
        column_width = 1,
        focus_fit_method = 1,
        follow_min_visible = 1,
    },

    dwindle = { preserve_split = true, smart_split = false },
    xwayland = { force_zero_scaling = true },
    misc = { force_default_wallpaper = -1, disable_hyprland_logo = false, vrr = true },

    input = {
        kb_layout = "us, ru",
        kb_options = "grp:alt_shift_toggle",
        follow_mouse = 1,
        sensitivity = 0,
        repeat_delay = 300,
        repeat_rate = 40,
        force_no_accel = true,
        touchpad = { natural_scroll = false },
    },

    cursor = {
        hide_on_key_press = true,
    },

    gestures = {
        workspace_swipe_invert = false,
        workspace_swipe_cancel_ratio = 0.1,
    }
})


---- KEYBINDINGS ----
if shell == "noctalia" then
    hl.bind(cat({ mainMod, "CTRL + l" }), hl.dsp.exec_cmd("noctalia-shell ipc call sessionMenu lock"))
elseif shell == "dms" then
    hl.bind(cat({ mainMod, "CTRL + l" }), hl.dsp.exec_cmd("dms ipc lock lock"))
    hl.bind(cat({ mainMod, "v" }), hl.dsp.exec_cmd("dms ipc clipboard toggle"))
end

-- Apps
hl.bind(cat({ mainMod, "Return" }), hl.dsp.exec_cmd(terminal))
hl.bind(cat({ mainMod, "Q" }), hl.dsp.window.close())
hl.bind(cat({ mainMod, "space" }), hl.dsp.exec_cmd(menu))

hl.bind(cat({ mainMod, "F" }), hl.dsp.window.float({ action = "toggle" }))
hl.bind(cat({ mainMod, "P" }), hl.dsp.window.pseudo())
hl.bind(cat({ mainMod, "W" }), hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))
-- hl.bind(mainMod .. " + G", hl.dsp.layout("togglesplit"))
hl.bind(cat({ mainMod, "Delete" }), hl.dsp.exit())

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag())
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize())

-- Move Focus
hl.bind(cat({ mainMod, "left" }), hl.dsp.focus({ direction = "left" }))
hl.bind(cat({ mainMod, "right" }), hl.dsp.focus({ direction = "right" }))
hl.bind(cat({ mainMod, "up" }), hl.dsp.focus({ direction = "up" }))
hl.bind(cat({ mainMod, "down" }), hl.dsp.focus({ direction = "down" }))
hl.bind(cat({ mainMod, "h" }), hl.dsp.focus({ direction = "left" }))
hl.bind(cat({ mainMod, "l" }), hl.dsp.focus({ direction = "right" }))
hl.bind(cat({ mainMod, "k" }), hl.dsp.focus({ direction = "up" }))
hl.bind(cat({ mainMod, "j" }), hl.dsp.focus({ direction = "down" }))

-- Move Window
hl.bind(cat({ mainMod, "SHIFT", "h" }), hl.dsp.window.move({ direction = "left" }))
hl.bind(cat({ mainMod, "SHIFT", "l" }), hl.dsp.window.move({ direction = "right" }))
hl.bind(cat({ mainMod, "SHIFT", "k" }), hl.dsp.window.move({ direction = "up" }))
hl.bind(cat({ mainMod, "SHIFT", "j" }), hl.dsp.window.move({ direction = "down" }))
hl.bind("F11", hl.dsp.window.fullscreen("fullscreen", "toggle"))

-- Resize
-- hl.bind(cat({ mainMod, "ALT", "h" }), hl.dsp.window.resize({ x = -50, y = 0, relative = true }))
-- hl.bind(cat({ mainMod, "ALT", "l" }), hl.dsp.window.resize({ x = 50, y = 0, relative = true }))
hl.bind(cat({ mainMod, "ALT", "l" }), hl.dsp.layout("colresize +0.1"))
hl.bind(cat({ mainMod, "ALT", "h" }), hl.dsp.layout("colresize -0.1"))
hl.bind(cat({ mainMod, "ALT", "j" }), hl.dsp.window.resize({ x = 0, y = 50, relative = true }))
hl.bind(cat({ mainMod, "ALT", "k" }), hl.dsp.window.resize({ x = 0, y = -50, relative = true }))

-- Workspaces
hl.bind(cat({ mainMod, "SHIFT", "S" }), hl.dsp.window.move({ workspace = "special:magic" }))
hl.bind(cat({ mainMod, "S" }), hl.dsp.workspace.toggle_special("magic"))

for i = 1, 9 do
    hl.bind(cat({ mainMod, i }), hl.dsp.focus({ workspace = i }))
    hl.bind(cat({ mainMod, "SHIFT", i }), hl.dsp.window.move({ workspace = i, follow = false }))
end

-- guestures
hl.gesture({
    fingers = 3,
    direction = "vertical",
    action = "workspace"
})

hl.gesture({
    fingers = 3,
    direction = "right",
    action = function()
        hl.dispatch(hl.dsp.layout("move +col"))
    end
})

hl.gesture({
    fingers = 3,
    direction = "left",
    action = function()
        hl.dispatch(hl.dsp.layout("move -col"))
    end
})

-- Multimedia
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"),
    { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
    { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl s 10%+"), { locked = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 10%-"), { locked = true })

-- Screenshots
local focused_monitor =
'$(hyprctl monitors -j | jq -r \'.[] | select(.focused==true) | .name\')'

local shot_monitor = 'grim -o "' .. focused_monitor .. '" -'
local shot_region = 'grim -g "$(slurp)" -'

local copy = 'wl-copy --type image/png'

local satty =
    'satty --filename - --floating-hack --resize 1000x600 --early-exit ' ..
    '--copy-command "wl-copy" ' ..
    '--output-filename ~/Pictures/Screenshots/satty-$(date "+%Y%m%d-%H:%M:%S").png'

hl.bind("PRINT", hl.dsp.exec_cmd(shot_monitor .. " | " .. copy))
hl.bind("SHIFT + PRINT", hl.dsp.exec_cmd(shot_region .. " | " .. copy))

hl.bind("CTRL + PRINT", hl.dsp.exec_cmd(shot_monitor .. " | " .. satty))
hl.bind("CTRL + SHIFT + PRINT", hl.dsp.exec_cmd(shot_region .. " | " .. satty))

---- WINDOWS AND WORKSPACES ----
-- fix slurp visible selection boundary
hl.layer_rule({
    match = { namespace = "selection" },
    no_anim = true,
})

hl.window_rule({
    name = "allow-tearing",
    match = {
        class = "^.*$",
    },
    immediate = true,
})

hl.workspace_rule({ workspace = "w[tv1]", gaps_out = { left = 5 }, gaps_in = 0 })
hl.workspace_rule({ workspace = "f[1]", gaps_out = { top = 0, bottom = 0, left = 5, right = 0, }, gaps_in = 0 })
hl.window_rule({ match = { float = false, workspace = "w[tv1]" }, border_size = 0 })
hl.window_rule({ match = { float = false, workspace = "f[1]" }, border_size = 0 })
-- hl.window_rule({ match = { float = false, workspace = "w[tv1]" }, rounding = 0 })
-- hl.window_rule({ match = { float = false, workspace = "f[1]" }, rounding = 0 })

-- DMS Include Configs
require("dms.layout")
require("dms.colors")
