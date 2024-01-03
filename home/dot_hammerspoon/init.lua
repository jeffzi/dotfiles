local inspect = hs.inspect.inspect

-- -----------------
-- Screen management
-- -----------------

local function set_screen_resolution()
   local screens = hs.screen.allScreens()
   if #screens == 1 then
      hs.screen.primaryScreen():setMode(1352, 878, 2.0, 120, 8)
   else
      local laptopScreen = hs.screen.find("Built%-in")
      laptopScreen:setMode(1147, 745, 2.0, 120, 8)
   end
end

hs.screen.watcher.new(set_screen_resolution):start()

-- ------------------------------------------------------------
-- Switch on/off external display (shared with Desktop machine)
-- ------------------------------------------------------------

local desk_log = hs.logger.new("display", "debug")

-- Fix for currentNetwork returning nil on MacOS Sonoma
-- This will add Hammerspoon to Settings/Privacy & Security/Location Services where we need to enable it.
-- https://github.com/Hammerspoon/hammerspoon/issues/3537#issuecomment-1743870568
hs.location.get()

local currentNetwork = hs.wifi.currentNetwork
local home_ssid = "zheli"
local desktop_address = "192.168.1.85"

local function is_home()
   return currentNetwork() == home_ssid
end

local function is_anker_hub(usb_device)
   -- Using 2 devices to detect the anker hub consistenly
   --"USB 10/100/1000 LAN"
   return (usb_device.vendorID == 3034 and usb_device.productID == 33107)
      -- "USB3.1 Hub"
      or (usb_device.vendorID == 1507 and usb_device.productID == 1574)
end

local function is_anker_hub_connected()
   local usb_devices = hs.usb.attachedDevices()
   for i = 1, #usb_devices do
      if is_anker_hub(usb_devices[i]) then
         return true
      end
   end
   return false
end

local function run_shortcut(shortcut)
   desk_log.i(string.format("Running %s shortcut...", shortcut))
   local success = os.execute(string.format("shortcuts run '%s'", shortcut))
   if not success then
      desk_log.e(string.format("Failed to run `shortcuts %s'`", shortcut))
   else
      desk_log.i("done.")
   end
end

local function desk_on()
   desk_log.i("Running desk_on function...")
   if not is_home() then
      desk_log.i("Not home, don't switch plug on.")
      return
   end
   if is_anker_hub_connected() then
      run_shortcut("Desktop on")
   end
end

local ping = hs.network.ping.ping

local function desk_off()
   desk_log.i("Running desk_off function...")
   if not is_home() then
      desk_log.i("Not home, don't switch plug off.")
      return
   end
   -- Switch off display only when Desktop is not awake.
   local is_success = false
   local function ping_callback(self, message, ...)
      if message == "receivedPacket" then
         is_success = true
         self:cancel() -- exit early if one ping succeeds
      elseif message == "didFinish" and not is_success then
         run_shortcut("Desktop off")
      end
   end

   desk_log.i("pinging desktop...")
   ping(desktop_address, 1, 1.0, 1.0, "any", ping_callback)
end

local function auto_power_desk()
   if is_anker_hub_connected() then
      desk_on()
   else
      desk_off()
   end
end

auto_power_desk()

local usb_log = hs.logger.new("usb", "debug")
local function hub_callback(event)
   usb_log.i(inspect(event))
   if not is_anker_hub(event) then
      return
   end
   if event.eventType == "added" then
      desk_on()
   elseif event.eventType == "removed" then
      desk_off()
   end
end

hs.usb.watcher.new(hub_callback):start()
usb_log.i("Attached USB devices:\n" .. inspect(hs.usb.attachedDevices()))

local caffeinate_watcher = hs.caffeinate.watcher
local on_events =
   { [caffeinate_watcher.systemDidWake] = true, [caffeinate_watcher.screensDidUnlock] = true }
local off_events =
   { [caffeinate_watcher.systemWillSleep] = true, [caffeinate_watcher.systemWillPowerOff] = true }
local caffeinate_log = hs.logger.new("caffeinate", "debug")

local function system_state_callback(event)
   if on_events[event] then
      caffeinate_log.i("Switch on event: " .. event)
      desk_on()
   elseif off_events[event] then
      caffeinate_log.i("Switch off event: " .. event)
      desk_off()
   end
end

caffeinate_watcher.new(system_state_callback):start()
