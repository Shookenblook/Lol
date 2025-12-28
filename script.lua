-- ============================================
-- WHITELIST SYSTEM - DO NOT REMOVE
-- ============================================

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Your GitHub whitelist URL
local WHITELIST_URL = "https://raw.githubusercontent.com/Shookenblook/Lol/main/whitelist.json"

-- Function to fetch whitelist
local function fetchWhitelist()
    local success, result = pcall(function()
        return game:HttpGet(WHITELIST_URL)
    end)
    
    if success then
        local data = HttpService:JSONDecode(result)
        return data
    else
        warn("Failed to fetch whitelist: " .. tostring(result))
        return nil
    end
end

-- Function to check if player is whitelisted
local function isWhitelisted(player, whitelistData)
    if not whitelistData then
        return false
    end
    
    -- Check User ID (most secure method)
    if whitelistData.whitelisted_users then
        for _, userId in ipairs(whitelistData.whitelisted_users) do
            if player.UserId == userId then
                return true
            end
        end
    end
    
    -- Check by ACTUAL USERNAME (not display name)
    if whitelistData.whitelisted_names then
        for _, username in ipairs(whitelistData.whitelisted_names) do
            -- player.Name returns the ACTUAL username, NOT display name
            if player.Name == username then
                return true
            end
        end
    end
    
    return false
end

-- Main whitelist check
print("🔒 Piko.wtf - Checking whitelist...")
print("👤 Account Name (Username): " .. LocalPlayer.Name)
print("🎭 Display Name: " .. LocalPlayer.DisplayName)
print("🔢 User ID: " .. LocalPlayer.UserId)

local whitelistData = fetchWhitelist()

if not whitelistData or not isWhitelisted(LocalPlayer, whitelistData) then
    LocalPlayer:Kick("❌ ACCESS DENIED - Piko.wtf\n\n🚫 You are not whitelisted for this script\n\n📋 Your Details:\n   Username: " .. LocalPlayer.Name .. "\n   Display Name: " .. LocalPlayer.DisplayName .. "\n   User ID: " .. LocalPlayer.UserId .. "\n\n💬 Contact kovaak on Discord for access")
    return
end

print("✅ Whitelist verified! Loading Piko.wtf...")
print("✅ Welcome, @" .. LocalPlayer.Name .. " (" .. LocalPlayer.DisplayName .. ")")

-- ============================================
-- MAIN SCRIPT STARTS HERE
-- ============================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Piko.wtf",
    LoadingTitle = "Piko.wtf",
    LoadingSubtitle = "by kovaak",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = nil,
        FileName = "PikoConfig"
    },
    Discord = {
        Enabled = false,
        Invite = "noinvitelink",
        RememberJoins = true
    },
    KeySystem = false,
    KeySettings = {
        Title = "Key System",
        Subtitle = "Enter Key",
        Note = "No method of obtaining key provided",
        FileName = "Key",
        SaveKey = true,
        GrabKeyFromSite = false,
        Key = {"Hello"}
    }
})

-- Combat Tab
local CombatTab = Window:CreateTab("Combat", 4483362458)

local CombatSection = CombatTab:CreateSection("Aimlock Features")

-- FOV Circle Setup
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.NumSides = 50
FOVCircle.Radius = 100
FOVCircle.Filled = false
FOVCircle.Transparency = 1
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Visible = false

getgenv().AimLockEnabled = false
getgenv().FOVSize = 100
getgenv().AimLockTarget = nil
getgenv().AimPart = "Head"
getgenv().WasHoldingRightClick = false
getgenv().AimSmoothing = 1
getgenv().PredictionAmount = 0.13

-- Function to get closest player to mouse within FOV
local function getClosestPlayerInFOV()
    local camera = workspace.CurrentCamera
    local localPlayer = game.Players.LocalPlayer
    local mouse = localPlayer:GetMouse()
    local mousePos = Vector2.new(mouse.X, mouse.Y)
    
    local closestPlayer = nil
    local shortestDistance = getgenv().FOVSize
    
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local targetPart = player.Character:FindFirstChild(getgenv().AimPart)
            if targetPart then
                local screenPos, onScreen = camera:WorldToViewportPoint(targetPart.Position)
                if onScreen then
                    local screenPosition = Vector2.new(screenPos.X, screenPos.Y)
                    local distance = (screenPosition - mousePos).Magnitude
                    
                    if distance < shortestDistance then
                        closestPlayer = player
                        shortestDistance = distance
                    end
                end
            end
        end
    end
    
    return closestPlayer
