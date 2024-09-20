-- Services 
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting") -- To adjust brightness and fog
local TeleportService = game:GetService("TeleportService") -- For rejoining the server

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local camera = Workspace.CurrentCamera

local walkSpeed = 0 -- Speed in studs per second

-- Variables for highlight functionality
local highlightFillColor = Color3.fromRGB(255, 101, 27) -- Default fill color (255, 101, 27)
local outlineColor = Color3.fromRGB(255, 255, 255) -- Default white outline color
local highlightPlayersEnabled = false -- Toggle state for players
local highlightMobsEnabled = false -- Toggle state for mobs
local highlightItemsEnabled = false -- Toggle state for items
local chestHighlightEnabled = false -- Toggle state for chest highlighting

-- Variables for spectate functionality
local spectatePlayerName = "" -- Player name to spectate
local spectatePlayerEnabled = false -- Toggle state for spectating

-- Function to create a highlight
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

-- Function to remove highlight
local function removeHighlight(object)
    local highlight = object:FindFirstChildOfClass("Highlight")
    if highlight then
        highlight:Destroy()
    end
end

-- Function to update highlights dynamically
local function updateHighlights()
    local liveFolder = Workspace:FindFirstChild("Live")
    local shopsFolder = Workspace:FindFirstChild("Shops")
    local thrownFolder = Workspace:FindFirstChild("Thrown")

    -- Create a set of player names
    local playerNames = {}
    for _, p in pairs(Players:GetPlayers()) do
        playerNames[p.Name] = true
    end

    -- Highlight players
    if highlightPlayersEnabled then
        for _, p in pairs(Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                createHighlight(p.Character, highlightFillColor, outlineColor)
            end
        end
    else
        for _, p in pairs(Players:GetPlayers()) do
            if p.Character then
                removeHighlight(p.Character)
            end
        end
    end

    -- Highlight mobs
    if highlightMobsEnabled then
        if liveFolder then
            for _, mob in pairs(liveFolder:GetChildren()) do
                if not playerNames[mob.Name] then
                    createHighlight(mob, highlightFillColor, outlineColor)
                end
            end
        end
    else
        if liveFolder then
            for _, mob in pairs(liveFolder:GetChildren()) do
                removeHighlight(mob)
            end
        end
    end

    -- Highlight buyable items
    if highlightItemsEnabled then
        if shopsFolder then
            for _, item in pairs(shopsFolder:GetChildren()) do
                createHighlight(item, highlightFillColor, outlineColor)
            end
        end
    else
        if shopsFolder then
            for _, item in pairs(shopsFolder:GetChildren()) do
                removeHighlight(item)
            end
        end
    end

    -- Highlight chests
    if chestHighlightEnabled then
        if thrownFolder then
            for _, model in pairs(thrownFolder:GetChildren()) do
                if model:IsA("Model") and model:FindFirstChild("Lid") then
                    createHighlight(model, highlightFillColor, outlineColor)
                else
                    removeHighlight(model)
                end
            end
        end
    else
        if thrownFolder then
            for _, model in pairs(thrownFolder:GetChildren()) do
                removeHighlight(model)
            end
        end
    end
end

-- Function to update highlight colors
local function updateHighlightColors(newFillColor, newOutlineColor)
    highlightFillColor = newFillColor or highlightFillColor
    outlineColor = newOutlineColor or outlineColor

    -- Update the highlights for existing players, mobs, items, and chests
    updateHighlights()
end

-- Function to spectate a player
local function spectatePlayer(playerName)
    local targetPlayer = Players:FindFirstChild(playerName)
    if targetPlayer and targetPlayer.Character then
        camera.CameraSubject = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
    else
        ui.notify({
            title = 'Spectate Error',
            message = 'Player not found or character not loaded.',
            duration = 3
        })
    end
end

-- Function to stop spectating
local function stopSpectating()
    camera.CameraSubject = character:FindFirstChildOfClass("Humanoid")
end

-- Dollarware example script

-- Snag the ui loader function (loadstring the link, but don't call it)
local uiLoader = loadstring(game:HttpGet('https://raw.githubusercontent.com/topitbopit/dollarware/main/library.lua'))
local ui = uiLoader({
    rounding = false,
    theme = 'cherry',
    smoothDragging = false
})

ui.autoDisableToggles = true

-- Create the main window
local window = ui.newWindow({
    text = 'Deepwoven',
    resize = true,
    size = Vector2.new(550, 376)
})

-- Visuals Menu
local visualsMenu = window:addMenu({
    text = 'Visuals'
})

do 
    -- First section under Visuals
    local section1 = visualsMenu:addSection({
        text = 'Visuals Section 1',
        side = 'left',
        showMinButton = true
    })
    
    -- Highlight Players toggle
    local highlightPlayersToggle = section1:addToggle({
        text = 'Highlight Players',
        state = false
    })
    
    highlightPlayersToggle:bindToEvent('onToggle', function(newState)
        highlightPlayersEnabled = newState -- Enable/disable player highlighting
        ui.notify({
            title = 'Highlight Toggle',
            message = 'Highlight Players toggled to ' .. tostring(newState),
            duration = 3
        })
    end)

    -- Mob ESP toggle
    local mobESPToggle = section1:addToggle({
        text = 'Mob ESP',
        state = false
    })
    mobESPToggle:bindToEvent('onToggle', function(newState)
        highlightMobsEnabled = newState -- Enable/disable mob highlighting
        ui.notify({
            title = 'Mob ESP Toggle',
            message = 'Mob ESP toggled to ' .. tostring(newState),
            duration = 3
        })
    end)

    -- Buyable Item ESP toggle
    local itemESPToggle = section1:addToggle({
        text = 'Buyable Item ESP',
        state = false
    })
    itemESPToggle:bindToEvent('onToggle', function(newState)
        highlightItemsEnabled = newState -- Enable/disable item highlighting
        ui.notify({
            title = 'Item ESP Toggle',
            message = 'Buyable Item ESP toggled to ' .. tostring(newState),
            duration = 3
        })
    end)
end

-- Second section under Visuals
local section2 = visualsMenu:addSection({
    text = 'Visuals Section 2',
    side = 'right',
    showMinButton = true
})

do
    -- Brightness adjustment slider
    section2:addSlider({
        text = 'Adjust Brightness',
        min = 0,
        max = 100,
        step = 1,
        val = 50
    }, function(newValue)
        -- Adjust the lighting's brightness based on the slider value
        Lighting.Brightness = newValue / 100
        ui.notify({
            title = 'Brightness',
            message = 'Brightness set to ' .. tostring(newValue),
            duration = 3
        })
    end)

    -- Remove fog button
    section2:addButton({
        text = 'Remove Fog',
        style = 'large'
    }, function()
        -- Remove fog by adjusting lighting properties
        Lighting.FogEnd = 100000 -- Set to a high value to remove the fog effect
        ui.notify({
            title = 'Fog Removal',
            message = 'Fog has been removed!',
            duration = 3
        })
    end)

    -- Color picker for highlight fill color
    section2:addColorPicker({
        text = 'Highlight Fill Color',
        color = highlightFillColor
    }, function(newColor)
        updateHighlightColors(newColor, nil) -- Update fill color
    end)

    -- Color picker for outline color
    section2:addColorPicker({
        text = 'Outline Color',
        color = outlineColor
    }, function(newColor)
        updateHighlightColors(nil, newColor) -- Update outline color
    end)
end

-- Third section under Visuals (Loot ESP)
local lootESPSection = visualsMenu:addSection({
    text = 'Loot ESP',
    side = 'left',
    showMinButton = true
})

do
    -- Chest ESP toggle
    local chestESPToggle = lootESPSection:addToggle({
        text = 'Chest ESP',
        state = false
    })
    chestESPToggle:bindToEvent('onToggle', function(newState)
        chestHighlightEnabled = newState -- Enable/disable chest highlighting
        updateHighlights() -- Update the highlights immediately
        ui.notify({
            title = 'Chest ESP Toggle',
            message = 'Chest ESP toggled to ' .. tostring(newState),
            duration = 3
        })
    end)
end

-- Player Menu
local playerMenu = window:addMenu({
    text = 'Player'
})

do
    -- First section under Player
    local section1 = playerMenu:addSection({
        text = 'Player Settings ',
        side = 'left',
        showMinButton = true
    })
    
    -- Button to rejoin server
    section1:addButton({
        text = 'Rejoin Server',
        style = 'large'
    }, function()
        -- Rejoin the server
        local placeId = game.PlaceId
        local teleportService = game:GetService("TeleportService")
        teleportService:Teleport(placeId, player)
        ui.notify({
            title = 'Rejoin Server',
            message = 'Rejoining the server...',
            duration = 3
        })
    end)

    -- Spectate Player toggle
    local spectatePlayerToggle = section1:addToggle({
        text = 'Spectate Player',
        state = false
    })

    -- Textbox for player name
    local playerNameTextbox = section1:addTextbox({
        text = 'Player Name'
    })

    spectatePlayerToggle:bindToEvent('onToggle', function(newState)
        spectatePlayerEnabled = newState -- Enable/disable player spectating
        if spectatePlayerEnabled then
            spectatePlayer(spectatePlayerName) -- Start spectating
        else
            stopSpectating() -- Stop spectating
        end
        ui.notify({
            title = 'Spectate Toggle',
            message = 'Spectate Player toggled to ' .. tostring(newState),
            duration = 3
        })
    end)

    playerNameTextbox:bindToEvent('onFocusLost', function(text)
        spectatePlayerName = text -- Update the spectate player name
        if spectatePlayerEnabled then
            spectatePlayer(spectatePlayerName) -- Update spectating if already enabled
        end
    end)
end

-- Second section under Player
local section2 = playerMenu:addSection({
    text = 'Player Movement ',
    side = 'right',
    showMinButton = true
})

do
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
    
    -- Slider to adjust player jump power
    section2:addSlider({
        text = 'Jump Power',
        min = 0,
        max = 200,
        step = 1,
        val = 50
    }, function(newValue)
        -- Assuming a humanoid exists in the character
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.JumpPower = newValue
        end
        ui.notify({
            title = 'Jump Power',
            message = 'Jump Power set to ' .. tostring(newValue),
            duration = 3
        })
    end)
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

-- Input listeners to update the movement direction
UserInputService.InputBegan:Connect(updateMovementDirection)
UserInputService.InputEnded:Connect(updateMovementDirection)

-- Connect the moveCharacter function to RunService's RenderStepped for smooth movement
RunService.RenderStepped:Connect(function(deltaTime)
    updateMovementDirection()
    moveCharacter(deltaTime)
    updateHighlights() -- Update highlights dynamically
end)
