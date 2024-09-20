-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local camera = Workspace.CurrentCamera

local walkSpeed = 15 -- Speed in studs per second

local movementDirection = Vector3.new(0, 0, 0)

-- Function to update the movement direction based on key inputs
local function updateMovementDirection()
    movementDirection = Vector3.new(0, 0, 0)
    
    -- Get the camera's look vector
    local cameraLookVector = camera.CFrame.LookVector
    
    -- Break down the look vector into the XZ plane
    local cameraDirection = Vector3.new(cameraLookVector.X, 0, cameraLookVector.Z).Unit

    -- Right direction relative to the camera
    local cameraRight = Vector3.new(camera.CFrame.RightVector.X, 0, camera.CFrame.RightVector.Z).Unit

    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
        movementDirection = movementDirection + cameraDirection
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
        movementDirection = movementDirection - cameraDirection
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
        movementDirection = movementDirection - cameraRight
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
        movementDirection = movementDirection + cameraRight
    end

    -- Normalize direction to ensure consistent speed
    if movementDirection.Magnitude > 0 then
        movementDirection = movementDirection.Unit
    end
end

-- Function to move the character using CFrame with increased speed
local function moveCharacter(deltaTime)
    if movementDirection.Magnitude > 0 then
        -- Calculate the new position using CFrame
        local displacement = movementDirection * walkSpeed * deltaTime
        local newCFrame = humanoidRootPart.CFrame + displacement
        humanoidRootPart.CFrame = newCFrame
    end
end

-- Input listeners to update the movement direction
UserInputService.InputBegan:Connect(updateMovementDirection)
UserInputService.InputEnded:Connect(updateMovementDirection)

-- Connect the moveCharacter function to RunService's RenderStepped for smooth movement
RunService.RenderStepped:Connect(function(deltaTime)
    updateMovementDirection()
    moveCharacter(deltaTime)
end)

-- Function to create a highlight and name display
local function highlightAndDisplayName(player)
    -- Get the player's character
    local character = player.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        -- Create highlight
        if not character:FindFirstChildOfClass("Highlight") then
            local highlight = Instance.new("Highlight")
            highlight.Parent = character
            highlight.Adornee = character
            highlight.FillColor = Color3.new(1, 1, 1) -- White color
            highlight.OutlineColor = Color3.new(1, 1, 1) -- White outline
            highlight.FillTransparency = 0.5 -- Semi-transparent
            highlight.OutlineTransparency = 0.5 -- Semi-transparent
        end

        -- Create BillboardGui to display name
        if not character:FindFirstChild("NameDisplay") then
            local billboard = Instance.new("BillboardGui")
            billboard.Name = "NameDisplay"
            billboard.Parent = character.HumanoidRootPart
            billboard.Adornee = character.HumanoidRootPart
            billboard.Size = UDim2.new(0, 200, 0, 50)
            billboard.StudsOffset = Vector3.new(0, 2, 0)
            billboard.AlwaysOnTop = true

            local textLabel = Instance.new("TextLabel")
            textLabel.Parent = billboard
            textLabel.Size = UDim2.new(1, 0, 1, 0)
            textLabel.BackgroundTransparency = 1
            textLabel.Text = player.Name
            textLabel.TextColor3 = Color3.new(1, 1, 1) -- White text color
            textLabel.TextScaled = false
            textLabel.TextSize = 25 -- Set font size here
            textLabel.Font = Enum.Font.SourceSans -- Change font type here if needed
        end
    end
end

-- Function to remove highlight and name display
local function removeHighlightAndNameDisplay(player)
    local character = player.Character
    if character then
        local highlight = character:FindFirstChildOfClass("Highlight")
        if highlight then
            highlight:Destroy()
        end

        local nameDisplay = character:FindFirstChild("NameDisplay")
        if nameDisplay then
            nameDisplay:Destroy()
        end
    end
end

-- Variable to track highlight state
local highlightEnabled = false

