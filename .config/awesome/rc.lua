-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

local rofi_settings = "rofi -combi-modi window,drun,ssh -show drun -lines 5 -width 100 -padding 800 -terminal kitty"
local rofimoji_settings = "rofimoji"
-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
local lain = require("lain")


-- local battery_widget = require("battery-widget")
-- local battery = battery_widget({
-- 	ac = "AC",
-- 	adapter = "BAT0",
-- 	ac_prefix = "🔌",
-- 	battery_prefix = "🔋",
-- 	percent_colors = {
-- 		{ 25, "red" },
-- 		{ 50, "orange" },
-- 		{ 999, "green" },
-- 	},
-- 	listen = true,
-- 	timeout = 10,
-- 	widget_text = "${AC_BAT}${color_on}${percent}%${color_off}",
-- 	tooltip_text = "Battery ${state}${time_est}\nCapacity: ${capacity_percent}%",
-- 	alert_threshold = 5,
-- 	alert_timeout = 0,
-- 	alert_title = "Low battery!",
-- 	alert_text = "${AC_BAT}${time_est}",
-- })

-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
	naughty.notify({
		preset = naughty.config.presets.critical,
		title = "Oops, there were errors during startup!",
		text = awesome.startup_errors,
	})
end

-- Handle runtime errors after startup
do
	local in_error = false
	awesome.connect_signal("debug::error", function(err)
		-- Make sure we don't go into an endless error loop
		if in_error then
			return
		end
		in_error = true

		naughty.notify({
			preset = naughty.config.presets.critical,
			title = "Oops, an error happened!",
			text = tostring(err),
		})
		in_error = false
	end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init("~/.config/awesome/themes/default/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "kitty"
terminalt = "kitty"
editor = os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. editor

-- Quake terminal toggle
local quake_client = nil
client.connect_signal("manage", function(c)
	if c.instance == "QuakeDD" or c.class == "QuakeDD" then
		quake_client = c
		c.floating = true
		c.maximized = true
		c.ontop = true
		c.skip_taskbar = true
		c:connect_signal("unmanage", function()
			quake_client = nil
		end)
	end
end)

local function quake_toggle()
	for _, c in ipairs(client.get()) do
		if c.class == "Rofi" then return end
	end
	if quake_client and quake_client.valid then
		quake_client.hidden = not quake_client.hidden
		if not quake_client.hidden then
			quake_client:move_to_tag(awful.screen.focused().selected_tag)
			quake_client:raise()
			client.focus = quake_client
		else
			awful.client.focus.history.previous()
			if client.focus then
				client.focus:raise()
			end
		end
	else
		awful.spawn("kitty --class QuakeDD")
	end
end

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
	awful.layout.suit.floating,
	awful.layout.suit.tile,
	-- awful.layout.suit.tile.left,
	-- awful.layout.suit.tile.bottom,
	-- awful.layout.suit.tile.top,
	-- awful.layout.suit.fair,
	-- awful.layout.suit.fair.horizontal,
	-- awful.layout.suit.spiral,
	-- awful.layout.suit.spiral.dwindle,
	-- awful.layout.suit.max,
	-- awful.layout.suit.max.fullscreen,
	-- awful.layout.suit.magnifier,
	-- awful.layout.suit.corner.nw,
	-- awful.layout.suit.corner.ne,
	-- awful.layout.suit.corner.sw,
	-- awful.layout.suit.corner.se,
}
-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu
myawesomemenu = {
	{
		"hotkeys",
		function()
			hotkeys_popup.show_help(nil, awful.screen.focused())
		end,
	},
	{ "manual", terminal .. " -e man awesome" },
	{ "edit config", editor_cmd .. " " .. awesome.conffile },
	{ "restart", awesome.restart },
	{
		"quit",
		function()
			awesome.quit()
		end,
	},
}

mymainmenu = awful.menu({
	items = {
		{ "awesome", myawesomemenu, beautiful.awesome_icon },
		{ "open terminal", terminalt },
	},
})

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon, menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- Keyboard map indicator and switcher
mykeyboardlayout = awful.widget.keyboardlayout()

-- {{{ Wibar
-- Create a textclock widget
mytextclock = wibox.widget.textclock()

-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
	awful.button({}, 1, function(t)
		t:view_only()
	end),
	awful.button({ modkey }, 1, function(t)
		if client.focus then
			client.focus:move_to_tag(t)
		end
	end),
	awful.button({}, 3, awful.tag.viewtoggle),
	awful.button({ modkey }, 3, function(t)
		if client.focus then
			client.focus:toggle_tag(t)
		end
	end),
	awful.button({}, 4, function(t)
		awful.tag.viewnext(t.screen)
	end),
	awful.button({}, 5, function(t)
		awful.tag.viewprev(t.screen)
	end)
)

local tasklist_buttons = gears.table.join(
	awful.button({}, 1, function(c)
		if c == client.focus then
			c.minimized = true
		else
			c:emit_signal("request::activate", "tasklist", { raise = true })
		end
	end),
	awful.button({}, 3, function()
		awful.menu.client_list({ theme = { width = 250 } })
	end),
	awful.button({}, 4, function()
		awful.client.focus.byidx(1)
	end),
	awful.button({}, 5, function()
		awful.client.focus.byidx(-1)
	end)
)

-- {{{ Tag name persistence
local tag_names_file = gears.filesystem.get_cache_dir() .. "tag-names"

local function load_tag_names()
	local names = {}
	local f = io.open(tag_names_file, "r")
	if not f then return names end
	for line in f:lines() do
		local s, t, name = line:match("^(%d+)\t(%d+)\t(.*)$")
		if s and t then
			local si = tonumber(s)
			names[si] = names[si] or {}
			names[si][tonumber(t)] = name
		end
	end
	f:close()
	return names
end

local function save_tag_names()
	local f = io.open(tag_names_file, "w")
	if not f then return end
	for s in screen do
		for i, t in ipairs(s.tags) do
			if t.name and t.name ~= "" then
				f:write(string.format("%d\t%d\t%s\n", s.index, i, t.name))
			end
		end
	end
	f:close()
end

local saved_tag_names = load_tag_names()
-- }}}

-- Paint a taglist row's number square.
--   selected (current tag): accent fill + white digit
--   occupied (has clients): light fill + dark digit
--   empty:                  no fill + dim digit
-- Called from both create_callback and update_callback; the taglist library
-- triggers update_callback on tagged/untagged and on property::selected.
function paint_taglist_row(self, t, index)
	-- bg/fg drive the number square; border tracks the same state so the
	-- icon strip's outline matches whether the tag is selected/occupied.
	local bg, fg, border
	if t.selected then
		bg, fg, border = "#5fafff", "#ffffff", "#5fafff"
	elseif #t:clients() > 0 then
		bg, fg, border = "#dddddd", "#222222", "#dddddd"
	else
		bg, fg, border = nil, "#888888", "#dddddd"
	end
	local occ = self:get_children_by_id("occupancy_role")[1]
	if occ then occ.bg = bg end
	local idx = self:get_children_by_id("index_role")[1]
	if idx then
		idx.markup = string.format(
			'<span foreground="%s" weight="bold">%d</span>',
			fg, index
		)
	end

	-- Rebuild the per-client icon row. The taglist re-runs update_callback on
	-- tagged/untagged signals, so the list stays in sync as windows move.
	local clist = self:get_children_by_id("clients_role")[1]
	local count = 0
	if clist then
		clist:reset()
		for _, c in ipairs(t:clients()) do
			-- Skip the quake terminal: it floats over every tag and would
			-- pollute every row's icon strip.
			local quake = c.class == "QuakeDD" or c.instance == "QuakeDD"
			if c.icon and not quake then
				clist:add(wibox.widget({
					{
						image = c.icon,
						forced_height = 14,
						forced_width = 14,
						widget = wibox.widget.imagebox,
					},
					valign = "center",
					halign = "center",
					widget = wibox.container.place,
				}))
				count = count + 1
			end
		end
	end
	local cb = self:get_children_by_id("clients_border")[1]
	if cb then
		cb.visible = count > 0 or t.has_sound == true
		cb.shape_border_color = border
	end
end

local function set_wallpaper(s)
	-- Wallpaper
	if beautiful.wallpaper then
		local wallpaper = beautiful.wallpaper
		-- If wallpaper is a function, call it with the screen
		if type(wallpaper) == "function" then
			wallpaper = wallpaper(s)
		end
		gears.wallpaper.maximized(wallpaper, s, true)
	end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

-- {{{ Window recording
local recording_state = { active = false, pid = nil, file = nil }
local recording_indicators = {}

local function make_recording_indicator()
	local w = wibox.widget({
		{
			markup = '<span foreground="#ff3333" size="large">●</span>',
			widget = wibox.widget.textbox,
		},
		left = 6,
		right = 6,
		widget = wibox.container.margin,
		visible = false,
	})
	table.insert(recording_indicators, w)
	return w
end

local function set_recording_indicator_visible(v)
	for _, w in ipairs(recording_indicators) do
		w.visible = v
	end
end

local function start_recording()
	if recording_state.active then return end

	naughty.notify({
		title = "Record window",
		text = "Click the window to record (Esc to cancel)",
		timeout = 3,
	})

	-- xwininfo grabs the pointer with a crosshair cursor while waiting for the click.
	-- The sleep gives awesomewm time to release its keybind grab; without it
	-- xwininfo's XGrabPointer fails and the command exits immediately.
	awful.spawn.easy_async_with_shell(
		"sleep 0.3 && xwininfo | awk '/Window id:/ {print $4}'",
		function(stdout, _, _, exit_code)
			local wid = stdout:gsub("%s+", "")
			if exit_code ~= 0 or wid == "" then
				naughty.notify({ title = "Record window", text = "Cancelled" })
				return
			end

			local dir = os.getenv("HOME") .. "/recordings"
			os.execute("mkdir -p " .. dir)
			local file = dir .. "/RECORD-" .. os.date("%Y-%m-%d_%H-%M-%S") .. ".mp4"

			recording_state.active = true
			recording_state.file = file
			set_recording_indicator_visible(true)

			recording_state.pid = awful.spawn.easy_async(
				{ "ffmpeg", "-y", "-f", "x11grab", "-framerate", "30",
				  "-window_id", wid, "-i", ":0.0", file },
				function(_, stderr, _, _)
					set_recording_indicator_visible(false)
					recording_state.active = false
					recording_state.pid = nil

					local f = io.open(file, "rb")
					local size = 0
					if f then
						size = f:seek("end") or 0
						f:close()
					end

					if size > 0 then
						naughty.notify({
							title = "Recording saved",
							text = file,
							timeout = 5,
						})
					else
						naughty.notify({
							preset = naughty.config.presets.critical,
							title = "Recording failed",
							text = (stderr and stderr ~= "") and stderr or "no output produced",
							timeout = 5,
						})
					end
				end
			)
		end
	)
end

local function stop_recording()
	if not recording_state.active or not recording_state.pid then return end
	awful.spawn({ "kill", "-INT", tostring(recording_state.pid) })
end

local function toggle_recording()
	if recording_state.active then
		stop_recording()
	else
		start_recording()
	end
end
-- }}}

-- {{{ Claude Code usage widget
-- Polls the (undocumented) https://api.anthropic.com/api/oauth/usage endpoint
-- using the OAuth token from ~/.claude/.credentials.json and renders
-- "5h N% · 7d N%" with colour thresholds. The endpoint is what /usage uses
-- internally and is not part of the public API — could break without notice.
local claude_usage_widgets = {}

local claude_icon_path = gears.filesystem.get_configuration_dir() .. "icons/claude.svg"

local function make_claude_usage_widget()
	local tb = wibox.widget({
		markup = '<span foreground="#888888">…</span>',
		widget = wibox.widget.textbox,
	})
	table.insert(claude_usage_widgets, tb)

	local icon = wibox.widget({
		image = gears.color.recolor_image(claude_icon_path, "#a0c4ff"),
		forced_height = 14,
		forced_width = 14,
		widget = wibox.widget.imagebox,
	})

	return wibox.widget({
		{
			{
				icon,
				valign = "center",
				halign = "center",
				widget = wibox.container.place,
			},
			{
				{
					tb,
					valign = "center",
					halign = "center",
					widget = wibox.container.place,
				},
				left = 6,
				widget = wibox.container.margin,
			},
			layout = wibox.layout.fixed.horizontal,
		},
		left = 8,
		right = 8,
		widget = wibox.container.margin,
	})
end
-- }}}

awful.screen.connect_for_each_screen(function(s)
	-- Wallpaper
	set_wallpaper(s)

	-- Each screen has its own tag table. Names are blank by default so the
	-- numerical prefix shown in the taglist (from tag.index) is the only
	-- number — renaming a tag never erases it.
	local tags = awful.tag({ "", "", "", "", "", "", "", "", "" }, s, awful.layout.layouts[2])
	local saved = saved_tag_names[s.index] or {}
	for i, t in ipairs(tags) do
		if saved[i] then t.name = saved[i] end
	end

	-- Create a promptbox for each screen
	s.mypromptbox = awful.widget.prompt()
	-- Create an imagebox widget which will contain an icon indicating which layout we're using.
	-- We need one layoutbox per screen.
	s.mylayoutbox = awful.widget.layoutbox(s)
	s.mylayoutbox:buttons(gears.table.join(
		awful.button({}, 1, function()
			awful.layout.inc(1)
		end),
		awful.button({}, 3, function()
			awful.layout.inc(-1)
		end),
		awful.button({}, 4, function()
			awful.layout.inc(1)
		end),
		awful.button({}, 5, function()
			awful.layout.inc(-1)
		end)
	))
	-- Create a taglist widget

	s.mytaglist = awful.widget.taglist({
		screen = s,
		filter = awful.widget.taglist.filter.all,
		layout = {
			spacing_widget = {
				color = "#dddddd",
				widget = wibox.widget.separator,
			},
			layout = wibox.layout.flex.horizontal,
		},
		widget_template = {
			{
				{
					-- Number block: square flush with the wibar; filled when the
					-- tag has clients, transparent otherwise.
					{
						{
							id = "index_role",
							align = "center",
							valign = "center",
							widget = wibox.widget.textbox,
						},
						left = 8,
						right = 8,
						widget = wibox.container.margin,
					},
					id = "occupancy_role",
					widget = wibox.container.background,
				},
				-- Bordered strip of per-client icons + sound indicator. Sits
				-- flush with the number square (no gap) and stretches to the
				-- row's height so it lines up with the wibar's top/bottom
				-- edges. Hidden when the tag has no icons and no sound (set
				-- in paint_taglist_row).
				{
					{
						{
							{
								id = "clients_role",
								spacing = 2,
								layout = wibox.layout.fixed.horizontal,
							},
							{
								id = "sound_role",
								visible = false,
								markup = ' <span foreground="#a0c4ff" size="large">♪</span>',
								widget = wibox.widget.textbox,
							},
							layout = wibox.layout.fixed.horizontal,
						},
						left = 3,
						right = 3,
						widget = wibox.container.margin,
					},
					id = "clients_border",
					shape = gears.shape.rectangle,
					shape_border_color = "#dddddd",
					shape_border_width = 1,
					widget = wibox.container.background,
				},
				{
					forced_width = 6,
					widget = wibox.container.background,
				},
				{
					{
						id = "icon_role",
						widget = wibox.widget.imagebox,
					},
					margins = 2,
					widget = wibox.container.margin,
				},
				{
					id = "text_role",
					widget = wibox.widget.textbox,
				},
				{
					forced_width = 10,
					widget = wibox.container.background,
				},
				layout = wibox.layout.fixed.horizontal,
			},
			id = "background_role",
			widget = wibox.container.background,
			create_callback = function(self, t, index, _)
				paint_taglist_row(self, t, index)

				local sw = self:get_children_by_id("sound_role")[1]
				if sw then sw.visible = t.has_sound == true end
				t:connect_signal("property::has_sound", function()
					local s2 = self:get_children_by_id("sound_role")[1]
					if s2 then s2.visible = t.has_sound == true end
					-- Border visibility now depends on has_sound too, repaint
					-- so an empty tag that starts/stops emitting audio shows
					-- or hides the border accordingly.
					paint_taglist_row(self, t, index)
				end)

				self:connect_signal("mouse::enter", function()
					if self.bg ~= "#ff0000" then
						self.backup = self.bg
						self.has_backup = true
					end
					self.bg = "#555555"
				end)
				self:connect_signal("mouse::leave", function()
					if self.has_backup then
						self.bg = self.backup
					end
				end)
			end,
			update_callback = function(self, t, index, _)
				paint_taglist_row(self, t, index)
			end,
		},
		buttons = taglist_buttons,
	})

	-- Create a tasklist widget
	s.mytasklist = awful.widget.tasklist({
		screen = s,
		filter = awful.widget.tasklist.filter.currenttags,
		buttons = tasklist_buttons,
	})

	-- Create the wibox
	s.bottomwibox = awful.wibar({ position = "bottom", screen = s })
	s.topwibox = awful.wibar({ position = "top", screen = s })

	-- Add widgets to the wibox
	s.bottomwibox:setup({
		layout = wibox.layout.align.horizontal,
		{ -- Left widgets
			layout = wibox.layout.fixed.horizontal,
			s.mypromptbox,
		},
		s.mytaglist, -- Middle: expands to fill the bar so flex rows distribute evenly
		{ -- Right widgets
			layout = wibox.layout.fixed.horizontal,
		},
	})
	s.topwibox:setup({
		layout = wibox.layout.align.horizontal,
		{ -- Left widgets
			layout = wibox.layout.fixed.horizontal,
			-- mylauncher,
			-- s.mytaglist,
			-- s.mypromptbox,
		},
		s.mytasklist, -- Middle widget
		{ -- Right widgets
			layout = wibox.layout.fixed.horizontal,
			make_recording_indicator(),
			mykeyboardlayout,
			wibox.widget.systray(),
			make_claude_usage_widget(),
			mytextclock,
			battery,
			s.mylayoutbox,
		},
	})
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(
	awful.button({}, 3, function()
		mymainmenu:toggle()
	end),
	awful.button({}, 4, awful.tag.viewnext),
	awful.button({}, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = gears.table.join(

	awful.key({ modkey }, "s", hotkeys_popup.show_help, { description = "show help", group = "awesome" }),
	awful.key({ modkey }, "Left", awful.tag.viewprev, { description = "view previous", group = "tag" }),
	awful.key({ modkey }, "Right", awful.tag.viewnext, { description = "view next", group = "tag" }),
	awful.key({ modkey }, "Escape", awful.tag.history.restore, { description = "go back", group = "tag" }),

	awful.key({ modkey }, "j", function()
		awful.client.focus.byidx(1)
	end, { description = "focus next by index", group = "client" }),
	awful.key({ modkey }, "k", function()
		awful.client.focus.byidx(-1)
	end, { description = "focus previous by index", group = "client" }),
	awful.key({ modkey }, "w", function()
		mymainmenu:show()
	end, { description = "show main menu", group = "awesome" }),

	-- Layout manipulation
	awful.key({ modkey, "Shift" }, "j", function()
		awful.client.swap.byidx(1)
	end, { description = "swap with next client by index", group = "client" }),
	awful.key({ modkey, "Shift" }, "k", function()
		awful.client.swap.byidx(-1)
	end, { description = "swap with previous client by index", group = "client" }),
	awful.key({ modkey, "Control" }, "j", function()
		awful.screen.focus_relative(1)
	end, { description = "focus the next screen", group = "screen" }),
	awful.key({ modkey, "Control" }, "k", function()
		awful.screen.focus_relative(-1)
	end, { description = "focus the previous screen", group = "screen" }),
	awful.key({ modkey }, "u", awful.client.urgent.jumpto, { description = "jump to urgent client", group = "client" }),
	awful.key({ modkey }, "Tab", function()
		awful.client.focus.history.previous()
		if client.focus then
			client.focus:raise()
		end
	end, { description = "go back", group = "client" }),

	-- Standard program
	awful.key({ modkey }, "Pause", function()
		awful.spawn(terminalt)
	end, { description = "open a terminal", group = "launcher" }),
	awful.key({ modkey }, "space", function()
		awful.spawn(terminalt)
	end, { description = "open a terminal", group = "launcher" }),
	awful.key({ modkey, "Shift" }, "r", awesome.restart, { description = "restart awesomewm", group = "awesome" }),

	awful.key({ modkey }, "l", function()
		awful.tag.incmwfact(0.05)
	end, { description = "increase master width factor", group = "layout" }),
	awful.key({ modkey }, "h", function()
		awful.tag.incmwfact(-0.05)
	end, { description = "decrease master width factor", group = "layout" }),
	awful.key({ modkey, "Shift" }, "h", function()
		awful.tag.incnmaster(1, nil, true)
	end, { description = "increase the number of master clients", group = "layout" }),
	awful.key({ modkey, "Shift" }, "l", function()
		awful.tag.incnmaster(-1, nil, true)
	end, { description = "decrease the number of master clients", group = "layout" }),
	awful.key({ modkey, "Control" }, "h", function()
		awful.tag.incncol(1, nil, true)
	end, { description = "increase the number of columns", group = "layout" }),
	awful.key({ modkey, "Control" }, "l", function()
		awful.tag.incncol(-1, nil, true)
	end, { description = "decrease the number of columns", group = "layout" }),
	awful.key({ modkey }, "space", function()
		awful.layout.inc(1)
	end, { description = "select next", group = "layout" }),
	awful.key({ modkey, "Shift" }, "space", function()
		awful.layout.inc(-1)
	end, { description = "select previous", group = "layout" }),

	awful.key({ modkey, "Control" }, "n", function()
		local c = awful.client.restore()
		-- Focus restored client
		if c then
			c:emit_signal("request::activate", "key.unminimize", { raise = true })
		end
	end, { description = "restore minimized", group = "client" }),

	-- Prompt
	awful.key({ modkey }, "d", function()
		awful.util.spawn(rofi_settings)
	end, { description = "run rofi prompt", group = "launcher" }),

	awful.key({ modkey }, "e", function()
		awful.util.spawn(rofimoji_settings)
	end, { description = "run rofimoji prompt", group = "launcher" }),
	awful.key({ modkey }, "x", function()
		awful.prompt.run({
			prompt = "Run Lua code: ",
			textbox = awful.screen.focused().mypromptbox.widget,
			exe_callback = awful.util.eval,
			history_path = awful.util.get_cache_dir() .. "/history_eval",
		})
	end, { description = "lua execute prompt", group = "awesome" }),
	-- Menubar
	awful.key({ modkey }, "p", function()
		menubar.show()
	end, { description = "show the menubar", group = "launcher" }),
	-- Quake terminal
	awful.key({}, "Pause", function()
		quake_toggle()
	end, { description = "show quake menu", group = "terminal" }),

	awful.key({}, "#105", function()
		quake_toggle()
	end, { description = "show quake menu", group = "terminal" }),

	awful.key({}, "Print", function()
		awful.util.spawn_with_shell("import /home/olik/screenshots/screenshot-`date +%s`.png")
	end, { description = "take screenshot", group = "util" }),

	awful.key({ "Shift" }, "Print", function()
		toggle_recording()
	end, { description = "record window (toggle)", group = "util" }),

	-- Rename current tag. The numerical prefix is fixed and shown in the
	-- prompt label — only the custom suffix is editable.
	awful.key({ modkey }, "F2", function()
		local tag = awful.screen.focused().selected_tag
		if not tag then return end
		awful.prompt.run({
			prompt = tostring(tag.index) .. ": ",
			textbox = awful.screen.focused().mypromptbox.widget,
			text = tag.name or "",
			exe_callback = function(new_name)
				tag.name = new_name or ""
				save_tag_names()
			end,
		})
	end, { description = "rename current tag", group = "tag" }),

	-- Resize focused client to exact pixel dimensions
	awful.key({ modkey }, "F3", function()
		local c = client.focus
		if not c then return end
		awful.prompt.run({
			prompt = "Resize (WxH or WxH+X+Y): ",
			textbox = awful.screen.focused().mypromptbox.widget,
			text = c.width .. "x" .. c.height,
			exe_callback = function(input)
				if not input or #input == 0 then return end
				local w, h, x, y = input:match("^(%d+)x(%d+)%+(%-?%d+)%+(%-?%d+)$")
				if not w then
					w, h = input:match("^(%d+)x(%d+)$")
				end
				if not w then return end
				c.floating = true
				local geo = { width = tonumber(w), height = tonumber(h) }
				if x then geo.x = tonumber(x) end
				if y then geo.y = tonumber(y) end
				c:geometry(geo)
			end,
		})
	end, { description = "resize focused client to exact pixels", group = "client" }),

	-- Resize focused client to 810x1531
	awful.key({ modkey }, "F4", function()
		local c = client.focus
		if not c then return end
		c.floating = true
		c:geometry({ width = 810, height = 1531 })
	end, { description = "resize focused client to 810x1531", group = "client" })
)

clientkeys = gears.table.join(
	awful.key({ modkey }, "f", function(c)
		c.fullscreen = not c.fullscreen
		c:raise()
	end, { description = "toggle fullscreen", group = "client" }),
	awful.key({ modkey, "Shift" }, "q", function(c)
		c:kill()
	end, { description = "close", group = "client" }),
	awful.key(
		{ modkey, "Control" },
		"space",
		awful.client.floating.toggle,
		{ description = "toggle floating", group = "client" }
	),
	awful.key({ modkey, "Control" }, "Return", function(c)
		c:swap(awful.client.getmaster())
	end, { description = "move to master", group = "client" }),
	awful.key({ modkey }, "o", function(c)
		c:move_to_screen()
	end, { description = "move to screen", group = "client" }),
	awful.key({ modkey }, "t", function(c)
		c.ontop = not c.ontop
	end, { description = "toggle keep on top", group = "client" }),
	awful.key({ modkey }, "n", function(c)
		-- The client currently has the input focus, so it cannot be
		-- minimized, since minimized clients can't have the focus.
		c.minimized = true
	end, { description = "minimize", group = "client" }),
	awful.key({ modkey }, "m", function(c)
		c.maximized = not c.maximized
		c:raise()
	end, { description = "(un)maximize", group = "client" }),
	awful.key({ modkey, "Control" }, "m", function(c)
		c.maximized_vertical = not c.maximized_vertical
		c:raise()
	end, { description = "(un)maximize vertically", group = "client" }),
	awful.key({ modkey, "Shift" }, "m", function(c)
		c.maximized_horizontal = not c.maximized_horizontal
		c:raise()
	end, { description = "(un)maximize horizontally", group = "client" })
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
	globalkeys = gears.table.join(
		globalkeys,
		-- View tag only.
		awful.key({ modkey }, "#" .. i + 9, function()
			local screen = awful.screen.focused()
			local tag = screen.tags[i]
			if tag then
				tag:view_only()
			end
		end, { description = "view tag #" .. i, group = "tag" }),
		-- Toggle tag display.
		awful.key({ modkey, "Control" }, "#" .. i + 9, function()
			local screen = awful.screen.focused()
			local tag = screen.tags[i]
			if tag then
				awful.tag.viewtoggle(tag)
			end
		end, { description = "toggle tag #" .. i, group = "tag" }),
		-- Move client to tag.
		awful.key({ modkey, "Shift" }, "#" .. i + 9, function()
			if client.focus then
				local tag = client.focus.screen.tags[i]
				if tag then
					client.focus:move_to_tag(tag)
				end
			end
		end, { description = "move focused client to tag #" .. i, group = "tag" }),
		-- Toggle tag on focused client.
		awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9, function()
			if client.focus then
				local tag = client.focus.screen.tags[i]
				if tag then
					client.focus:toggle_tag(tag)
				end
			end
		end, { description = "toggle focused client on tag #" .. i, group = "tag" })
	)
end

clientbuttons = gears.table.join(
	awful.button({}, 1, function(c)
		c:emit_signal("request::activate", "mouse_click", { raise = true })
	end),
	awful.button({ modkey }, 1, function(c)
		c:emit_signal("request::activate", "mouse_click", { raise = true })
		awful.mouse.client.move(c)
	end),
	awful.button({ modkey }, 3, function(c)
		c:emit_signal("request::activate", "mouse_click", { raise = true })
		awful.mouse.client.resize(c)
	end)
)

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
	-- All clients will match this rule.
	{
		rule = {},
		properties = {
			border_width = beautiful.border_width,
			border_color = beautiful.border_normal,
			focus = awful.client.focus.filter,
			raise = true,
			keys = clientkeys,
			buttons = clientbuttons,
			screen = awful.screen.preferred,
			placement = awful.placement.no_overlap + awful.placement.no_offscreen,
		},
	},

	{
		rule = { instance = "Toolkit", class = "firefox" },
		callback = function(c)
			c:tags(c.screen.tags)
		end,
	},

	-- Floating clients.
	{
		rule_any = {
			instance = {
				"DTA", -- Firefox addon DownThemAll.
				"copyq", -- Includes session name in class.
				"pinentry",
			},
			class = {
				"Arandr",
				"Blueman-manager",
				"Gpick",
				"Kruler",
				"MessageWin", -- kalarm.
				"Sxiv",
				"Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
				"Wpa_gui",
				"veromix",
				"xtightvncviewer",
				"zoom",
			},

			-- Note that the name property shown in xprop might be set slightly after creation of the client
			-- and the name shown there might not match defined rules here.
			name = {
				"Event Tester", -- xev.
			},
			role = {
				"AlarmWindow", -- Thunderbird's calendar.
				"ConfigManager", -- Thunderbird's about:config.
				"pop-up", -- e.g. Google Chrome's (detached) Developer Tools.
			},
		},
		properties = { floating = true },
	},

	-- Add titlebars to normal clients and dialogs
	{ rule_any = { type = { "normal", "dialog" } }, properties = { titlebars_enabled = false } },
}
-- }}}

-- {{{ Signals
-- Re-run paint_taglist_row when clients appear, vanish, or finally provide
-- their icon. The taglist library handles tagged/untagged on its own, but
-- those don't fire reliably for late-arriving icons or for unmanage. Emitting
-- a no-op tag signal that the taglist already listens to is the cheapest way
-- to force a row repaint.
local function bump_taglists()
	for s in screen do
		for _, t in ipairs(s.tags) do
			t:emit_signal("property::name")
		end
	end
end
client.connect_signal("manage", bump_taglists)
client.connect_signal("unmanage", bump_taglists)
client.connect_signal("property::icon", bump_taglists)

-- Signal function to execute when a new client appears.
client.connect_signal("manage", function(c)
	-- Set the windows at the slave,
	-- i.e. put it at the end of others instead of setting it master.
	-- if not awesome.startup then awful.client.setslave(c) end

	if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
		-- Prevent clients from being unreachable after screen count changes.
		awful.placement.no_offscreen(c)
	end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
	-- buttons for the titlebar
	local buttons = gears.table.join(
		awful.button({}, 1, function()
			c:emit_signal("request::activate", "titlebar", { raise = true })
			awful.mouse.client.move(c)
		end),
		awful.button({}, 3, function()
			c:emit_signal("request::activate", "titlebar", { raise = true })
			awful.mouse.client.resize(c)
		end)
	)

	awful.titlebar(c):setup({
		{ -- Left
			awful.titlebar.widget.iconwidget(c),
			buttons = buttons,
			layout = wibox.layout.fixed.horizontal,
		},
		{ -- Middle
			{ -- Title
				align = "center",
				widget = awful.titlebar.widget.titlewidget(c),
			},
			buttons = buttons,
			layout = wibox.layout.flex.horizontal,
		},
		{ -- Right
			awful.titlebar.widget.floatingbutton(c),
			awful.titlebar.widget.maximizedbutton(c),
			awful.titlebar.widget.stickybutton(c),
			awful.titlebar.widget.ontopbutton(c),
			awful.titlebar.widget.closebutton(c),
			layout = wibox.layout.fixed.horizontal(),
		},
		layout = wibox.layout.align.horizontal,
	})
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
	-- checking if we don't currently have focused, or if the current focused is not fullscreen
	-- (we don't want to change focus for screens that are fullscreen)
	-- otherwise lazily change the focus
	if not client.focus or client.focus and not client.focus.fullscreen then
		c:emit_signal("request::activate", "mouse_enter", { raise = false })
	end
end)

client.connect_signal("focus", function(c)
	c.border_color = beautiful.border_focus
end)
client.connect_signal("unfocus", function(c)
	c.border_color = beautiful.border_normal
end)

-- {{{ Per-tag audio indicator
-- Polls pactl for currently-playing sink-inputs (State: RUNNING) and flips
-- tag.has_sound on each tag whose clients are producing audio.
-- Returns { [pid] = { media_name1, media_name2, ... }, ... } for every
-- currently-playing sink-input. media.name is the title the application sets
-- on the stream (e.g. the playing tab's title for Firefox/Chromium); we use it
-- to narrow down which window is actually producing the sound when several
-- share the same PID.
local function parse_running_pids(stdout)
	local pids = {}
	local current = nil
	local function flush()
		-- Active iff PulseAudio State == RUNNING or PipeWire-pulse Corked == no.
		-- Treat unknown/missing playback state as active so we don't miss audio
		-- on backends that omit both fields.
		if current and current.pid and current.playing ~= false then
			local list = pids[current.pid] or {}
			table.insert(list, current.media or "")
			pids[current.pid] = list
		end
	end
	for line in stdout:gmatch("[^\n]+") do
		if line:match("^Sink Input #") then
			flush()
			current = { playing = nil }
		elseif current then
			local state = line:match("^%s*State:%s*(%S+)")
			if state then current.playing = (state == "RUNNING") end
			local corked = line:match("^%s*Corked:%s*(%S+)")
			if corked then current.playing = (corked == "no") end
			local pid = line:match('application%.process%.id = "(%d+)"')
			if pid then current.pid = pid end
			local media = line:match('media%.name = "(.-)"')
			if media then current.media = media end
		end
	end
	flush()
	return pids
end

local function ppid_of(pid)
	local f = io.open("/proc/" .. pid .. "/status", "r")
	if not f then return nil end
	local ppid
	for line in f:lines() do
		local p = line:match("^PPid:%s*(%d+)")
		if p then ppid = p; break end
	end
	f:close()
	return ppid
end

local function refresh_tag_sound()
	awful.spawn.easy_async({ "pactl", "list", "sink-inputs" }, function(stdout)
		local pids = parse_running_pids(stdout)

		-- Group clients by PID. Multiple windows can share a PID
		-- (e.g. several Firefox windows under one Firefox process). We pick
		-- the actually-playing window per stream by matching the sink-input's
		-- media.name against client window titles; if no title match, fall
		-- back to all clients with that PID.
		local clients_by_pid = {}
		for _, c in ipairs(client.get()) do
			if c.pid then
				local key = tostring(c.pid)
				local list = clients_by_pid[key] or {}
				table.insert(list, c)
				clients_by_pid[key] = list
			end
		end

		local tags_with_sound = {}
		for pid, media_names in pairs(pids) do
			-- Walk up the process tree until we hit a known window PID.
			local clients
			local cur = pid
			for _ = 1, 20 do
				if clients_by_pid[cur] then
					clients = clients_by_pid[cur]
					break
				end
				local parent = ppid_of(cur)
				if not parent or parent == "0" or parent == cur then break end
				cur = parent
			end

			if clients then
				-- Narrow to clients whose window title contains any of the
				-- stream's media.name strings. If nothing matches, fall back
				-- to every client with that PID.
				local narrowed = {}
				for _, c in ipairs(clients) do
					for _, name in ipairs(media_names) do
						if name ~= "" and c.name and c.name:find(name, 1, true) then
							table.insert(narrowed, c)
							break
						end
					end
				end
				local matches = (#narrowed > 0) and narrowed or clients
				for _, c in ipairs(matches) do
					for _, t in ipairs(c:tags()) do
						tags_with_sound[t] = true
					end
				end
			end
		end

		for s in screen do
			for _, t in ipairs(s.tags) do
				local now = tags_with_sound[t] == true
				if t.has_sound ~= now then
					t.has_sound = now
					t:emit_signal("property::has_sound")
				end
			end
		end
	end)
end

gears.timer({
	timeout = 2,
	autostart = true,
	call_now = true,
	callback = refresh_tag_sound,
})
-- }}}

-- {{{ Claude Code usage poller
-- The /api/oauth/usage endpoint is rate-limited; polling more often than a
-- few minutes returns 429. The poll interval and timestamp are persisted to
-- ~/.cache/awesome so awesome restarts don't restart the backoff window —
-- if we fetched 30s ago and you restart, we wait the remaining time instead
-- of hammering the endpoint again.
local CLAUDE_POLL_INTERVAL = 300
local claude_cache_file = gears.filesystem.get_cache_dir() .. "claude-usage"
local last_claude_markup = '<span foreground="#888888">…</span>'
local last_claude_fetch = 0

local function load_claude_cache()
	local f = io.open(claude_cache_file, "r")
	if not f then return end
	local ts = f:read("*l")
	local markup = f:read("*a")
	f:close()
	if ts then last_claude_fetch = tonumber(ts) or 0 end
	if markup and markup ~= "" then last_claude_markup = markup end
end

local function save_claude_cache()
	local f = io.open(claude_cache_file, "w")
	if not f then return end
	f:write(tostring(last_claude_fetch), "\n", last_claude_markup)
	f:close()
end

local function paint_claude_widgets()
	for _, w in ipairs(claude_usage_widgets) do
		w.markup = last_claude_markup
	end
end

local function refresh_claude_usage()
	local cmd = [[
		TOKEN=$(jq -r '.claudeAiOauth.accessToken' "$HOME/.claude/.credentials.json" 2>/dev/null) || exit 1
		[ -n "$TOKEN" ] && [ "$TOKEN" != "null" ] || exit 1
		curl -sS --max-time 5 \
			-H "Authorization: Bearer $TOKEN" \
			-H "anthropic-beta: oauth-2025-04-20" \
			"https://api.anthropic.com/api/oauth/usage"
	]]
	awful.spawn.easy_async_with_shell(cmd, function(stdout)
		local five = stdout:match('"five_hour"%s*:%s*{[^}]-"utilization"%s*:%s*([%-%d%.]+)')
		local seven = stdout:match('"seven_day"%s*:%s*{[^}]-"utilization"%s*:%s*([%-%d%.]+)')
		if five and seven then
			local function color(p)
				if p >= 90 then return "#ff6b6b"
				elseif p >= 75 then return "#ffd166"
				else return "#a0c4ff" end
			end
			local f, s = tonumber(five), tonumber(seven)
			last_claude_markup = string.format(
				'<span foreground="#aaaaaa">5h </span><span foreground="%s">%d%%</span><span foreground="#666666"> · </span><span foreground="#aaaaaa">7d </span><span foreground="%s">%d%%</span>',
				color(f), math.floor(f + 0.5),
				color(s), math.floor(s + 0.5)
			)
			last_claude_fetch = os.time()
			save_claude_cache()
		end
		paint_claude_widgets()
	end)
end

load_claude_cache()
paint_claude_widgets()

local age = os.time() - last_claude_fetch
if age >= CLAUDE_POLL_INTERVAL then
	-- Cache is stale, refresh immediately.
	refresh_claude_usage()
	gears.timer({
		timeout = CLAUDE_POLL_INTERVAL,
		autostart = true,
		callback = refresh_claude_usage,
	})
else
	-- Cache is fresh: schedule the first refresh for when it expires, then
	-- fall back to the regular interval.
	gears.timer.start_new(CLAUDE_POLL_INTERVAL - age, function()
		refresh_claude_usage()
		gears.timer({
			timeout = CLAUDE_POLL_INTERVAL,
			autostart = true,
			callback = refresh_claude_usage,
		})
		return false
	end)
end
-- }}}

-- prevent urgent from stealing focus, this works but also disabled 'Window' from rofi
-- awful.ewmh.add_activate_filter(function() return false end, "ewmh")
