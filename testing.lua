-- AntiAFK cu GUI: ON/OFF + Counter + Log
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")

local player = Players.LocalPlayer
if not player then return end

-- === GUI Setup ===
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AntiAFK_GUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 350, 0, 220)
frame.Position = UDim2.new(0, 10, 0, 10)
frame.BackgroundTransparency = 0.3
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BorderSizePixel = 0
frame.Parent = screenGui

local uiCorner = Instance.new("UICorner", frame)
uiCorner.CornerRadius = UDim.new(0, 12)

-- Buton ON/OFF
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 100, 0, 30)
toggleButton.Position = UDim2.new(0, 10, 0, 10)
toggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Font = Enum.Font.SourceSansBold
toggleButton.TextSize = 18
toggleButton.Text = "AntiAFK: ON"
toggleButton.Parent = frame

local uiCornerBtn = Instance.new("UICorner", toggleButton)
uiCornerBtn.CornerRadius = UDim.new(0, 8)

-- Counter text
local counterLabel = Instance.new("TextLabel")
counterLabel.Size = UDim2.new(0, 200, 0, 30)
counterLabel.Position = UDim2.new(0, 120, 0, 10)
counterLabel.BackgroundTransparency = 1
counterLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
counterLabel.Font = Enum.Font.SourceSansBold
counterLabel.TextSize = 18
counterLabel.TextXAlignment = Enum.TextXAlignment.Left
counterLabel.Text = "Clicks: 0"
counterLabel.Parent = frame

-- Log box
local logBox = Instance.new("TextLabel")
logBox.Size = UDim2.new(1, -20, 0, 150)
logBox.Position = UDim2.new(0, 10, 0, 50)
logBox.BackgroundTransparency = 1
logBox.TextColor3 = Color3.fromRGB(0, 200, 255)
logBox.TextXAlignment = Enum.TextXAlignment.Left
logBox.TextYAlignment = Enum.TextYAlignment.Top
logBox.Font = Enum.Font.Code
logBox.TextSize = 16
logBox.Text = "AntiAFK Log:\n"
logBox.TextWrapped = true
logBox.TextScaled = false
logBox.Parent = frame

-- === Variabile control ===
local enabled = true
local clicks = 0
local logHistory = {}

-- Funcție log
local function log(msg)
    table.insert(logHistory, os.date("%X") .. " - " .. msg)
    if #logHistory > 8 then
        table.remove(logHistory, 1)
    end
    logBox.Text = "AntiAFK Log:\n" .. table.concat(logHistory, "\n")
end

-- Buton ON/OFF
toggleButton.MouseButton1Click:Connect(function()
    enabled = not enabled
    if enabled then
        toggleButton.Text = "AntiAFK: ON"
        toggleButton.BackgroundColor3 = Color3.fromRGB(60, 120, 60)
        log("AntiAFK activat")
    else
        toggleButton.Text = "AntiAFK: OFF"
        toggleButton.BackgroundColor3 = Color3.fromRGB(120, 60, 60)
        log("AntiAFK dezactivat")
    end
end)

-- Funcție AntiAFK
local function antiAfk()
    if not enabled then return end
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new(0,0))
    clicks += 1
    counterLabel.Text = "Clicks: " .. clicks
    log("[AntiAFK] VirtualUser click #" .. clicks)
end

-- Când devine idle
player.Idled:Connect(function()
    antiAfk()
end)

-- Detectare input real (pentru log)
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 or
       input.UserInputType == Enum.UserInputType.Touch then
        log("[Client] InputBegan detectat")
    end
end)

local success, mouse = pcall(function() return player:GetMouse() end)
if success and mouse then
    mouse.Button1Down:Connect(function()
        log("[Client] Mouse.Button1Down detectat")
    end)
end