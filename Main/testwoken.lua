-- Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

-- Variables
local thrownFolder = Workspace:FindFirstChild("Thrown")

-- Function to create a highlight for a model
local function createHighlight(object, fillColor, outlineColor)
    if not object:FindFirstChildOfClass("Highlight") then
        local highlight = Instance.new("Highlight")
        highlight.Parent = object
        highlight.Adornee = object
        highlight.FillColor = fillColor
        highlight.OutlineColor = outlineColor
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0.5
    end
end

-- Function to remove highlight from a model
local function removeHighlight(object)
    local highlight = object:FindFirstChildOfClass("Highlight")
    if highlight then
        highlight:Destroy()
    end
end

-- Function to update highlights based on conditions
local function updateHighlights()
    if thrownFolder then
        for _, model in pairs(thrownFolder:GetChildren()) do
            -- Check if the model has a child named "Lid"
            if model:IsA("Model") and model:FindFirstChild("Lid") then
                createHighlight(model, Color3.fromRGB(255, 101, 27), Color3.fromRGB(255, 255, 255)) -- Default colors
            else
                removeHighlight(model)
            end
        end
    end
end

-- Call the function to update highlights initially
updateHighlights()

-- Optional: Connect to an event if the "Thrown" folder's content may change dynamically
thrownFolder.ChildAdded:Connect(updateHighlights)
thrownFolder.ChildRemoved:Connect(updateHighlights)
