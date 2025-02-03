local NanoUI = {}

local function safeLoadModule(url)
    local success, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    if not success then
        print("Error loading module from URL:", url, "\nError:", result)
        return nil
    end
    return result
end

local WindowModule = safeLoadModule("https://raw.githubusercontent.com/Nanonite-crypto/NanoUI/refs/heads/main/NanoUI/Components/Window.lua")
local ButtonModule = safeLoadModule("https://raw.githubusercontent.com/Nanonite-crypto/NanoUI/refs/heads/main/NanoUI/Components/Button.lua")
local ToggleModule = safeLoadModule("https://raw.githubusercontent.com/Nanonite-crypto/NanoUI/refs/heads/main/NanoUI/Components/Toggle.lua")
local ThemeManager = safeLoadModule("https://raw.githubusercontent.com/Nanonite-crypto/NanoUI/refs/heads/main/NanoUI/Themes/ThemeManager.lua")

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
        Windows = {},
        NewWindow = function(self, config)
            if not WindowModule then
                print("WindowModule is not loaded.")
                return nil
            end
            local window = WindowModule.New(ScreenGui, config)
            table.insert(self.Windows, window)
            return window
        end,
        SetTheme = function(self, theme)
            if not ThemeManager then
                print("ThemeManager is not loaded.")
                return
            end
            ThemeManager.Apply(theme)
        end
    }
    return instance
end

-- API Exposure
function NanoUI.NewWindow(config)
    local window = WindowModule.Neww(config)  -- Set ScreenGui as the parent
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

return NanoUI