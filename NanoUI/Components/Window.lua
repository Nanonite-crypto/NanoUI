
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

local Window = {}
Window.__index = Window

function Window.New(parent, config)
    local self = setmetatable({}, Window)
    self.Frame = Instance.new("Frame")
    self.Frame.Parent = parent
    self.Frame.Size = config.Size or UDim2.new(0, 400, 0, 300)
    self.Frame.Name = config.Title or "Untitled Window"
    
    -- Title Bar
    local titleBar = Instance.new("Frame")
    titleBar.Parent = self.Frame
    titleBar.Size = UDim2.new(1, 0, 0, 25)
    titleBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    
    local titleText = Instance.new("TextLabel")
    titleText.Parent = titleBar
    titleText.Text = self.Frame.Name
    titleText.Size = UDim2.new(1, 0, 1, 0)
    titleText.BackgroundTransparency = 1
    titleText.TextColor3 = Color3.new(1, 1, 1)
    
    -- Content Area
    local contentArea = Instance.new("ScrollingFrame")
    contentArea.Parent = self.Frame
    contentArea.Size = UDim2.new(1, 0, 1, -25)
    contentArea.Position = UDim2.new(0, 0, 0, 25)

    return self
end

function Window:AddButton(text, callback)
    local ButtonModule = safeLoadModule("https://raw.githubusercontent.com/Nanonite-crypto/NanoUI/refs/heads/main/NanoUI/Components/Button.lua")
    ButtonModule.Create(self.Frame, text, callback)
end

function Window:AddToggle(text, defaultState, callback)
local ToggleModule = safeLoadModule("https://raw.githubusercontent.com/Nanonite-crypto/NanoUI/refs/heads/main/NanoUI/Components/Toggle.lua")
    ToggleModule.Create(self.Frame, text, defaultState, callback)
end

function Window:Destroy()
    self.Frame:Destroy()
    for i, v in ipairs(getmetatable(Window).Windows) do
        if v == self then
            table.remove(getmetatable(Window).Windows, i)
            break
        end
    end
end

return Window
