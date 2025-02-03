local ThemeManager = {
    CurrentTheme = {
        PrimaryColor = Color3.fromRGB(25, 25, 25),
        Font = Enum.Font.Gotham,
        TextSize = 14
    }
}

function ThemeManager.Apply(theme)
    for key, value in pairs(theme) do
        ThemeManager.CurrentTheme[key] = value
    end
    -- Apply theme to all UI elements here
end

return ThemeManager