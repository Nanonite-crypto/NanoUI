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

local WindowModule = {}
WindowModule.__index = WindowModule

function WindowModule.New(parent, config)
    local self = setmetatable({}, WindowModule)
    
    print("Window")
    -- Use the config parameter to set window properties
    self.Title = config.Title or "Untitled Window"
    self.Size = config.Size or {Width = 400, Height = 300}
    self.Elements = {}
    self.Parent = parent
    
    -- Initialize the window UI here, using self.Parent as the parent
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, self.Size.Width, 0, self.Size.Height)
    frame.Parent = self.Parent
    
    -- Store the frame in the window object for further manipulation
    self.Frame = frame
    
    return self
end

function WindowModule:AddButton(text, callback)
    -- Create a button and add it to self.Elements
    local button = Instance.new("TextButton")
    button.Text = text
    button.Size = UDim2.new(0, 100, 0, 50) -- Example size
    button.Parent = self.Frame
    button.MouseButton1Click:Connect(callback)
    table.insert(self.Elements, button)
    return button
end

function WindowModule:AddToggle(text, defaultState, callback)
    -- Create a toggle and add it to self.Elements
    local toggle = Instance.new("TextButton")
    toggle.Text = text
    toggle.Size = UDim2.new(0, 100, 0, 50) -- Example size
    toggle.Parent = self.Frame
    toggle.MouseButton1Click:Connect(function()
        defaultState = not defaultState
        callback(defaultState)
    end)
    table.insert(self.Elements, toggle)
    return toggle
end

function WindowModule:Destroy()
    -- Clean up all elements of the window
    print("Destroying window:", self.Title)
    if self.Frame then
        self.Frame:Destroy()
    end
    self.Elements = nil
end

return WindowModule
