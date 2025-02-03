-- NanoUI - A simple custom UI library inspired by Rayfield
-- Author: YourNameHere
-- Date: YYYY-MM-DD

local NanoUI = {}
NanoUI.__index = NanoUI

-- Create a new NanoUI instance (a window)
function NanoUI.new(config)
    config = config or {}
    
    local self = setmetatable({}, NanoUI)
    
    -- Create a ScreenGui (parented to CoreGui for executors; you can change this as required)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = config.Name or "NanoUI_Window"
    if not game:GetService("RunService"):IsStudio() then
        screenGui.Parent = game:GetService("CoreGui")
    else
        screenGui.Parent = game:GetService("StarterGui")
    end

    -- Create the main window frame
    local window = Instance.new("Frame")
    window.Name = "Window"
    window.Size = UDim2.new(0, 400, 0, 300)
    window.Position = UDim2.new(0.5, -200, 0.5, -150)
    window.BackgroundColor3 = config.BackgroundColor or Color3.fromRGB(30, 30, 30)
    window.BorderSizePixel = 0
    window.Parent = screenGui

    -- Create a Topbar
    local topbar = Instance.new("Frame")
    topbar.Name = "Topbar"
    topbar.Size = UDim2.new(1, 0, 0, 30)
    topbar.BackgroundColor3 = config.TopbarColor or Color3.fromRGB(45, 45, 45)
    topbar.BorderSizePixel = 0
    topbar.Parent = window

    -- Window Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, 0, 1, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = config.Name or "NanoUI"
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.TextScaled = true
    titleLabel.TextColor3 = config.TextColor or Color3.new(1,1,1)
    titleLabel.Parent = topbar

    -- Container for tabs (content area)
    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "Content"
    contentFrame.Size = UDim2.new(1, 0, 1, -30)
    contentFrame.Position = UDim2.new(0, 0, 0, 30)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = window

    -- Store our created instances for later use
    self.ScreenGui = screenGui
    self.Window = window
    self.Topbar = topbar
    self.Content = contentFrame
    self.Tabs = {}       -- table to store each created tab
    self.CurrentTab = nil
    
    return self
end

-- Create a new tab in the UI window
function NanoUI:CreateTab(tabName)
    tabName = tabName or "Tab"
    local tab = {}
    tab.Name = tabName
    tab.Elements = {} -- for storing UI elements added to this tab

    -- Each tab gets its own Frame inside Content
    local tabFrame = Instance.new("Frame")
    tabFrame.Name = tabName.."Tab"
    tabFrame.Size = UDim2.new(1, 0, 1, 0)
    tabFrame.BackgroundTransparency = 1
    tabFrame.Parent = self.Content

    tab.Frame = tabFrame

    -- Hide the tab (except for the first one)
    if #self.Tabs > 0 then
        tabFrame.Visible = false
    else
        tabFrame.Visible = true
        self.CurrentTab = tab
    end

    table.insert(self.Tabs, tab)
    return tab
end

-- Switch visible tab (pass in a tab from self.Tabs)
function NanoUI:SwitchTab(targetTab)
    for _, tab in pairs(self.Tabs) do
        tab.Frame.Visible = (tab == targetTab)
    end
    self.CurrentTab = targetTab
end

-- Create a Button element inside a tab
-- config: { Name = "Button", Callback = function() ... end }
function NanoUI:CreateButton(tab, config)
    config = config or {}
    local button = Instance.new("TextButton")
    button.Name = config.Name or "Button"
    button.Size = UDim2.new(0, 120, 0, 40)
    button.BackgroundColor3 = config.ButtonColor or Color3.fromRGB(60, 60, 60)
    button.BorderSizePixel = 0
    button.Text = config.Name or "Button"
    button.Font = Enum.Font.SourceSans
    button.TextScaled = true
    button.TextColor3 = config.TextColor or Color3.new(1,1,1)
    button.Parent = tab.Frame

    button.MouseButton1Click:Connect(function()
        if config.Callback then
            pcall(config.Callback)
        end
    end)
    
    return button
end

