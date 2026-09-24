hs.loadSpoon("EmmyLua")
require("hs.ipc")

--- Send a macOS notification with an info or caution icon.
--- @param title string Notification title.
--- @param is_error boolean? Caution-icon flag; info icon when false or nil.
local function notification(title, is_error)
   local icon = is_error and "NSCaution" or "NSInfo"
   hs.notify
      .new({ title = title, withdrawAfter = 5 })
      :contentImage(hs.image.imageFromName(icon))
      :send()
end

-- -----------------
-- Screen management
-- -----------------

local screen_log = hs.logger.new("screen", "debug")

--- @class ScreenMode
--- @field label string Log label.
--- @field w integer Width in points.
--- @field h integer Height in points.

local EXTERNAL_SCREEN_NAME = "AW3926QW"
--- @type ScreenMode
local DOCKED_MODE = { label = "Docked", w = 1149, h = 746 }
--- @type ScreenMode
local STANDALONE_MODE = { label = "Standalone", w = 1346, h = 874 }
local SCREEN_SCALE = 2.0
local SCREEN_REFRESH = 120
local SCREEN_DEPTH = 8
local SCREEN_SETTLE_DELAY_S = 1.5

--- Set laptop screen resolution based on whether an external display is connected.
local function set_screen_resolution()
   local laptop = hs.screen.find("Built%-in")
   local external = hs.screen.find(EXTERNAL_SCREEN_NAME)

   screen_log.df(
      "Screens: laptop=%s external=%s",
      tostring(laptop ~= nil),
      tostring(external ~= nil)
   )

   if laptop == nil then
      screen_log.i("Clamshell mode (no laptop screen)")
      return
   end

   local current = laptop:currentMode()
   local target = external ~= nil and DOCKED_MODE or STANDALONE_MODE

   if current.w == target.w and current.h == target.h then
      screen_log.d("Laptop already at target resolution, skipping")
      return
   end

   local ok = laptop:setMode(target.w, target.h, SCREEN_SCALE, SCREEN_REFRESH, SCREEN_DEPTH)
   if not ok then
      screen_log.ef("Failed to set laptop resolution to %dx%d", target.w, target.h)
      notification("Failed to set laptop resolution", true)
      return
   end

   screen_log.f("%s: laptop → %dx%d", target.label, target.w, target.h)
end

-- macOS emits several screen events per plug/unplug; restarting one delayed timer runs
-- set_screen_resolution once, after the last event has settled.
local screen_settle_timer = hs.timer.delayed.new(SCREEN_SETTLE_DELAY_S, set_screen_resolution)

--- Restart the settle countdown on each screen configuration change.
local function on_screen_change()
   screen_log.df("Screen change detected, waiting %gs for macOS...", SCREEN_SETTLE_DELAY_S)
   screen_settle_timer:start()
end

-- Global, not local: a local goes out of scope once init.lua returns, and the garbage
-- collector then stops the watcher silently.
screen_watcher = hs.screen.watcher.new(on_screen_change):start()
set_screen_resolution()
