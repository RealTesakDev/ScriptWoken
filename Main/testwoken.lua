local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local workspace = game:GetService("Workspace")

-- Load and initialize the Dollarware UI Library
loadstring(game:HttpGet('https://raw.githubusercontent.com/Dollarware-UI/Roblox-Library/main/DollarwareLib.lua'))()
local Library = DollarwareLib()

-- Create the main UI window
local Window = Library:CreateWindow({
    Title = "ESP & Highlight Settings",
    Size = UDim2.new(0, 425, 0, 512)
})

-- Create a "Visuals" tab
local VisualsTab = Window:AddTab("Visuals")

-- Create sections for ESP and Highlight features
local ESPSection = VisualsTab:AddSection("ESP Settings")
local HighlightSection = VisualsTab:AddSection("Highlight Settings")

-- UI Toggles and Colors
local highlightToggle, nameToggle, distanceToggle
local espFontSize = 14 -- Default ESP font size
local espFont = Enum.Font.SourceSans -- Default ESP font
local highlightColor = Color3.new(0, 1, 0) -- Default highlight color (Green)
local espTextColor = Color3.new(1, 1, 1) -- Default ESP text color (White)

-- Add options to change highlight and ESP properties

-- Toggle for enabling/disabling highlights
HighlightSection:AddToggle("Highlight Players", function(value)
    highlightToggle = value
end)

-- Color picker for highlight color
HighlightSection:AddColorPicker("Highlight Color", highlightColor, function(color)
    highlightColor = color
end)

-- Toggle for showing player names
ESPSection:AddToggle("Show Player Name", function(value)
    nameToggle = value
end)

-- Toggle for showing player distance
ESPSection:AddToggle("Show Player Distance", function(value)
    distanceToggle = value
end)

-- Color picker for ESP text color
ESPSection:AddColorPicker("ESP Text Color", espTextColor, function(color)
    espTextColor = color
end)

-- Slider for ESP font size
ESPSection:AddSlider("ESP Font Size", {min = 10, max = 30, default = espFontSize}, function(value)
    espFontSize = value
end)

-- Dropdown for ESP font selection
ESPSection:AddDropdown("ESP Font", {Enum.Font.SourceSans, Enum.Font.Gotham, Enum.Font.Arial}, function(font)
    espFont = font
end)

-- Function to create or update a highlight for a player
function UpdateHighlightForPlayer(Model)
    -- Remove existing highlights if any
    for _, child in pairs(Model:GetChildren()) do
        if child:IsA("Highlight") then
            child:Destroy()
        end
    end

    if highlightToggle then
        local highlight = Instance.new("Highlight")
        highlight.Adornee = Model
        highlight.FillColor = highlightColor -- Use the selected highlight color
        highlight.OutlineColor = Color3.new(1, 1, 1) -- White outline color
        highlight.Parent = Model
    end
end

-- Function to create a Billboard GUI for ESP
function CreateESP()
    local Billboard = Instance.new("BillboardGui")
    Billboard.Size = UDim2.new(0, 200, 0, 50)
    Billboard.StudsOffset = Vector3.new(0, 2, 0)
    Billboard.AlwaysOnTop = true

    -- Player name text
    local PlayerName = Instance.new("TextLabel")
    PlayerName.Name = "PlayerName"
    PlayerName.Size = UDim2.new(1, 0, 0.5, 0)
    PlayerName.BackgroundTransparency = 1
    PlayerName.TextColor3 = espTextColor -- Use the selected ESP text color
    PlayerName.TextStrokeTransparency = 0.5
    PlayerName.TextSize = espFontSize
    PlayerName.Font = espFont -- Use the selected font
    PlayerName.Parent = Billboard

    -- Player distance text
    local PlayerDistance = Instance.new("TextLabel")
    PlayerDistance.Name = "PlayerDistance"
    PlayerDistance.Size = UDim2.new(1, 0, 0.5, 0)
    PlayerDistance.Position = UDim2.new(0, 0, 0.5, 0)
    PlayerDistance.BackgroundTransparency = 1
    PlayerDistance.TextColor3 = espTextColor -- Use the selected ESP text color
    PlayerDistance.TextStrokeTransparency = 0.5
    PlayerDistance.TextSize = espFontSize
    PlayerDistance.Font = espFont -- Use the selected font
    PlayerDistance.Parent = Billboard

    return Billboard
end

local HasESP = {}

-- Function to get the player from a character model
function GetPlayerFromCharacter(character)
    return game.Players:GetPlayerFromCharacter(character)
end

-- Main loop for ESP and Highlight updates
RunService.Heartbeat:Connect(function()
    for _, model in pairs(workspace:GetChildren()) do
        if IsPlayer(model) then
            -- Handle highlight toggle
            UpdateHighlightForPlayer(model)

            -- Handle ESP (player name and distance)
            if not HasESP[model] then
                local Billboard = CreateESP()
                Billboard.Parent = model.PrimaryPart
                HasESP[model] = Billboard
            end
            
            local Billboard = HasESP[model]

            -- Update player name
            if nameToggle then
                local player = GetPlayerFromCharacter(model)
                Billboard.PlayerName.Text = player and player.Name or "None"
                Billboard.PlayerName.Visible = true
                Billboard.PlayerName.TextSize = espFontSize -- Update font size dynamically
                Billboard.PlayerName.TextColor3 = espTextColor -- Update text color dynamically
                Billboard.PlayerName.Font = espFont -- Update font dynamically
            else
                Billboard.PlayerName.Visible = false
            end

            -- Update player distance
            if distanceToggle then
                local distance = (workspace.CurrentCamera.CFrame.p - model.PrimaryPart.Position).Magnitude
                Billboard.PlayerDistance.Text = tostring(math.floor(distance)) .. "m"
                Billboard.PlayerDistance.Visible = true
                Billboard.PlayerDistance.TextSize = espFontSize -- Update font size dynamically
                Billboard.PlayerDistance.TextColor3 = espTextColor -- Update text color dynamically
                Billboard.PlayerDistance.Font = espFont -- Update font dynamically
            else
                Billboard.PlayerDistance.Visible = false
            end
        end
    end
end)