end

-- Update FOV Circle Position and Aimlock
game:GetService("RunService").RenderStepped:Connect(function()
    if FOVCircle.Visible then
        local mousePos = game:GetService("UserInputService"):GetMouseLocation()
        FOVCircle.Position = Vector2.new(mousePos.X, mousePos.Y)
        FOVCircle.Radius = getgenv().FOVSize
    end
    
    -- Aimlock Logic
    if getgenv().AimLockEnabled then
        local isHoldingRightClick = game:GetService("UserInputService"):IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
        
        if isHoldingRightClick and not getgenv().WasHoldingRightClick then
            getgenv().AimLockTarget = getClosestPlayerInFOV()
            getgenv().WasHoldingRightClick = true
        elseif not isHoldingRightClick and getgenv().WasHoldingRightClick then
            getgenv().AimLockTarget = nil
            getgenv().WasHoldingRightClick = false
        end
        
        if isHoldingRightClick and getgenv().AimLockTarget then
            if getgenv().AimLockTarget.Character and getgenv().AimLockTarget.Character:FindFirstChild(getgenv().AimPart) and getgenv().AimLockTarget.Character:FindFirstChild("Humanoid") and getgenv().AimLockTarget.Character.Humanoid.Health > 0 then
                local camera = workspace.CurrentCamera
                local targetPart = getgenv().AimLockTarget.Character[getgenv().AimPart]
                local targetRootPart = getgenv().AimLockTarget.Character:FindFirstChild("HumanoidRootPart")
                
                local targetPosition = targetPart.Position
                if targetRootPart and getgenv().PredictionAmount > 0 then
                    local targetVelocity = targetRootPart.AssemblyLinearVelocity or targetRootPart.Velocity
                    targetPosition = targetPosition + (targetVelocity * getgenv().PredictionAmount)
                end
                
                if getgenv().AimSmoothing < 1 then
                    local targetCFrame = CFrame.new(camera.CFrame.Position, targetPosition)
                    camera.CFrame = camera.CFrame:Lerp(targetCFrame, getgenv().AimSmoothing)
                else
                    camera.CFrame = CFrame.new(camera.CFrame.Position, targetPosition)
                end
            else
                getgenv().AimLockTarget = nil
            end
        end
    else
        getgenv().AimLockTarget = nil
        getgenv().WasHoldingRightClick = false
    end
end)

local AimLockToggle = CombatTab:CreateToggle({
    Name = "Aim Lock (Hold Right Click)",
    CurrentValue = false,
    Flag = "AimLockToggle",
    Callback = function(Value)
        getgenv().AimLockEnabled = Value
    end,
})

local AimPartDropdown = CombatTab:CreateDropdown({
    Name = "Aim Part",
    Options = {"Head", "HumanoidRootPart"},
    CurrentOption = {"Head"},
    MultipleOptions = false,
    Flag = "AimPartDropdown",
    Callback = function(Option)
        getgenv().AimPart = Option[1]
    end,
})

local FOVToggle = CombatTab:CreateToggle({
    Name = "Show FOV Circle",
    CurrentValue = false,
    Flag = "FOVToggle",
    Callback = function(Value)
        FOVCircle.Visible = Value
    end,
})

local FOVSlider = CombatTab:CreateSlider({
    Name = "FOV Size",
    Range = {50, 500},
    Increment = 10,
    Suffix = "px",
    CurrentValue = 100,
    Flag = "FOVSlider",
    Callback = function(Value)
        getgenv().FOVSize = Value
    end,
})

local SmoothingSlider = CombatTab:CreateSlider({
    Name = "Smoothing",
    Range = {0.1, 1},
    Increment = 0.05,
    Suffix = "",
    CurrentValue = 1,
    Flag = "SmoothingSlider",
    Callback = function(Value)
        getgenv().AimSmoothing = Value
    end,
})

local PredictionSlider = CombatTab:CreateSlider({
    Name = "Prediction",
    Range = {0, 0.3},
    Increment = 0.01,
    Suffix = "",
    CurrentValue = 0.13,
    Flag = "PredictionSlider",
    Callback = function(Value)
        getgenv().PredictionAmount = Value
    end,
})

-- Trigger Bot
local TriggerBotSection = CombatTab:CreateSection("Trigger Bot")

getgenv().TriggerBotEnabled = false
getgenv().TriggerBotDelay = 0

