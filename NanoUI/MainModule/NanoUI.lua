-- NanoUI - A custom UI library inspired by Rayfield with customizable header buttons
-- Author: YourNameHere
-- Date: YYYY-MM-DD

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local NanoUI = {}
NanoUI.__index = NanoUI

-- Create a new NanoUI instance (i.e. a window)
function NanoUI.new(config)
    config = config or {}
    
    local self = setmetatable({}, NanoUI)
    
    -- Default Animation Configuration (can be overridden via config.AnimationConfig)
    local defaultAnimations = {
        close = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        minimize = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
        maximize = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
    }
    self.AnimationConfig = config.AnimationConfig or defaultAnimations

    -- Default Reopen key (if window is closed, press this key to bring it back)
    self.ReopenKey = config.ReopenKey or "N"
    self.ReopenKeyCode = Enum.KeyCode[self.ReopenKey] or Enum.KeyCode.N

    self.WindowState = "open" -- possible states: "open", "minimized", "closed"
    
    -- Create the ScreenGui (parented to CoreGui if not in Studio)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = config.Name or "NanoUI_Window"
    if not game:GetService("RunService"):IsStudio() then
        screenGui.Parent = game:GetService("CoreGui")
    else
        screenGui.Parent = game:GetService("StarterGui")
    end

    -- Main window frame
    local window = Instance.new("Frame")
    window.Name = "Window"
    window.Size = UDim2.new(0, 600, 0, 400)
    window.Position = UDim2.new(0.5, -300, 0.5, -200)
    window.BackgroundColor3 = config.BackgroundColor or Color3.fromRGB(30, 30, 30)
    window.BorderSizePixel = 0
    window.Parent = screenGui

    -- Store the original position for later use in reopening animations.
    self.OriginalPosition = window.Position

    -- Topbar with title label
    local topbar = Instance.new("Frame")
    topbar.Name = "Topbar"
    topbar.Size = UDim2.new(1, 0, 0, 40)
    topbar.BackgroundColor3 = config.TopbarColor or Color3.fromRGB(45, 45, 45)
    topbar.BorderSizePixel = 0
    topbar.Parent = window

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, 0, 1, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = config.Name or "NanoUI"
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.TextScaled = true
    titleLabel.TextColor3 = config.TextColor or Color3.new(1, 1, 1)
    titleLabel.Parent = topbar

    ------------------------------
    -- Create Customizable Header Buttons
    ------------------------------
    self.HeaderButtons = {}
    local headerConfig = config.HeaderButtons or {}
    local defaultClose = {
        Type = "Text",
        Text = "X",
        Color = Color3.new(1, 0, 0),
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -35, 0, 5),
        Font = Enum.Font.SourceSansBold,
        TextScaled = true,
    }
    local defaultMinimize = {
        Type = "Text",
        Text = "-",
        Color = Color3.new(1, 1, 1),
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -70, 0, 5),
        Font = Enum.Font.SourceSansBold,
        TextScaled = true,
    }
    local closeSettings = headerConfig.close or defaultClose
    local minimizeSettings = headerConfig.minimize or defaultMinimize

    local function createButton(settings)
        if settings.Type == "Image" then
            local btn = Instance.new("ImageButton")
            btn.Name = settings.Name or "HeaderButton"
            btn.Size = settings.Size or defaultClose.Size
            btn.Position = settings.Position or UDim2.new(1, 0, 0, 0)
            btn.BackgroundTransparency = 1
            btn.Image = settings.Image or ""
            return btn
        else
            local btn = Instance.new("TextButton")
            btn.Name = settings.Name or "HeaderButton"
            btn.Size = settings.Size or UDim2.new(0, 30, 0, 30)
            btn.Position = settings.Position or UDim2.new(1, 0, 0, 0)
            btn.BackgroundTransparency = 1
            btn.Text = settings.Text or ""
            btn.TextColor3 = settings.Color or Color3.new(1, 1, 1)
            btn.Font = settings.Font or Enum.Font.SourceSansBold
            btn.TextScaled = settings.TextScaled == nil and true or settings.TextScaled
            return btn
        end
    end

    -- Create Close Button
    local closeButton = createButton(closeSettings)
    closeButton.Parent = topbar
    closeButton.MouseButton1Click:Connect(function()
        self:Close()
    end)
    self.CloseButton = closeButton

    -- Create Minimize Button
    local minimizeButton = createButton(minimizeSettings)
    minimizeButton.Parent = topbar
    minimizeButton.MouseButton1Click:Connect(function()
        self:ToggleMinimize()
    end)
    self.MinimizeButton = minimizeButton

    -- Bind input for reopening the window if closed (default key "N")
    UserInputService.InputBegan:Connect(function(input, processed)
        --print("KEY PROCESSED: ", processed)
        --print("KEY PRESSED: ", input.KeyCode)
        --print("WINDOW STATE BEFORE: ", self.WindowState)
        if not processed and input.KeyCode == self.ReopenKeyCode then
            print("WINDOW STATE NOW: ", self.WindowState)
            print("KEY: ", self.ReopenKeyCode)
            if self.WindowState == "closed" then
                self:Reopen()
            end
        end
    end)

    ------------------------------
    -- Dragging
    ------------------------------
    local dragging = false
    local dragInput, dragStart, startPos

    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = window.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    topbar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    ------------------------------
    -- Create Tab and Content Containers
    ------------------------------
    local tabContainer = Instance.new("Frame")
    tabContainer.Name = "TabContainer"
    tabContainer.Size = UDim2.new(0, 150, 1, -40)
    tabContainer.Position = UDim2.new(0, 0, 0, 40)
    tabContainer.BackgroundColor3 = config.TabContainerColor or Color3.fromRGB(35, 35, 35)
    tabContainer.BorderSizePixel = 0
    tabContainer.Parent = window

    local contentContainer = Instance.new("Frame")
    contentContainer.Name = "ContentContainer"
    contentContainer.Size = UDim2.new(1, -150, 1, -40)
    contentContainer.Position = UDim2.new(0, 150, 0, 40)
    contentContainer.BackgroundColor3 = config.ContentColor or Color3.fromRGB(25, 25, 25)
    contentContainer.BorderSizePixel = 0
    contentContainer.Parent = window

    self.Window = window
    self.TabContainer = tabContainer
    self.ContentContainer = contentContainer
    self.Tabs = {}   -- table to store custom tabs
    self.CurrentTab = nil

    -- For minimize/restore animations, store full window size and position.
    self.FullSize = window.Size
    self.FullPosition = window.Position
    self.Minimized = false

    return self
