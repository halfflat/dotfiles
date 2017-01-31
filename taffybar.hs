import System.Taffybar

import System.Taffybar.Systray
import System.Taffybar.TaffyPager
import System.Taffybar.SimpleClock
import System.Taffybar.FreedesktopNotifications
import System.Taffybar.Widgets.PollingBar
import System.Taffybar.Widgets.PollingGraph
import System.Taffybar.Pager
import System.Taffybar.WorkspaceSwitcher
import System.Taffybar.WindowSwitcher

import System.Information.Memory
import System.Information.CPU

import Graphics.UI.Gtk

memCallback = do
    mi <- parseMeminfo
    return [memoryUsedRatio mi]

cpuCallback = do
    (userLoad, systemLoad, totalLoad) <- cpuLoad
    return [totalLoad, systemLoad]

memGraphConfig = defaultGraphConfig { graphDataColors = [(1,0,0,1)], graphLabel = Just "mem" }
cpuGraphConfig = defaultGraphConfig { graphDataColors = [(0,1,0,1), (1,0,1,0.5)], graphLabel = Just "cpu" }
    

customPager = do
    pager <- pagerNew $ defaultPagerConfig {
        -- visibleWorkspace = colorize "white" "grey30" . escape,
        visibleWorkspace = colorize "black" "#408030" . escape,
        activeWorkspace  = colorize "black" "#80f070" . escape
    }
    wspaceSwitcher <- wspaceSwitcherNew pager
    windowSwitcher <- windowSwitcherNew pager
    sep <- labelNew $ Just " » "
    box <- hBoxNew False 0

    boxPackStart box wspaceSwitcher PackNatural 0
    boxPackStart box sep  PackNatural 0
    boxPackStart box windowSwitcher PackNatural 0

    widgetShowAll box
    return $ toWidget box


main = do
    let clock = textClockNew Nothing "<span fgcolor='orange'>%a %b %_d %H:%M</span>" 1
        pager = customPager
        note = notifyAreaNew defaultNotificationConfig
        mem = pollingGraphNew memGraphConfig 0.5 memCallback
        cpu = pollingGraphNew cpuGraphConfig 0.5 cpuCallback
        tray = systrayNew

    defaultTaffybar defaultTaffybarConfig { startWidgets = [pager, note], endWidgets = [tray, clock, mem, cpu] }
