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
    HitNotify = false
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
    Settings = Window:AddTab('Settings'),
}

local MainSection = Tabs.Ragebot:AddLeftGroupbox('Main')
local TargetSection = Tabs.Ragebot:AddRightGroupbox('Targeting')
local VisualSection = Tabs.Ragebot:AddLeftGroupbox('Visuals')

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