end

-- Create a new tab. Each tab gets a button in the TabContainer and a ScrollingFrame for content.
function NanoUI:CreateTab(tabName, icon)
    local tabId = #self.Tabs + 1

    local tabButton = Instance.new("TextButton")
    tabButton.Name = "TabButton_"..tabId
    tabButton.Size = UDim2.new(1, 0, 0, 40)
    tabButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    tabButton.BorderSizePixel = 0
    tabButton.Text = tabName
    tabButton.TextColor3 = Color3.new(1, 1, 1)
    tabButton.Font = Enum.Font.SourceSansBold
    tabButton.TextScaled = true
    tabButton.Parent = self.TabContainer

    -- Create a scrolling content frame for the elements of the tab
    local tabContent = Instance.new("ScrollingFrame")
    tabContent.Name = "TabContent_"..tabName
    tabContent.Size = UDim2.new(1, 0, 1, 0)
    tabContent.BackgroundTransparency = 1
    tabContent.BorderSizePixel = 0
    tabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
    tabContent.ScrollBarThickness = 6
    tabContent.Parent = self.ContentContainer
    tabContent.Visible = false

    -- UIListLayout automatically arranges children vertically with a gap
    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 10)
    listLayout.Parent = tabContent
    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        tabContent.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y)
    end)

    local tab = {
        Name = tabName,
        Button = tabButton,
        Content = tabContent,
        ListLayout = listLayout,
        Elements = {}
    }
    table.insert(self.Tabs, tab)

    -- Clicking the tab button switches to that tab.
    tabButton.MouseButton1Click:Connect(function()
        self:SwitchTab(tab)
    end)
    
    if not self.CurrentTab then
        self:SwitchTab(tab)
    end

    return tab
end

function NanoUI:SwitchTab(tab)
    for _, t in ipairs(self.Tabs) do
        t.Content.Visible = false
        t.Button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    end
    self.CurrentTab = tab
    tab.Content.Visible = true
    tab.Button.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
end

