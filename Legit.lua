local repo = 'https://raw.githubusercontent.com/mstudio45/LinoriaLib/main/'

local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()


getgenv().Ragebot = {
    Enabled = false,
    FOV = 250,
    AimPart = "Head",
    Wallbang = false,
    Tracer = false,
    TracerColor = Color3.fromRGB(199, 120, 221),
    TargetList = {},
    WhiteList = {},
    PlayerNames = {},
    ClosestMode = false,
    HitSound = false,
    HitNotify = false,
    Teleport = false,
    TeleportMode = "Behind",
    TeleportOffset = Vector3.new(0, 0, 0),
    TargetStrafe = false,
    StrafeRadius = 5,
    StrafeSpeed = 20,
    StrafeDirection = "Clockwise",
    RichTracer = false,
    TracerTexture = "rbxassetid://901813002",
    TracerWidth = 0.3,
    TracerLength = 15,
    TracerSpeed = 2
}

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

local Window = Library:CreateWindow({
    Title = 'ske.gg',
    Center = true,
    AutoShow = true,
})

local Tabs = {
    Ragebot = Window:AddTab('Ragebot'),
    Movement = Window:AddTab('Movement'),
    Settings = Window:AddTab('Settings'),
}

local MainSection = Tabs.Ragebot:AddLeftGroupbox('Main')
local TargetSection = Tabs.Ragebot:AddRightGroupbox('Targeting')
local VisualSection = Tabs.Ragebot:AddLeftGroupbox('Visuals')
local MovementSection = Tabs.Movement:AddLeftGroupbox('Movement')

MainSection:AddToggle('EnableRagebot', {
    Text = 'Enable Ragebot',
    Default = false,
    Callback = function(Value)
        Ragebot.Enabled = Value
    end
})
VisualSection:AddToggle('HitSoundToggle', {
    Text = 'Hit Sound',
    Default = false,
    Callback = function(Value)
        Ragebot.HitSound = Value
    end
})

VisualSection:AddToggle('HitNotifyToggle', {
    Text = 'Hit Notify',
    Default = false,
    Callback = function(Value)
        Ragebot.HitNotify = Value
    end
})

MainSection:AddToggle('ClosestMode', {
    Text = 'Closest Mode',
    Default = false,
    Callback = function(Value)
        Ragebot.ClosestMode = Value
    end
})

MainSection:AddSlider('FOVSlider', {
    Text = 'FOV',
    Default = 250,
    Min = 50,
    Max = 2500,
    Rounding = 0,
    Callback = function(Value)
        Ragebot.FOV = Value
    end
})

MainSection:AddDropdown('AimPartDropdown', {
    Values = {'Head', 'HumanoidRootPart'},
    Default = 1,
    Text = 'Aim Part',
    Callback = function(Value)
        Ragebot.AimPart = Value
    end
})

MainSection:AddToggle('WallbangToggle', {
    Text = 'Wallbang',
    Default = false,
    Callback = function(Value)
        Ragebot.Wallbang = Value
    end
})

VisualSection:AddToggle('TracerToggle', {
    Text = 'Tracer',
    Default = false,
    Callback = function(Value)
        Ragebot.Tracer = Value
    end
})

VisualSection:AddLabel('Tracer Color'):AddColorPicker('TracerColorPicker', {
    Default = Color3.fromRGB(199, 120, 221),
    Callback = function(Value)
        Ragebot.TracerColor = Value
    end
})

local function UpdatePlayerList()
    local playerNames = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(playerNames, player.Name)
        end
    end
    return playerNames
end

local initialPlayerNames = UpdatePlayerList()

local TargetDropdown = TargetSection:AddDropdown('TargetListDropdown', {
    Values = initialPlayerNames,
    Default = 1,
    Text = 'Add Target',
    Callback = function(Value)
        local player = Players:FindFirstChild(Value)
        if player and not table.find(Ragebot.TargetList, player) then
            table.insert(Ragebot.TargetList, player)
        end
    end
})

