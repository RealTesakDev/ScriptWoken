-- Services 
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting") -- To adjust brightness and fog
local TeleportService = game:GetService("TeleportService") -- For rejoining the server

-- Player and Camera
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local camera = Workspace.CurrentCamera

-- Movement Variables
local walkSpeed = 0 -- Speed in studs per second
local movementDirection = Vector3.new(0, 0, 0)

-- Highlight Functionality Variables
local highlightFillColor = Color3.fromRGB(255, 101, 27) -- Default fill color
local outlineColor = Color3.fromRGB(255, 255, 255) -- Default white outline color
local highlightPlayersEnabled = false
local highlightMobsEnabled = false
local highlightItemsEnabled = false
local chestHighlightEnabled = false

-- Spectate Functionality Variables
local spectatePlayerName = "" -- Player name to spectate
local spectatePlayerEnabled = false

-- UI Setup (Dollarware)
local uiLoader = loadstring(game:HttpGet('https://raw.githubusercontent.com/topitbopit/dollarware/main/library.lua'))
local ui = uiLoader({ rounding = false, theme = 'cherry', smoothDragging = false })
ui.autoDisableToggles = true

-- Functions --

-- Create and remove highlights
local function createHighlight(object, fillColor, outlineColor)
    if not object:FindFirstChildOfClass("Highlight") then
        local highlight = Instance.new("Highlight")
        highlight.Parent = object
        highlight.Adornee = object
        highlight.FillColor = fillColor or highlightFillColor
        highlight.OutlineColor = outlineColor or outlineColor
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0.5
    end
end

local function removeHighlight(object)
    local highlight = object:FindFirstChildOfClass("Highlight")
    if highlight then highlight:Destroy() end
end

