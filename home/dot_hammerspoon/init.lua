---@diagnostic disable: lowercase-global
-- -----------------
-- Screen management
-- -----------------

function screenWatcher()
    local screens = hs.screen.allScreens()
    if #screens == 1 then
        hs.screen.primaryScreen():setMode(1352, 878, 2.0, 120, 8)
        hs.eventtap.keyStroke({ "shift", "cmd", "alt", "ctrl" }, "k")
    else
        local laptopScreen = hs.screen.find('Built%-in')
        laptopScreen:setMode(1147, 745, 2.0, 120, 8)
    end
end

screenWatcherObject = hs.screen.watcher.new(screenWatcher)
screenWatcherObject:start()