local WhiteDropdown = TargetSection:AddDropdown('WhiteListDropdown', {
    Values = initialPlayerNames,
    Default = 1,
    Text = 'Add to Whitelist',
    Callback = function(Value)
        local player = Players:FindFirstChild(Value)
        if player and not table.find(Ragebot.WhiteList, player) then
            table.insert(Ragebot.WhiteList, player)
        end
    end
})

TargetSection:AddButton('Clear TargetList', function()
    Ragebot.TargetList = {}
end)

TargetSection:AddButton('Clear WhiteList', function()
    Ragebot.WhiteList = {}
end)

task.spawn(function()
    while true do
        local currentPlayers = UpdatePlayerList()
        TargetDropdown:SetValues(currentPlayers)
        WhiteDropdown:SetValues(currentPlayers)
        task.wait(2)
    end
end)

local TargetDropdown = TargetSection:AddDropdown('TargetListDropdown', {
    Values = initialPlayerNames,
    Default = 1,
    Text = 'Add Target TelePort',
    Callback = function(Value)
        local player = Players:FindFirstChild(Value)
        if player and not table.find(Ragebot.TargetList, player) then
            table.insert(Ragebot.TargetList, player)
            Library:Notify("Added " .. Value .. " to TargetList", 2)
        end
    end
})

local WhiteDropdown = TargetSection:AddDropdown('WhiteListDropdown', {
    Values = initialPlayerNames,
    Default = 1,
    Text = 'Add to Whitelist',
    Callback = function(Value)
        local player = Players:FindFirstChild(Value)
        if player and not table.find(Ragebot.WhiteList, player) then
            table.insert(Ragebot.WhiteList, player)
            Library:Notify("Added " .. Value .. " to Whitelist", 2)
        end
    end
})

TargetSection:AddButton('Clear TargetList', function()
    Ragebot.TargetList = {}
    Library:Notify("TargetList cleared", 2)
end)

TargetSection:AddButton('Clear WhiteList', function()
    Ragebot.WhiteList = {}
    Library:Notify("Whitelist cleared", 2)
end)
VisualSection:AddToggle('RichTracerToggle', {
    Text = 'Rich Tracer',
    Default = false,
    Callback = function(Value)
        Ragebot.RichTracer = Value
    end
})

VisualSection:AddSlider('TracerWidthSlider', {
    Text = 'Tracer Width',
    Default = 0.3,
    Min = 0.1,
    Max = 1,
    Rounding = 1,
    Callback = function(Value)
        Ragebot.TracerWidth = Value
    end
})

VisualSection:AddSlider('TracerLengthSlider', {
    Text = 'Tracer Length',
    Default = 15,
    Min = 5,
    Max = 30,
    Rounding = 1,
    Callback = function(Value)
        Ragebot.TracerLength = Value
    end
})

VisualSection:AddSlider('TracerSpeedSlider', {
    Text = 'Tracer Speed',
    Default = 2,
    Min = 1,
    Max = 5,
    Rounding = 1,
    Callback = function(Value)
        Ragebot.TracerSpeed = Value
    end
})

local tracerContainer = Instance.new("Folder")
tracerContainer.Name = "RichTracers"
tracerContainer.Parent = Workspace

