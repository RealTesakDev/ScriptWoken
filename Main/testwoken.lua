-- Services 
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting") -- To adjust brightness and fog

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local camera = Workspace.CurrentCamera

local walkSpeed = 0 -- Speed in studs per second

-- Variables for highlight functionality
local highlightFillColor = Color3.new(1, 1, 1) -- Default white fill color
local outlineColor = Color3.new(1, 1, 1) -- Default white outline color
local highlightPlayersEnabled = false -- Toggle state for players
local highlightMobsEnabled = false -- Toggle state for mobs
local highlightItemsEnabled = false -- Toggle state for items

-- Function to create a highlight
local function createHighlight(object)
    if not object:FindFirstChildOfClass("Highlight") then
        local highlight = Instance.new("Highlight")
        highlight.Parent = object
        highlight.Adornee = object
        highlight.FillColor = highlightFillColor
        highlight.OutlineColor = outlineColor
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

-- Function to update highlights periodically
local function updateHighlights()
    if highlightPlayersEnabled then
        -- Highlight players
        for _, player in pairs(Players:GetPlayers()) do
            if player.Character then
                createHighlight(player.Character)
            end
        end
    else
        -- Remove highlights for players
        for _, player in pairs(Players:GetPlayers()) do
            if player.Character then
                removeHighlight(player.Character)
            end
        end
    end
    
    if highlightMobsEnabled then
        -- Highlight mobs
        local mobs = Workspace:FindFirstChild("Live") -- Folder containing mobs
        if mobs then
            for _, mob in pairs(mobs:GetChildren()) do
                createHighlight(mob)
            end
        end
    else
        -- Remove highlights for mobs
        local mobs = Workspace:FindFirstChild("Live")
        if mobs then
            for _, mob in pairs(mobs:GetChildren()) do
                removeHighlight(mob)
            end
        end
    end
    
    if highlightItemsEnabled then
        -- Highlight buyable items
        local items = Workspace:FindFirstChild("Shops") -- Folder containing items
        if items then
            for _, item in pairs(items:GetChildren()) do
                createHighlight(item)
            end
        end
    else
        -- Remove highlights for items
        local items = Workspace:FindFirstChild("Shops")
        if items then
            for _, item in pairs(items:GetChildren()) do
                removeHighlight(item)
            end
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

    -- Update the highlights for existing players, mobs, and items
    updateHighlights()
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
        updateHighlights() -- Update the highlights immediately
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
        updateHighlights() -- Update the highlights immediately
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
        updateHighlights() -- Update the highlights immediately
        ui.notify({
            title = 'Item ESP Toggle',
            message = 'Buyable Item ESP toggled to ' .. tostring(newState),
            duration = 3
        })
    end)

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
        ui.notify({
            title = 'Rejoin Server',
            message = 'Please Wait!',
            duration = 3
        })
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
    
    section2:addTextbox({
        text = 'Player Name'
    }):bindToEvent('onFocusLost', function(text)
        ui.notify({
            title = 'Player Name',
            message = 'Name entered: ' .. text,
            duration = 4
        })
    end)


    -- Slider to adjust player jump power
    section2:addSlider({
        text = 'Jump Power',
        min = 0,
        max = 200,
        step = 1,
        val = 50
    }, function(newValue)
        -- Adjust player's jump power
        local humanoid = character:WaitForChild("Humanoid")
        humanoid.JumpPower = newValue
    end)
end

-- Tp Walk Stuff

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