local TriggerBotToggle = CombatTab:CreateToggle({
    Name = "Trigger Bot",
    CurrentValue = false,
    Flag = "TriggerBotToggle",
    Callback = function(Value)
        getgenv().TriggerBotEnabled = Value
    end,
})

local TriggerBotDelaySlider = CombatTab:CreateSlider({
    Name = "Trigger Delay",
    Range = {0, 500},
    Increment = 10,
    Suffix = "ms",
    CurrentValue = 0,
    Flag = "TriggerBotDelaySlider",
    Callback = function(Value)
        getgenv().TriggerBotDelay = Value
    end,
})

game:GetService("RunService").Heartbeat:Connect(function()
    if getgenv().TriggerBotEnabled then
        local player = game.Players.LocalPlayer
        local mouse = player:GetMouse()
        local target = mouse.Target
        
        if target and target.Parent then
            local humanoid = target.Parent:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local targetPlayer = game.Players:GetPlayerFromCharacter(target.Parent)
                if targetPlayer and targetPlayer ~= player then
                    task.wait(getgenv().TriggerBotDelay / 1000)
                    mouse1click()
                end
            end
        end
    end
end)

-- Visuals Tab
local VisualsTab = Window:CreateTab("Visuals", 4483362458)

local VisualsSection = VisualsTab:CreateSection("Visual Features")

getgenv().ESPEnabled = false
getgenv().ESPObjects = {}

local function createESP(player)
    local ESPData = {
        Player = player,
        Box = Drawing.new("Square"),
        HealthBar = Drawing.new("Square"),
        HealthBarOutline = Drawing.new("Square"),
        HealthText = Drawing.new("Text"),
        NameText = Drawing.new("Text")
    }
    
    ESPData.Box.Thickness = 2
    ESPData.Box.Filled = false
    ESPData.Box.Color = Color3.fromRGB(255, 255, 255)
    ESPData.Box.Transparency = 1
    ESPData.Box.Visible = false
    
    ESPData.HealthBarOutline.Thickness = 1
    ESPData.HealthBarOutline.Filled = false
    ESPData.HealthBarOutline.Color = Color3.fromRGB(0, 0, 0)
    ESPData.HealthBarOutline.Transparency = 1
    ESPData.HealthBarOutline.Visible = false
    
    ESPData.HealthBar.Thickness = 1
    ESPData.HealthBar.Filled = true
    ESPData.HealthBar.Color = Color3.fromRGB(0, 255, 0)
    ESPData.HealthBar.Transparency = 1
    ESPData.HealthBar.Visible = false
    
    ESPData.HealthText.Text = "100"
    ESPData.HealthText.Size = 14
    ESPData.HealthText.Center = true
    ESPData.HealthText.Outline = true
    ESPData.HealthText.Color = Color3.fromRGB(255, 255, 255)
    ESPData.HealthText.Visible = false
    
    ESPData.NameText.Text = player.Name
    ESPData.NameText.Size = 14
    ESPData.NameText.Center = true
    ESPData.NameText.Outline = true
    ESPData.NameText.Color = Color3.fromRGB(255, 255, 255)
    ESPData.NameText.Visible = false
    
    return ESPData
end

local function updateESP()
    if not getgenv().ESPEnabled then return end
    
    for _, espData in pairs(getgenv().ESPObjects) do
        local player = espData.Player
        if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") then
            local hrp = player.Character.HumanoidRootPart
            local humanoid = player.Character.Humanoid
            local camera = workspace.CurrentCamera
            
            local vector, onScreen = camera:WorldToViewportPoint(hrp.Position)
            
            if onScreen then
                local headPos = camera:WorldToViewportPoint(hrp.Position + Vector3.new(0, 3, 0))
                local legPos = camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
                
                local height = math.abs(headPos.Y - legPos.Y)
                local width = height / 2
                
                espData.Box.Size = Vector2.new(width, height)
                espData.Box.Position = Vector2.new(vector.X - width / 2, vector.Y - height / 2)
                espData.Box.Visible = true
                
                local health = math.floor(humanoid.Health)
                local maxHealth = math.floor(humanoid.MaxHealth)
                local healthPercent = health / maxHealth
                
                espData.HealthBarOutline.Size = Vector2.new(4, height)
                espData.HealthBarOutline.Position = Vector2.new(vector.X - width / 2 - 7, vector.Y - height / 2)
                espData.HealthBarOutline.Visible = true
                
                local healthBarHeight = height * healthPercent
                espData.HealthBar.Size = Vector2.new(2, healthBarHeight)
                espData.HealthBar.Position = Vector2.new(vector.X - width / 2 - 6, vector.Y - height / 2 + (height - healthBarHeight))
                espData.HealthBar.Color = Color3.fromRGB(255 * (1 - healthPercent), 255 * healthPercent, 0)
                espData.HealthBar.Visible = true
                
                espData.HealthText.Text = tostring(health)
                espData.HealthText.Position = Vector2.new(vector.X - width / 2 - 5, vector.Y - height / 2 - 15)
                espData.HealthText.Visible = true
                
                espData.NameText.Text = player.Name
                espData.NameText.Position = Vector2.new(vector.X, vector.Y - height / 2 - 15)
                espData.NameText.Visible = true
            else
                espData.Box.Visible = false
                espData.HealthBar.Visible = false
                espData.HealthBarOutline.Visible = false
                espData.HealthText.Visible = false
                espData.NameText.Visible = false
            end
        else
            espData.Box.Visible = false
            espData.HealthBar.Visible = false
            espData.HealthBarOutline.Visible = false
            espData.HealthText.Visible = false
            espData.NameText.Visible = false
        end
    end