local function createRichTracer(startPos, endPos)
    if not Ragebot.RichTracer then return end
    
    local beamPart = Instance.new("Part")
    beamPart.Name = "RichTracer"
    beamPart.Anchored = true
    beamPart.Size = Vector3.new(0.5, 0.5, 0.5)
    beamPart.Transparency = 1
    beamPart.CanCollide = false
    beamPart.Parent = tracerContainer
    
    local distance = (startPos - endPos).Magnitude
    local midPoint = (startPos + endPos) / 2
    beamPart.Position = midPoint
    
    local beam = Instance.new("Beam")
    beam.Attachment0 = Instance.new("Attachment")
    beam.Attachment0.Parent = beamPart
    beam.Attachment0.Position = Vector3.new(0, distance/2, 0)
    
    beam.Attachment1 = Instance.new("Attachment")
    beam.Attachment1.Parent = beamPart
    beam.Attachment1.Position = Vector3.new(0, -distance/2, 0)
    
    beam.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 183, 255)),
        ColorSequenceKeypoint.new(0.3, Color3.fromRGB(100, 0, 255)),
        ColorSequenceKeypoint.new(0.6, Color3.fromRGB(187, 0, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 183))
    })
    
    beam.Texture = Ragebot.TracerTexture
    beam.TextureSpeed = Ragebot.TracerSpeed
    beam.TextureLength = Ragebot.TracerLength
    beam.Width0 = Ragebot.TracerWidth
    beam.Width1 = Ragebot.TracerWidth
    beam.FaceCamera = true
    beam.Parent = beamPart
    
    local lookCFrame = CFrame.new(midPoint, endPos)
    beamPart.CFrame = lookCFrame
    
    beam.Width0 = 0
    beam.Width1 = 0
    
    local tweenIn = TweenService:Create(beam, TweenInfo.new(0.2), {
        Width0 = Ragebot.TracerWidth,
        Width1 = Ragebot.TracerWidth
    })
    
    local tweenOut = TweenService:Create(beam, TweenInfo.new(0.3), {
        Width0 = 0,
        Width1 = 0
    })
    
    tweenIn:Play()
    tweenIn.Completed:Connect(function()
        task.wait(0.1)
        tweenOut:Play()
        tweenOut.Completed:Connect(function()
            beamPart:Destroy()
        end)
    end)
    
    return beamPart
end
TargetSection:AddButton('Refresh Player List', function()
    local currentPlayers = UpdatePlayerList()
    TargetDropdown:SetValues(currentPlayers)
    WhiteDropdown:SetValues(currentPlayers)
    Library:Notify("Player list refreshed", 2)
end)

task.spawn(function()
    while true do
        local currentPlayers = UpdatePlayerList()
        TargetDropdown:SetValues(currentPlayers)
        WhiteDropdown:SetValues(currentPlayers)
        task.wait(5)
    end
end)

MovementSection:AddToggle('TeleportToggle', {
    Text = 'Enable Teleport',
    Default = false,
    Callback = function(Value)
        Ragebot.Teleport = Value
    end
})

MovementSection:AddDropdown('TeleportModeDropdown', {
    Values = {'Behind', 'Above', 'Custom'},
    Default = 1,
    Text = 'Teleport Mode',
    Callback = function(Value)
        Ragebot.TeleportMode = Value
    end
})

MovementSection:AddInput('TeleportOffsetInput', {
    Text = 'Teleport Offset (x,y,z)',
    Default = '0,0,0',
    Callback = function(Value)
        local parts = string.split(Value, ",")
        if #parts == 3 then
            Ragebot.TeleportOffset = Vector3.new(tonumber(parts[1]), tonumber(parts[2]), tonumber(parts[3]))
        end
    end
})
MovementSection:AddToggle('TargetStrafeToggle', {
    Text = 'Enable Target Strafe',
    Default = false,
    Callback = function(Value)
        Ragebot.TargetStrafe = Value
    end
})

MovementSection:AddSlider('StrafeRadiusSlider', {
    Text = 'Strafe Radius',
    Default = 5,
    Min = 1,
    Max = 20,
    Rounding = 1,
    Callback = function(Value)
        Ragebot.StrafeRadius = Value
    end
})

MovementSection:AddSlider('StrafeSpeedSlider', {
    Text = 'Strafe Speed',
    Default = 20,
    Min = 1,
    Max = 500,
    Rounding = 1,
    Callback = function(Value)
        Ragebot.StrafeSpeed = Value
    end
})