-- Create a Button element within a given tab
function NanoUI:CreateButton(tab, config)
    config = config or {}
    local button = Instance.new("TextButton")
    button.Name = config.Name or "Button"
    button.Size = UDim2.new(1, -20, 0, 40)
    button.BackgroundColor3 = config.ButtonColor or Color3.fromRGB(50, 50, 50)
    button.BorderSizePixel = 0
    button.Text = config.Name or "Button"
    button.TextColor3 = config.TextColor or Color3.new(1, 1, 1)
    button.Font = Enum.Font.SourceSansBold
    button.TextScaled = true
    button.LayoutOrder = #tab.Elements + 1
    button.Parent = tab.Content
    
    button.MouseButton1Click:Connect(function()
        if config.Callback then
            pcall(config.Callback)
        end
    end)
    
    table.insert(tab.Elements, button)
    return button
end

-- Create a Toggle element within a given tab
function NanoUI:CreateToggle(tab, config)
    config = config or {}
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Name = config.Name or "Toggle"
    toggleFrame.Size = UDim2.new(1, -20, 0, 40)
    toggleFrame.BackgroundTransparency = 1
    toggleFrame.LayoutOrder = #tab.Elements + 1
    toggleFrame.Parent = tab.Content

    local label = Instance.new("TextLabel")
    label.Name = "ToggleLabel"
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = config.Name or "Toggle"
    label.TextColor3 = config.TextColor or Color3.new(1, 1, 1)
    label.Font = Enum.Font.SourceSans
    label.TextScaled = true
    label.Parent = toggleFrame

    local toggleButton = Instance.new("TextButton")
    toggleButton.Name = "ToggleButton"
    toggleButton.Size = UDim2.new(0.25, 0, 0.6, 0)
    toggleButton.Position = UDim2.new(0.75, 0, 0.2, 0)
    local state = config.CurrentValue or false
    toggleButton.Text = state and "ON" or "OFF"
    toggleButton.TextColor3 = Color3.new(1, 1, 1)
    toggleButton.BackgroundColor3 = config.ToggleColor or Color3.fromRGB(50, 50, 50)
    toggleButton.Font = Enum.Font.SourceSansBold
    toggleButton.TextScaled = true
    toggleButton.Parent = toggleFrame

    toggleButton.MouseButton1Click:Connect(function()
        state = not state
        toggleButton.Text = state and "ON" or "OFF"
        if config.Callback then
            pcall(config.Callback, state)
        end
    end)
    
    table.insert(tab.Elements, toggleFrame)
    return {Frame = toggleFrame, Button = toggleButton, Label = label, Get = function() return state end}
end