end

local function removeESP(espData)
    espData.Box:Remove()
    espData.HealthBar:Remove()
    espData.HealthBarOutline:Remove()
    espData.HealthText:Remove()
    espData.NameText:Remove()
end

game:GetService("RunService").RenderStepped:Connect(function()
    updateESP()
end)

local ESPToggle = VisualsTab:CreateToggle({
    Name = "Player ESP",
    CurrentValue = false,
    Flag = "ESPToggle",
    Callback = function(Value)
        getgenv().ESPEnabled = Value
        
        if Value then
            for _, player in pairs(game.Players:GetPlayers()) do
                if player ~= game.Players.LocalPlayer then
                    getgenv().ESPObjects[player] = createESP(player)
                end
            end
            
            game.Players.PlayerAdded:Connect(function(player)
                if getgenv().ESPEnabled then
                    getgenv().ESPObjects[player] = createESP(player)
                end
            end)
            
            game.Players.PlayerRemoving:Connect(function(player)
                if getgenv().ESPObjects[player] then
                    removeESP(getgenv().ESPObjects[player])
                    getgenv().ESPObjects[player] = nil
                end
            end)
        else
            for _, espData in pairs(getgenv().ESPObjects) do
                removeESP(espData)
            end
            getgenv().ESPObjects = {}
        end
    end,
})

getgenv().TracersEnabled = false
getgenv().TracerObjects = {}

local function updateTracers()
    if not getgenv().TracersEnabled then return end
    
    local camera = workspace.CurrentCamera
    local screenSize = camera.ViewportSize
    local fromPos = Vector2.new(screenSize.X / 2, screenSize.Y)
    
    for player, tracer in pairs(getgenv().TracerObjects) do
        if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            local vector, onScreen = camera:WorldToViewportPoint(hrp.Position)
            
            if onScreen then
                tracer.From = fromPos
                tracer.To = Vector2.new(vector.X, vector.Y)
                tracer.Visible = true
            else
                tracer.Visible = false
            end
        else
            tracer.Visible = false
        end
    end
end

game:GetService("RunService").RenderStepped:Connect(function()
    updateTracers()
end)

local TracersToggle = VisualsTab:CreateToggle({
    Name = "Tracers",
    CurrentValue = false,
    Flag = "TracersToggle",
    Callback = function(Value)
        getgenv().TracersEnabled = Value
        
        if Value then
            for _, player in pairs(game.Players:GetPlayers()) do
                if player ~= game.Players.LocalPlayer then
                    local tracer = Drawing.new("Line")
                    tracer.Thickness = 1
                    tracer.Color = Color3.fromRGB(255, 255, 255)
                    tracer.Transparency = 1
                    tracer.Visible = false
                    getgenv().TracerObjects[player] = tracer
                end
            end
            
            game.Players.PlayerAdded:Connect(function(player)
                if getgenv().TracersEnabled and player ~= game.Players.LocalPlayer then
                    local tracer = Drawing.new("Line")
                    tracer.Thickness = 1
                    tracer.Color = Color3.fromRGB(255, 255, 255)
                    tracer.Transparency = 1
                    tracer.Visible = false
                    getgenv().TracerObjects[player] = tracer
                end
            end)
            
            game.Players.PlayerRemoving:Connect(function(player)
                if getgenv().TracerObjects[player] then
                    getgenv().TracerObjects[player]:Remove()
                    getgenv().TracerObjects[player] = nil
                end
            end)
        else
            for _, tracer in pairs(getgenv().TracerObjects) do
                tracer:Remove()
            end
            getgenv().TracerObjects = {}
        end
    end,
})

