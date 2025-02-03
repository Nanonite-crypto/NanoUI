<<<<<<< Updated upstream
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

=======
local NanoUI = {}
local WindowModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/Nanonite-crypto/NanoUI/refs/heads/main/NanoUI/Components/Window.lua"))()
local ButtonModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/Nanonite-crypto/NanoUI/refs/heads/main/NanoUI/Components/Button.lua"))()
local ToggleModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/Nanonite-crypto/NanoUI/refs/heads/main/NanoUI/Components/Toggle.lua"))()
local ThemeManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/Nanonite-crypto/NanoUI/refs/heads/main/NanoUI/Themes/ThemeManager.lua"))()

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NanoUIScreen"
ScreenGui.DisplayOrder = 1
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

-- Singleton pattern for NanoUI
local instance = nil
function NanoUI.New()
    if instance then return instance end
    instance = {
        Windows = {}
    }
    return instance
end

-- API Exposure
function NanoUI.NewWindow(config)
    local window = WindowModule.New(ScreenGui, config)  -- Set ScreenGui as the parent
    table.insert(instance.Windows, window)
    return window
end

function NanoUI.SetTheme(theme)
    ThemeManager.Apply(theme)
end

-- Window Class (Assuming WindowModule has these methods)
function WindowModule.New(config)
    local window = {
        Title = config.Title or "Untitled Window",
        Size = config.Size or {Width = 400, Height = 300},
        Elements = {}
    }
    return window
end

function WindowModule:AddButton(text, callback)
    local button = ButtonModule.Create(text, callback)
    table.insert(self.Elements, button)
    return button
end

function WindowModule:AddToggle(text, defaultState, callback)
    local toggle = ToggleModule.Create(text, defaultState, callback)
    table.insert(self.Elements, toggle)
    return toggle
end

function WindowModule:Destroy()
    -- Here you would handle cleaning up all elements of the window
    print("Destroying window:", self.Title)
    self.Elements = nil -- In pure Lua, we can't actually destroy objects, so we're just clearing references
end

-- Theme Manager (Assuming ThemeManager has this method)
function ThemeManager.Apply(theme)
    -- Here you would apply the theme to all elements or windows
    print("Applying theme:", theme)
end

>>>>>>> Stashed changes
return NanoUI