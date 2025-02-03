local Button = {}

function Button.Create(parent, text, callback)
    local button = Instance.new("TextButton")
    button.Parent = parent
    button.Text = text
    button.Size = UDim2.new(0, 100, 0, 25)
    
    button.MouseButton1Click:Connect(callback)
    return button
end

return Button