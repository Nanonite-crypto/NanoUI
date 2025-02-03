local Toggle = {}

function Toggle.Create(parent, text, defaultState, callback)
    local toggle = {
        Parent = parent,  -- Where this toggle will be placed
        Text = text,
        State = defaultState or false, -- Default to off if not specified
        Callback = callback,
        Instances = {}, -- To store UI instances if needed
        
        -- Method to toggle the state
        ToggleState = function(self)
            self.State = not self.State
            if self.Callback then
                self.Callback(self.State)
            end
            -- Here you would update UI or perform actions based on the new state
            print("Toggle state changed to:", self.State)
        end,
        
        -- Method to set the state manually
        SetState = function(self, newState)
            if self.State ~= newState then
                self.State = newState
                if self.Callback then
                    self.Callback(self.State)
                end
                print("Toggle state set to:", self.State)
            end
        end,
        
        -- Method to destroy the toggle
        Destroy = function(self)
            -- Clean up any instances or references
            self.Instances = nil
            self.Callback = nil
            print("Toggle destroyed")
        end
    }
    
    -- Here you might initialize UI elements if this were a real UI system
    -- For example:
    -- local frame = Instance.new("Frame")
    -- frame.Parent = self.Parent
    -- self.Instances.Frame = frame
    
    return toggle
end

return Toggle
