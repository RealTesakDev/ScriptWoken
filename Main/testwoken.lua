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
    text = 'Visuals' -- Renamed this menu from 'menu 1' to 'Visuals'
})

do 
    -- First section under Visuals
    local section1 = visualsMenu:addSection({
        text = 'Visuals Section 1',
        side = 'left',
        showMinButton = true
    })
    
    section1:addLabel({
        text = 'Visual Effect Toggle'
    })
    
    local visualsToggle = section1:addToggle({
        text = 'Toggle Visuals',
        state = false
    })
    
    visualsToggle:bindToEvent('onToggle', function(newState)
        ui.notify({
            title = 'Visuals Toggle',
            message = 'Visuals toggled to ' .. tostring(newState),
            duration = 3
        })
    end)
    
    section1:addButton({
        text = 'Apply Visuals',
        style = 'large'
    }, function()
        ui.notify({
            title = 'Apply Visuals',
            message = 'Visuals applied!',
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
    section2:addSlider({
        text = 'Adjust Brightness',
        min = 0,
        max = 100,
        step = 1,
        val = 50
    }, function(newValue)
        print("Brightness set to:", newValue)
    end)
    
    section2:addColorPicker({
        text = 'Select Color',
        color = Color3.fromRGB(255, 0, 0)
    }, function(newColor)
        print("Selected color:", newColor)
    end)
end

-- Player Menu
local playerMenu = window:addMenu({
    text = 'Player' -- New Player Menu
})

do
    -- First section under Player
    local section1 = playerMenu:addSection({
        text = 'Player Settings 1',
        side = 'left',
        showMinButton = true
    })
    
    section1:addLabel({
        text = 'Player ESP Toggle'
    })
    
    local playerEspToggle = section1:addToggle({
        text = 'Enable ESP',
        state = false
    })
    
    playerEspToggle:bindToEvent('onToggle', function(newState)
        ui.notify({
            title = 'Player ESP Toggle',
            message = 'ESP toggled to ' .. tostring(newState),
            duration = 3
        })
    end)
    
    section1:addButton({
        text = 'Apply ESP',
        style = 'large'
    }, function()
        ui.notify({
            title = 'Apply ESP',
            message = 'ESP applied!',
            duration = 3
        })
    end)
end

-- Second section under Player
local section2 = playerMenu:addSection({
    text = 'Player Settings 2',
    side = 'right',
    showMinButton = true
})

do
    section2:addSlider({
        text = 'Adjust Speed',
        min = 1,
        max = 50,
        step = 1,
        val = 10
    }, function(newValue)
        print("Speed set to:", newValue)
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
end