-- Update all highlights
local function updateHighlights()
    local liveFolder = Workspace:FindFirstChild("Live")
    local shopsFolder = Workspace:FindFirstChild("Shops")
    local thrownFolder = Workspace:FindFirstChild("Thrown")

    local playerNames = {}
    for _, p in pairs(Players:GetPlayers()) do
        playerNames[p.Name] = true
    end

    -- Players Highlight
    if highlightPlayersEnabled then
        for _, p in pairs(Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                createHighlight(p.Character, highlightFillColor, outlineColor)
            end
        end
    else
        for _, p in pairs(Players:GetPlayers()) do
            if p.Character then removeHighlight(p.Character) end
        end
    end

    -- Mobs Highlight
    if highlightMobsEnabled and liveFolder then
        for _, mob in pairs(liveFolder:GetChildren()) do
            if not playerNames[mob.Name] then
                createHighlight(mob, highlightFillColor, outlineColor)
            end
        end
    elseif liveFolder then
        for _, mob in pairs(liveFolder:GetChildren()) do removeHighlight(mob) end
    end

    -- Items Highlight
    if highlightItemsEnabled and shopsFolder then
        for _, item in pairs(shopsFolder:GetChildren()) do
            createHighlight(item, highlightFillColor, outlineColor)
        end
    elseif shopsFolder then
        for _, item in pairs(shopsFolder:GetChildren()) do removeHighlight(item) end
    end

    -- Chest Highlight
    if chestHighlightEnabled and thrownFolder then
        for _, model in pairs(thrownFolder:GetChildren()) do
            if model:IsA("Model") and model:FindFirstChild("Lid") then
                createHighlight(model, highlightFillColor, outlineColor)
            else
                removeHighlight(model)
            end
        end
    elseif thrownFolder then
        for _, model in pairs(thrownFolder:GetChildren()) do removeHighlight(model) end
    end
end

-- Update highlight colors dynamically
local function updateHighlightColors(newFillColor, newOutlineColor)
    highlightFillColor = newFillColor or highlightFillColor
    outlineColor = newOutlineColor or outlineColor
    updateHighlights() -- Apply new colors immediately
end

-- Spectate Functionality
local function spectatePlayer(playerName)
    local targetPlayer = Players:FindFirstChild(playerName)
    if targetPlayer and targetPlayer.Character then
        camera.CameraSubject = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
    else
        ui.notify({ title = 'Spectate Error', message = 'Player not found or character not loaded.', duration = 3 })
    end
end

local function stopSpectating()
    camera.CameraSubject = character:FindFirstChildOfClass("Humanoid")
end

-- Walking Stuff
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

-- UI Setup --

-- Create the main window
local window = ui.newWindow({ text = 'Deepwoven', resize = true, size = Vector2.new(550, 376) })

-- Visuals Menu
local visualsMenu = window:addMenu({ text = 'Visuals' })

-- Visuals Section 1
local section1 = visualsMenu:addSection({ text = 'Visuals Section 1', side = 'left', showMinButton = true })
section1:addToggle({ text = 'Highlight Players', state = false })
    :bindToEvent('onToggle', function(newState) highlightPlayersEnabled = newState; updateHighlights() end)

section1:addToggle({ text = 'Mob ESP', state = false })
    :bindToEvent('onToggle', function(newState) highlightMobsEnabled = newState; updateHighlights() end)

section1:addToggle({ text = 'Buyable Item ESP', state = false })
    :bindToEvent('onToggle', function(newState) highlightItemsEnabled = newState; updateHighlights() end)

-- Visuals Section 2
local section2 = visualsMenu:addSection({ text = 'Visuals Section 2', side = 'right', showMinButton = true })
section2:addSlider({ text = 'Adjust Brightness', min = 0, max = 100, step = 1, val = 50 })
    :bindToEvent('onValueChanged', function(newValue) Lighting.Brightness = newValue / 100 end)

section2:addButton({ text = 'Remove Fog', style = 'large' })
    :bindToEvent('onClick', function() Lighting.FogEnd = 100000 end)

section2:addColorPicker({ text = 'Highlight Fill Color', color = highlightFillColor })
    :bindToEvent('onColorChanged', function(newColor) updateHighlightColors(newColor, nil) end)

section2:addColorPicker({ text = 'Outline Color', color = outlineColor })
    :bindToEvent('onColorChanged', function(newColor) updateHighlightColors(nil, newColor) end)

-- Loot ESP Section
local lootESPSection = visualsMenu:addSection({ text = 'Loot ESP', side = 'left', showMinButton = true })
lootESPSection:addToggle({ text = 'Chest ESP', state = false })
    :bindToEvent('onToggle', function(newState) chestHighlightEnabled = newState; updateHighlights() end)

-- Player Menu
local playerMenu = window:addMenu({ text = 'Player' })

-- Player Settings Section
local section1 = playerMenu:addSection({ text = 'Player Settings', side = 'left', showMinButton = true })
section1:addButton({ text = 'Rejoin Server', style = 'large' })
    :bindToEvent('onClick', function() TeleportService:Teleport(game.PlaceId, player) end)

local spectateToggle = section1:addToggle({ text = 'Spectate Player', state = false })
local playerNameTextbox = section1:addTextbox({ text = 'Player Name' })

spectateToggle:bindToEvent('onToggle', function(newState)
    spectatePlayerEnabled = newState
    spectatePlayerName = playerNameTextbox:getText()
    if spectatePlayerEnabled then
        spectatePlayer(spectatePlayerName)
    else
        stopSpectating()
    end
end)

playerNameTextbox:bindToEvent('onTextChanged', function(newText)
    spectatePlayerName = newText
    if spectatePlayerEnabled then
        spectatePlayer(spectatePlayerName)
    end
end)

section2:addSlider({
        text = 'Adjust Speed',
        min = 1,
        max = 250,
        step = 1,
        val = 10
    }, function(value)
        walkSpeed = value -- Update the walkSpeed variable based on the slider value
        print("Speed set to:", value)
    end)

-- Main Loop --

RunService.RenderStepped:Connect(function(deltaTime)
    updateMovementDirection()
    moveCharacter(deltaTime)
end)
