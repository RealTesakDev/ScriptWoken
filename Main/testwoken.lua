local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local workspace = game:GetService("Workspace")

-- Load and initialize the Dollarware UI Library
local success, err = pcall(function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/Dollarware-UI/Roblox-Library/main/DollarwareLib.lua'))()
end)

if not success then
    warn("Failed to load Dollarware UI library: " .. err)
    return -- Stop script execution if library failed to load
end

local Library = DollarwareLib -- Ensure the function or object is correctly referenced

-- Check if the Library loaded properly
if not Library then
    error("Failed to initialize Dollarware UI library. Ensure the URL and library setup are correct.")
end

-- Create the main UI window
local Window = Library:CreateWindow({
    Title = "ESP & Highlight Settings",
    Size = UDim2.new(0, 425, 0, 512)
})

-- Create a "Visuals" tab
local VisualsTab = Window:AddTab("Visuals")

-- Continue the rest of the script as it was...