local FullbrightToggle = VisualsTab:CreateToggle({
    Name = "Fullbright",
    CurrentValue = false,
    Flag = "FullbrightToggle",
    Callback = function(Value)
        if Value then
            game:GetService("Lighting").Brightness = 2
            game:GetService("Lighting").ClockTime = 14
            game:GetService("Lighting").FogEnd = 100000
            game:GetService("Lighting").GlobalShadows = false
            game:GetService("Lighting").OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        else
            game:GetService("Lighting").Brightness = 1
            game:GetService("Lighting").ClockTime = 12
            game:GetService("Lighting").FogEnd = 100000
            game:GetService("Lighting").GlobalShadows = true
            game:GetService("Lighting").OutdoorAmbient = Color3.fromRGB(70, 70, 70)
        end
    end,
})

-- Players Tab
local PlayersTab = Window:CreateTab("Players", 4483362458)

local PlayersSection = PlayersTab:CreateSection("Player Options")

-- Variables for speed and jump
getgenv().CustomWalkSpeed = 16
getgenv().CustomJumpPower = 50
getgenv().WalkSpeedEnabled = false
getgenv().JumpPowerEnabled = false

-- Continuous loop to bypass Da Hood anti-cheat
game:GetService("RunService").Heartbeat:Connect(function()
    local player = game.Players.LocalPlayer
    if player and player.Character then
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            if getgenv().WalkSpeedEnabled and humanoid.WalkSpeed ~= getgenv().CustomWalkSpeed then
                humanoid.WalkSpeed = getgenv().CustomWalkSpeed
            end
            if getgenv().JumpPowerEnabled and humanoid.JumpPower ~= getgenv().CustomJumpPower then
                humanoid.JumpPower = getgenv().CustomJumpPower
            end
        end
    end
end)

-- Also hook the .Changed event
local function setupSpeedBypass()
    local player = game.Players.LocalPlayer
    if player.Character then
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
                if getgenv().WalkSpeedEnabled then
                    humanoid.WalkSpeed = getgenv().CustomWalkSpeed
                end
            end)
            
            humanoid:GetPropertyChangedSignal("JumpPower"):Connect(function()
                if getgenv().JumpPowerEnabled then
                    humanoid.JumpPower = getgenv().CustomJumpPower
                end
            end)
        end
    end
end

-- Setup on character spawn
game.Players.LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.1)
    setupSpeedBypass()
end)

setupSpeedBypass()

local WalkSpeedToggle = PlayersTab:CreateToggle({
    Name = "Enable Walk Speed",
    CurrentValue = false,
    Flag = "WalkSpeedToggle",
    Callback = function(Value)
        getgenv().WalkSpeedEnabled = Value
        if Value then
            local humanoid = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = getgenv().CustomWalkSpeed
            end
        else
            local humanoid = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = 16
            end
        end
    end,
})

local WalkSpeedSlider = PlayersTab:CreateSlider({
    Name = "Walk Speed",
    Range = {16, 200},
    Increment = 1,
    Suffix = "speed",
    CurrentValue = 16,
    Flag = "WalkSpeedSlider",
    Callback = function(Value)
        getgenv().CustomWalkSpeed = Value
        if getgenv().WalkSpeedEnabled then
            local humanoid = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = Value
            end
        end
    end,
})

local JumpPowerToggle = PlayersTab:CreateToggle({
    Name = "Enable Jump Power",
    CurrentValue = false,
    Flag = "JumpPowerToggle",
    Callback = function(Value)
        getgenv().JumpPowerEnabled = Value
        if Value then
            local humanoid = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.JumpPower = getgenv().CustomJumpPower
            end
        else
            local humanoid = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.JumpPower = 50
            end
        end
    end,
})

local JumpPowerSlider = PlayersTab:CreateSlider({
    Name = "Jump Power",
    Range = {50, 300},
    Increment = 1,
    Suffix = "power",
    CurrentValue = 50,
    Flag = "JumpPowerSlider",
    Callback = function(Value)
        getgenv().CustomJumpPower = Value
        if getgenv().JumpPowerEnabled then
            local humanoid = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.JumpPower = Value
            end
        end
    end,
})

