-- Core.lua
local Rayfield = {Windows = {}}

function Rayfield:CreateWindow(options)
    local Window = {Elements = {}}
    options = options or {}
    
    -- Create main GUI container
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "NanoUI"
    ScreenGui.Parent = game:GetService("CoreGui")
    
    -- Main window frame
    local WindowFrame = Instance.new("Frame")
    WindowFrame.Name = "Window"
    WindowFrame.Size = UDim2.new(0, 500, 0, 400)
    WindowFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
    WindowFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    WindowFrame.Parent = ScreenGui
    
    -- Window title
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Text = options.Name or "Window"
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.Font = Enum.Font.GothamBold
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.BackgroundTransparency = 1
    Title.Parent = WindowFrame
    
    -- Elements container
    local ElementsList = Instance.new("UIListLayout")
    ElementsList.Parent = WindowFrame
    ElementsList.Padding = UDim.new(0, 10)
    
    function Window:CreateButton(options)
        local Button = {Name = options.Name or "Button"}
        
        local ButtonFrame = Instance.new("TextButton")
        ButtonFrame.Name = "Button"
        ButtonFrame.Size = UDim2.new(1, -40, 0, 40)
        ButtonFrame.Position = UDim2.new(0, 20, 0, 50)
        ButtonFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        ButtonFrame.Font = Enum.Font.Gotham
        ButtonFrame.TextColor3 = Color3.new(1, 1, 1)
        ButtonFrame.Text = options.Name or "Button"
        ButtonFrame.Parent = WindowFrame
        
        if options.Callback then
            ButtonFrame.MouseButton1Click:Connect(options.Callback)
        end
        
        table.insert(self.Elements, Button)
        return Button
    end
    
    function Window:CreateToggle(options)
        local Toggle = {Value = options.Default or false}
        
        local ToggleFrame = Instance.new("TextButton")
        ToggleFrame.Name = "Toggle"
        ToggleFrame.Size = UDim2.new(1, -40, 0, 40)
        ToggleFrame.Position = UDim2.new(0, 20, 0, 100)
        ToggleFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        ToggleFrame.Font = Enum.Font.Gotham
        ToggleFrame.Text = (options.Name or "Toggle") .. ": Off"
        ToggleFrame.TextColor3 = Color3.new(1, 1, 1)
        ToggleFrame.Parent = WindowFrame
        
        local function UpdateToggle()
            Toggle.Value = not Toggle.Value
            ToggleFrame.Text = (options.Name or "Toggle") .. (Toggle.Value and ": On" or ": Off")
            if options.Callback then
                options.Callback(Toggle.Value)
            end
        end
        
        ToggleFrame.MouseButton1Click:Connect(UpdateToggle)
        
        table.insert(self.Elements, Toggle)
        return Toggle
    end
    
    table.insert(self.Windows, Window)
    return Window
end

return function()
    return Rayfield
end