MovementSection:AddDropdown('StrafeDirectionDropdown', {
    Values = {'Clockwise', 'CounterClockwise'},
    Default = 1,
    Text = 'Strafe Direction',
    Callback = function(Value)
        Ragebot.StrafeDirection = Value
    end
})
local function getClosestTarget()
    local closestTarget = nil
    local closestDistance = math.huge
    local localRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    
    if not localRoot then return nil end
    
    local playersToCheck = {}
    if Ragebot.ClosestMode then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and not table.find(Ragebot.WhiteList, player) then
                table.insert(playersToCheck, player)
            end
        end
    else
        playersToCheck = Ragebot.TargetList
    end
    
    for _, player in ipairs(playersToCheck) do
        if player and player.Character and not table.find(Ragebot.WhiteList, player) then
            local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart then
                local distance = (humanoidRootPart.Position - localRoot.Position).Magnitude
                if distance < closestDistance then
                    closestDistance = distance
                    closestTarget = player
                end
            end
        end
    end
    
    return closestTarget
end

local function teleportToTarget(target)
    if not target or not target.Character then return end
    
    local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
    local localRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    
    if not targetRoot or not localRoot then return end
    
    local offset = Ragebot.TeleportOffset
    local teleportPosition = targetRoot.Position
    
    if Ragebot.TeleportMode == "Behind" then
        teleportPosition = targetRoot.Position - targetRoot.CFrame.LookVector * 5
    elseif Ragebot.TeleportMode == "Above" then
        teleportPosition = targetRoot.Position + Vector3.new(0, 5, 0)
    elseif Ragebot.TeleportMode == "Custom" then
        teleportPosition = targetRoot.Position + offset
    end
    
    localRoot.CFrame = CFrame.new(teleportPosition)
end

local strafeAngle = 0
local currentTarget = nil

