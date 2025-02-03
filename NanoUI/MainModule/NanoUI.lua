local NanoUI = {}
local Players = game:GetService("Players")
local user = Players.LocalPlayer
local PlayerGui = user:WaitForChild("PlayerGui")

-- Singleton pattern for NanoUI
local instance = nil
function NanoUI.New()
    if instance then return instance end
    instance = {
        ScreenGui = Instance.new("ScreenGui"),
        Windows = {}
    }
    instance.ScreenGui.Parent = PlayerGui
    return instance
end

-- API Exposure
function NanoUI.NewWindow(config)
    local WindowModule = require(script.Parent.Components.Window)
    local window = WindowModule.New(instance.ScreenGui, config)
    table.insert(instance.Windows, window)
    return window
end

function NanoUI.Notify(title, message)
    local NotificationModule = require(script.Parent.Components.Notification)
    NotificationModule.Show(title, message)
end

function NanoUI.SetTheme(theme)
    local ThemeManager = require(script.Parent.Themes.ThemeManager)
    ThemeManager.Apply(theme)
end

return NanoUI