local InfiniteJumpToggle = PlayersTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Flag = "InfiniteJumpToggle",
    Callback = function(Value)
        getgenv().InfiniteJump = Value
        game:GetService("UserInputService").JumpRequest:connect(function()
            if getgenv().InfiniteJump then
                game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
            end
        end)
    end,
})

-- Misc Tab
local MiscTab = Window:CreateTab("Misc", 4483362458)

local MiscSection = MiscTab:CreateSection("Miscellaneous")

getgenv().FlyEnabled = false
getgenv().FlySpeed = 50

local function toggleFly()
    getgenv().FlyEnabled = not getgenv().FlyEnabled
    
    local player = game.Players.LocalPlayer
    local character = player.Character
    if not character then return end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    
    if getgenv().FlyEnabled then
        local bv = Instance.new("BodyVelocity")
        bv.Name = "FlyBodyVelocity"
        bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bv.Velocity = Vector3.new(0, 0, 0)
        bv.Parent = rootPart
        
        local bg = Instance.new("BodyGyro")
        bg.Name = "FlyBodyGyro"
        bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        bg.CFrame = rootPart.CFrame
        bg.Parent = rootPart
        
        local flyConnection
        flyConnection = game:GetService("RunService").Heartbeat:Connect(function()
            if not getgenv().FlyEnabled then
                flyConnection:Disconnect()
                if rootPart:FindFirstChild("FlyBodyVelocity") then
                    rootPart.FlyBodyVelocity:Destroy()
                end
                if rootPart:FindFirstChild("FlyBodyGyro") then
                    rootPart.FlyBodyGyro:Destroy()
                end
                return
            end
            
            local cam = workspace.CurrentCamera
            local direction = Vector3.new(0, 0, 0)
            local userInput = game:GetService("UserInputService")
            
            if userInput:IsKeyDown(Enum.KeyCode.W) then
                direction = direction + (cam.CFrame.LookVector)
            end
            if userInput:IsKeyDown(Enum.KeyCode.S) then
                direction = direction - (cam.CFrame.LookVector)
            end
            if userInput:IsKeyDown(Enum.KeyCode.A) then
                direction = direction - (cam.CFrame.RightVector)
            end
            if userInput:IsKeyDown(Enum.KeyCode.D) then
                direction = direction + (cam.CFrame.RightVector)
            end
            if userInput:IsKeyDown(Enum.KeyCode.Space) then
                direction = direction + Vector3.new(0, 1, 0)
            end
            if userInput:IsKeyDown(Enum.KeyCode.LeftShift) then
                direction = direction - Vector3.new(0, 1, 0)
            end
            
            if bv and bg then
                bv.Velocity = direction * getgenv().FlySpeed
                bg.CFrame = cam.CFrame
            end
        end)
    else
        if rootPart:FindFirstChild("FlyBodyVelocity") then
            rootPart.FlyBodyVelocity:Destroy()
        end
        if rootPart:FindFirstChild("FlyBodyGyro") then
            rootPart.FlyBodyGyro:Destroy()
        end
    end
end

game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.X then
        toggleFly()
    end
end)

local NoClipToggle = MiscTab:CreateToggle({
    Name = "No Clip",
    CurrentValue = false,
    Flag = "NoClipToggle",
    Callback = function(Value)
        getgenv().NoClip = Value
        game:GetService("RunService").Stepped:connect(function()
            if getgenv().NoClip then
                for _, v in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.CanCollide = false
                    end
                end
            end
        end)
    end,
})

local FlyToggle = MiscTab:CreateToggle({
    Name = "Fly (Press X to toggle)",
    CurrentValue = false,
    Flag = "FlyToggle",
    Callback = function(Value)
        if Value ~= getgenv().FlyEnabled then
            toggleFly()
        end
    end,
})

local FlySpeedSlider = MiscTab:CreateSlider({
    Name = "Fly Speed",
    Range = {16, 200},
    Increment = 1,
    Suffix = "speed",
    CurrentValue = 50,
    Flag = "FlySpeedSlider",
    Callback = function(Value)
        getgenv().FlySpeed = Value
    end,
})

local TeleportButton = MiscTab:CreateButton({
    Name = "Teleport to Spawn",
    Callback = function()
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(0, 50, 0)
    end,
})

Rayfield:LoadConfiguration()