-- Function to update highlights periodically
local function updateHighlights()
    while highlightEnabled do
        for _, player in pairs(Players:GetPlayers()) do
            if player.Character then
                highlightAndDisplayName(player)
            end
        end
        wait(0.5) -- Adjust the delay as needed to reduce load on the system
    end
    -- Remove highlights and name displays when toggled off
    for _, player in pairs(Players:GetPlayers()) do
        removeHighlightAndNameDisplay(player)
    end
end

-- Function to toggle highlights
local function toggleHighlights(isEnabled)
    highlightEnabled = isEnabled
    if not highlightEnabled then
        -- Hide name displays when highlights are disabled
        for _, player in pairs(Players:GetPlayers()) do
            removeHighlightAndNameDisplay(player)
        end
    else
        -- Enable highlights
        updateHighlights()
    end
end

-- Connect update function to RunService's RenderStepped
RunService.RenderStepped:Connect(updateHighlights)


-- Variable to track highlight state
local NpchighlightEnabled = false

-- Function to highlight a model
local function highlightModel(model)
    if not model:FindFirstChildOfClass("Highlight") then
        local highlight = Instance.new("Highlight")
        highlight.Parent = model
        highlight.Adornee = model
        highlight.FillColor = Color3.new(1, 1, 1) -- White color
        highlight.OutlineColor = Color3.new(1, 1, 1) -- White outline
        highlight.FillTransparency = 0.5 -- Semi-transparent
        highlight.OutlineTransparency = 0.5 -- Semi-transparent
    end
end

-- Function to remove highlight from a model
local function removeHighlightFromModel(model)
    local Npchighlight = model:FindFirstChildOfClass("Highlight")
    if Npchighlight then
        Npchighlight:Destroy()
    end
end

-- Function to update highlights for all models in workspace.NPCs
local function updateModelsHighlights()
    if NpchighlightEnabled then
        for _, model in pairs(Workspace.NPCs:GetChildren()) do
            if model:IsA("Model") then
                highlightModel(model)
            end
        end
    else
        -- Remove highlights if not enabled
        for _, model in pairs(Workspace.NPCs:GetChildren()) do
            if model:IsA("Model") then
                removeHighlightFromModel(model)
            end
        end
    end
end

-- Call the update function initially to apply or remove highlights based on the toggle state
updateModelsHighlights()

-- Connect the update function to RunService's RenderStepped to continuously check and update highlights
RunService.RenderStepped:Connect(updateModelsHighlights)


-- Example usage of the toggle function
-- You can connect this to a UI toggle or other input mechanism
-- toggleHighlight(true) -- Enable highlights
-- toggleHighlight(false) -- Disable highlights



-- UI Library Setup
local Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/Rain-Design/Unnamed/main/Library.lua'))()
Library.Theme = "Dark"
local Flags = Library.Flags

local Window = Library:Window({
   Text = "Script Woken Beta 1.0"
})

local Player = Window:Tab({
   Text = "Player"
})

local Visual = Window:Tab({
   Text = "Visual"
})

local Misc = Window:Tab({
   Text = "Misc"
})

local Settings = Window:Tab({
   Text = "Settings"
})

local Movement = Player:Section({
   Text = "Movement"
})

local Visual = Visual:Section({
   Text = "Visual"
})

local Section3 = Misc:Section({
   Text = "Buttons2"
})
local Section4 = Settings:Section({
   Text = "Buttons2"
})


Movement:Slider({
    Text = "Speed",
    Default = 25,
    Minimum = 0,
    Maximum = 200,
    Callback = function(value)
        walkSpeed = value -- Update the walkSpeed variable based on the slider value
        print("Speed set to:", value)
    end
})



local drop = Movement:Dropdown({
   Text = "Choose",
   List = {"Idk", "Test"},
   Callback = function(v)
       warn(v)
   end
})

-- Visuals

Visual:Toggle({
    Text = "Players Esp",
    Callback = function(value)
        highlightEnabled = value
    end
})

Visual:Toggle({
    Text = "Npc Esp",
    Callback = function(value)
        NpchighlightEnabled = value
    end
})



Tab:Select()