RunService.Heartbeat:Connect(function()
    if Ragebot.Teleport then
        local target = getClosestTarget()
        if target then
            teleportToTarget(target)
        end
    end
    
    if Ragebot.TargetStrafe then
        local target = getClosestTarget()
        if target and target.Character then
            local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
            local localRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            
            if targetRoot and localRoot then
                currentTarget = target
                
                local direction = Ragebot.StrafeDirection == "Clockwise" and 1 or -1
                strafeAngle = strafeAngle + (Ragebot.StrafeSpeed * 0.2 * direction)
                
                local circlePosition = targetRoot.Position + Vector3.new(
                    math.cos(strafeAngle) * Ragebot.StrafeRadius,
                    0,
                    math.sin(strafeAngle) * Ragebot.StrafeRadius
                )
                
                localRoot.CFrame = CFrame.new(circlePosition, targetRoot.Position)
            end
        end
    end
end)
     
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({'MenuKeybind'})
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder('LegitPlay')
SaveManager:SetFolder('LegitPlay/config')
ThemeManager:ApplyToTab(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Library:Notify('Legit.cc Loaded Successfully')

local mt = getrawmetatable(game)
local oldIndex = mt.__index
setreadonly(mt, false)

mt.__index = function(self, key)
    if key == "Hit" and Ragebot.Enabled then
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not root then return oldIndex(self, key) end

        local target, closest = nil, math.huge
        local playersToCheck = {}
        
        if Ragebot.ClosestMode then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and not table.find(Ragebot.WhiteList, player) then
                    table.insert(playersToCheck, player)
                end
            end
        else
            playersToCheck = Ragebot.TargetList
        end

        for _, player in ipairs(playersToCheck) do
            if player.Character and not table.find(Ragebot.WhiteList, player) then
                local part = player.Character:FindFirstChild(Ragebot.AimPart)
                local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                if part and humanoid and humanoid.Health > 0 then
                    local distance = (part.Position - root.Position).Magnitude
                    if distance < Ragebot.FOV and distance < closest then
                        target = part
                        closest = distance
                    end
                end
            end
        end

        if target then
            local velocity = target.Velocity
            local distance = (target.Position - root.Position).Magnitude
            local prediction = (distance / 100) * (velocity.Magnitude / 50)
            local offset = velocity.Unit * prediction
            local hitPosition = target.Position + offset

            if Ragebot.RichTracer then
                createRichTracer(root.Position, hitPosition)
            end

            if Ragebot.Tracer then
                local tracer = Instance.new("Part")
                tracer.Size = Vector3.new(0.1, 0.1, (hitPosition - root.Position).Magnitude)
                tracer.Anchored = true
                tracer.CanCollide = false
                tracer.Material = Enum.Material.Neon
                tracer.Color = Ragebot.TracerColor
                tracer.Transparency = 1
                tracer.CFrame = CFrame.lookAt(root.Position, hitPosition)
                tracer.Parent = Workspace

                local tweenIn = TweenService:Create(tracer, TweenInfo.new(0.3), {Transparency = 0.1})
                local tweenOut = TweenService:Create(tracer, TweenInfo.new(0.4), {Transparency = 1})

                tweenIn:Play()
                tweenIn.Completed:Connect(function() tweenOut:Play() end)
                tweenOut.Completed:Connect(function() tracer:Destroy() end)
            end

            if Ragebot.Wallbang then
                local ghost = Instance.new("Part")
                ghost.Size = Vector3.new(0.2, 0.2, (hitPosition - root.Position).Magnitude)
                ghost.Anchored = true
                ghost.CanCollide = false
                ghost.Material = Enum.Material.ForceField
                ghost.Color = Ragebot.TracerColor
                ghost.Transparency = 1
                ghost.CFrame = CFrame.lookAt(root.Position, hitPosition)
                ghost.Parent = Workspace

                local ghostTweenIn = TweenService:Create(ghost, TweenInfo.new(0.3), {Transparency = 0.3})
                local ghostTweenOut = TweenService:Create(ghost, TweenInfo.new(0.4), {Transparency = 1})

                ghostTweenIn:Play()
                ghostTweenIn.Completed:Connect(function() ghostTweenOut:Play() end)
                ghostTweenOut.Completed:Connect(function() ghost:Destroy() end)
            end

            return CFrame.new(hitPosition)
        end
    end

    return oldIndex(self, key)
end

setreadonly(mt, true)
task.spawn(function()
    while true do
        if Ragebot.Enabled then
            local character = LocalPlayer.Character
            if character then
                for _, obj in ipairs(character:GetDescendants()) do
                    if obj.Name == "Ammo" then obj.Value = 999 end
                end
            end
            local backpack = LocalPlayer:FindFirstChild("Backpack")
            if backpack then
                for _, obj in ipairs(backpack:GetDescendants()) do
                    if obj.Name == "Ammo" then obj.Value = 999 end
                end
            end
            for _, tool in ipairs(LocalPlayer.Backpack:GetChildren()) do
                if tool:IsA("Tool") then pcall(function() tool:Activate() end) end
            end
            for _, tool in ipairs(LocalPlayer.Character:GetChildren()) do
                if tool:IsA("Tool") then pcall(function() tool:Activate() end) end
            end
        end
        
        if Ragebot.HitSound then
            local sound = Instance.new("Sound")
            sound.SoundId = "rbxassetid://4817809188"
            sound.Parent = Workspace
            sound:Play()
            sound.Ended:Connect(function()
                sound:Destroy()
            end)
        end
        
        if Ragebot.HitNotify then
            local target = nil
            local closest = math.huge
            local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            
            if root then
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character then
                        local part = player.Character:FindFirstChild(Ragebot.AimPart)
                        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                        if part and humanoid and humanoid.Health > 0 then
                            local distance = (part.Position - root.Position).Magnitude
                            if distance < closest then
                                target = player
                                closest = distance
                            end
                        end
                    end
                end
                
                if target then
                    local humanoid = target.Character:FindFirstChildOfClass("Humanoid")
                    Library:Notify(string.format("Hit %s | Health: %d | Distance: %.1f", 
                        target.Name, math.floor(humanoid.Health), closest), 1)
                end
            end
        end
        
        task.wait(0.05)
    end
end)