-- Create a Slider element within a given tab with dragging functionality.
function NanoUI:CreateSlider(tab, config)
    config = config or {}
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Name = config.Name or "Slider"
    sliderFrame.Size = UDim2.new(1, -20, 0, 50)
    sliderFrame.BackgroundTransparency = 1
    sliderFrame.LayoutOrder = #tab.Elements + 1
    sliderFrame.Parent = tab.Content

    local label = Instance.new("TextLabel")
    label.Name = "SliderLabel"
    label.Size = UDim2.new(0.4, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = config.Name or "Slider"
    label.TextColor3 = config.TextColor or Color3.new(1, 1, 1)
    label.Font = Enum.Font.SourceSans
    label.TextScaled = true
    label.Parent = sliderFrame

    local sliderBackground = Instance.new("Frame")
    sliderBackground.Name = "SliderBackground"
    sliderBackground.Size = UDim2.new(0.55, 0, 0.4, 0)
    sliderBackground.Position = UDim2.new(0.45, 0, 0.3, 0)
    sliderBackground.BackgroundColor3 = config.SliderBackground or Color3.fromRGB(50, 50, 50)
    sliderBackground.BorderSizePixel = 0
    sliderBackground.Parent = sliderFrame

    local sliderProgress = Instance.new("Frame")
    sliderProgress.Name = "SliderProgress"
    local initPercent = (config.CurrentValue - config.Range[1])/(config.Range[2] - config.Range[1])
    sliderProgress.Size = UDim2.new(initPercent, 0, 1, 0)
    sliderProgress.BackgroundColor3 = config.ProgressColor or Color3.fromRGB(0, 146, 214)
    sliderProgress.BorderSizePixel = 0
    sliderProgress.Parent = sliderBackground

    local valueText = Instance.new("TextLabel")
    valueText.Name = "ValueText"
    valueText.Size = UDim2.new(0.4, 0, 1, 0)
    valueText.Position = UDim2.new(0.6, 0, 0, 0)
    valueText.BackgroundTransparency = 1
    valueText.Text = tostring(math.floor(config.CurrentValue))
    valueText.TextColor3 = config.TextColor or Color3.new(1, 1, 1)
    valueText.Font = Enum.Font.SourceSans
    valueText.TextScaled = true
    valueText.Parent = sliderFrame

    local slider = {Value = config.CurrentValue}
    local UserInputService = game:GetService("UserInputService")
    sliderBackground.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local connection
            connection = UserInputService.InputChanged:Connect(function(m)
                local relativePos = m.Position.X - sliderBackground.AbsolutePosition.X
                local newPercent = math.clamp(relativePos / sliderBackground.AbsoluteSize.X, 0, 1)
                slider.Value = config.Range[1] + newPercent * (config.Range[2] - config.Range[1])
                sliderProgress.Size = UDim2.new(newPercent, 0, 1, 0)
                valueText.Text = tostring(math.floor(slider.Value))
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
    
    table.insert(tab.Elements, sliderFrame)
    return slider
end

-- Create a Section label to separate groups of elements.
function NanoUI:CreateSection(tab, config)
    config = config or {}
    local sectionFrame = Instance.new("Frame")
    sectionFrame.Name = config.Title or "Section"
    sectionFrame.Size = UDim2.new(1, -20, 0, 30)
    sectionFrame.BackgroundTransparency = 1
    sectionFrame.LayoutOrder = #tab.Elements + 1
    sectionFrame.Parent = tab.Content

    local sectionLabel = Instance.new("TextLabel")
    sectionLabel.Name = "SectionLabel"
    sectionLabel.Size = UDim2.new(1, 0, 1, 0)
    sectionLabel.BackgroundTransparency = 1
    sectionLabel.Text = config.Title or "Section"
    sectionLabel.TextColor3 = config.TextColor or Color3.fromRGB(200, 200, 200)
    sectionLabel.Font = Enum.Font.SourceSans
    sectionLabel.TextScaled = true
    sectionLabel.Parent = sectionFrame

    table.insert(tab.Elements, sectionFrame)
    return sectionFrame
end

-- Closes the window with a closing tween
function NanoUI:Close()
    if not self.Window then return end
    print("CLOSING WINDOW...")
    local tween = TweenService:Create(self.Window, self.AnimationConfig.close, {
        BackgroundTransparency = 1,
        Position = UDim2.new(self.Window.Position.X.Scale, self.Window.Position.X.Offset, 1, 0)
    })
    self.WindowState = "closed"
    print("GUI STATE: ", self.WindowState)
    tween:Play()
    --[[tween.Completed:Connect(function()
        self.Window:Destroy()
    end)]]
end

-- Toggles between minimized and maximized states.
function NanoUI:ToggleMinimize()
    if not self.Window then return end
    if self.Minimized then
        -- Restore window size and position (maximize)
        self.ContentContainer.Visible = true
        local tween = TweenService:Create(self.Window, self.AnimationConfig.maximize, {
            Size = self.FullSize,
            Position = self.FullPosition
        })
        tween:Play()
        tween.Completed:Connect(function()
            self.Minimized = false
        end)
    else
        -- Store the current full size/position then minimize.
        self.FullSize = self.Window.Size
        self.FullPosition = self.Window.Position
        local tween = TweenService:Create(self.Window, self.AnimationConfig.minimize, {
            Size = UDim2.new(self.Window.Size.X.Scale, self.Window.Size.X.Offset, 0, 40)
        })
        tween:Play()
        tween.Completed:Connect(function()
            self.ContentContainer.Visible = false
            self.Minimized = true
        end)
    end
end

-- Reopen the window if it was closed.
function NanoUI:Reopen()
    if self.WindowState == "closed" then
        self.Window.Visible = true
        
        -- Set the window to the "closed" off-screen state first.
        -- Matching your close tween, we assume BackgroundTransparency was set to 1
        -- and the position was moved offscreen (for example, off the bottom)
        self.Window.Position = UDim2.new(self.Window.Position.X.Scale, self.Window.Position.X.Offset, 1, 0)
        self.Window.BackgroundTransparency = 1
        
        -- Create an "open" tween that returns the window to its original (centered) position
        local openTween = TweenService:Create(self.Window, self.AnimationConfig.maximize, {
            Position = self.OriginalPosition,  -- center it
            BackgroundTransparency = 0         -- restore original transparency
        })
        openTween:Play()
        
        self.WindowState = "open"
    end
end

return NanoUI