-- Create a Toggle element inside a tab
-- config: { Name = "Toggle", CurrentValue = false, Callback = function(newValue) ... end }
function NanoUI:CreateToggle(tab, config)
    config = config or {}
    local toggle = {}
    toggle.Value = config.CurrentValue or false

    local toggleFrame = Instance.new("Frame")
    toggleFrame.Name = config.Name or "Toggle"
    toggleFrame.Size = UDim2.new(0, 200, 0, 40)
    toggleFrame.BackgroundColor3 = config.ToggleColor or Color3.fromRGB(60, 60, 60)
    toggleFrame.BorderSizePixel = 0
    toggleFrame.Parent = tab.Frame

    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = config.Name or "Toggle"
    label.Font = Enum.Font.SourceSans
    label.TextScaled = true
    label.TextColor3 = config.TextColor or Color3.new(1,1,1)
    label.Parent = toggleFrame

    local button = Instance.new("TextButton")
    button.Name = "Button"
    button.Size = UDim2.new(0.3, 0, 1, 0)
    button.Position = UDim2.new(0.7, 0, 0, 0)
    button.BackgroundColor3 = toggle.Value and (config.EnabledColor or Color3.fromRGB(0, 146, 214)) or (config.DisabledColor or Color3.fromRGB(100, 100, 100))
    button.BorderSizePixel = 0
    button.Text = toggle.Value and "ON" or "OFF"
    button.Font = Enum.Font.SourceSansBold
    button.TextScaled = true
    button.TextColor3 = config.TextColor or Color3.new(1,1,1)
    button.Parent = toggleFrame

    button.MouseButton1Click:Connect(function()
         toggle.Value = not toggle.Value
         button.BackgroundColor3 = toggle.Value and (config.EnabledColor or Color3.fromRGB(0,146,214)) or (config.DisabledColor or Color3.fromRGB(100,100,100))
         button.Text = toggle.Value and "ON" or "OFF"
         if config.Callback then
             pcall(config.Callback, toggle.Value)
         end
    end)
    
    return toggle
end

-- Create a Slider element inside a tab
-- config: { Name = "Slider", Range = {min, max}, CurrentValue = number, Callback = function(newValue) ... end }
function NanoUI:CreateSlider(tab, config)
    config = config or {}
    local slider = {}
    slider.Value = config.CurrentValue or config.Range[1] or 0

    local sliderFrame = Instance.new("Frame")
    sliderFrame.Name = config.Name or "Slider"
    sliderFrame.Size = UDim2.new(0, 200, 0, 40)
    sliderFrame.BackgroundColor3 = config.SliderColor or Color3.fromRGB(60, 60, 60)
    sliderFrame.BorderSizePixel = 0
    sliderFrame.Parent = tab.Frame

    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(0.4, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = config.Name or "Slider"
    label.Font = Enum.Font.SourceSans
    label.TextScaled = true
    label.TextColor3 = config.TextColor or Color3.new(1,1,1)
    label.Parent = sliderFrame

    local bar = Instance.new("Frame")
    bar.Name = "Bar"
    bar.Size = UDim2.new(0.6, -10, 0.3, 0)
    bar.Position = UDim2.new(0.4, 5, 0.35, 0)
    bar.BackgroundColor3 = config.BarColor or Color3.fromRGB(30, 30, 30)
    bar.BorderSizePixel = 0
    bar.Parent = sliderFrame

    local progress = Instance.new("Frame")
    progress.Name = "Progress"
    local percent = (slider.Value - config.Range[1])/(config.Range[2]-config.Range[1])
    progress.Size = UDim2.new(percent, 0, 1, 0)
    progress.BackgroundColor3 = config.ProgressColor or Color3.fromRGB(0, 146, 214)
    progress.BorderSizePixel = 0
    progress.Parent = bar

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Name = "ValueLabel"
    valueLabel.Size = UDim2.new(0.3, 0, 1, 0)
    valueLabel.Position = UDim2.new(0.7, 0, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(math.floor(slider.Value))
    valueLabel.Font = Enum.Font.SourceSans
    valueLabel.TextScaled = true
    valueLabel.TextColor3 = config.TextColor or Color3.new(1,1,1)
    valueLabel.Parent = sliderFrame

    -- Basic dragging functionality for the slider bar
    local UserInputService = game:GetService("UserInputService")
    bar.InputBegan:Connect(function(input)
       if input.UserInputType == Enum.UserInputType.MouseButton1 then
           local connection
           connection = UserInputService.InputChanged:Connect(function(m)
              local relativePos = m.Position.X - bar.AbsolutePosition.X
              local newPercent = math.clamp(relativePos / bar.AbsoluteSize.X, 0, 1)
              slider.Value = config.Range[1] + newPercent * (config.Range[2] - config.Range[1])
              progress.Size = UDim2.new(newPercent, 0, 1, 0)
              valueLabel.Text = tostring(math.floor(slider.Value))
              if config.Callback then
                  pcall(config.Callback, slider.Value)
              end
           end)
           input.Changed:Connect(function(prop)
              if prop == "UserInputState" and input.UserInputState == Enum.UserInputState.End then
                  connection:Disconnect()
              end
           end)
       end
    end)

    return slider
end

return NanoUI