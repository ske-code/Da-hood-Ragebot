--// Bypass
repeat
	task.wait()
until game:IsLoaded()
do
	local function isAdonisAC(table)
		return rawget(table, "Detected")
			and typeof(rawget(table, "Detected")) == "function"
			and rawget(table, "RLocked")
	end

	for _, v in next, getgc(true) do
		if typeof(v) == "table" and isAdonisAC(v) then
			for i, v in next, v do
				if rawequal(i, "Detected") then
					local old
					old = hookfunction(v, function(action, info, crash)
						if rawequal(action, "_") and rawequal(info, "_") and rawequal(crash, false) then
							return old(action, info, crash)
						end
						return task.wait(9e9)
					end)
					warn("bypassed")
					break
				end
			end
		end
	end
end
--// Main

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

getgenv().Ragebot = {
    Enabled = false,
    FOV = 250,
    AimPart = "Head",
    Wallbang = false,
    Trancer = false,
    TrancerColor = Color3.fromRGB(199, 120, 221),
    TargetList = {},
    WhiteList = {},
    PlayerNames = {}
}

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/cat"))()
local Window = Library:CreateWindow("LegitPlay.cc", Vector2.new(492, 598), Enum.KeyCode.RightControl)
local Tab = Window:CreateTab("Ragebot")
local Main = Tab:CreateSector("Main", "left")
local Target = Tab:CreateSector("Targeting", "left")

Main:AddToggle("Enable Ragebot", false, function(v)
    Ragebot.Enabled = v
end)

Main:AddSlider("FOV", 50, 2500, 250, 1, function(v)
    Ragebot.FOV = v
end)

Main:AddDropdown("Aim Part", {"Head", "HumanoidRootPart"}, "Head", false, function(v)
    Ragebot.AimPart = v
end)

Main:AddToggle("Wallbang", false, function(v)
    Ragebot.Wallbang = v
end)

local TrancerToggle = Main:AddToggle("Trancer", false, function(v)
    Ragebot.Trancer = v
end)

TrancerToggle:AddColorpicker(Ragebot.TrancerColor, function(c)
    Ragebot.TrancerColor = c
end)

local TargetDropdown = Target:AddDropdown("TargetList", {}, nil, false, function(name)
    local plr = Players:FindFirstChild(name)
    if plr and not table.find(Ragebot.TargetList, plr) then
        table.insert(Ragebot.TargetList, plr)
    end
end)

local WhiteDropdown = Target:AddDropdown("WhiteList", {}, nil, false, function(name)
    local plr = Players:FindFirstChild(name)
    if plr and not table.find(Ragebot.WhiteList, plr) then
        table.insert(Ragebot.WhiteList, plr)
    end
end)

Target:AddButton("Clear TargetList", function()
    Ragebot.TargetList = {}
end)

Target:AddButton("Clear WhiteList", function()
    Ragebot.WhiteList = {}
end)

Tab:CreateConfigSystem("right")

task.spawn(function()
    while true do
        Ragebot.PlayerNames = {}
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                table.insert(Ragebot.PlayerNames, plr.Name)
            end
        end
        task.wait(2)
    end
end)

task.spawn(function()
    while true do
        if Ragebot.Enabled then
            local char = LocalPlayer.Character
            if char then
                for _, obj in ipairs(char:GetDescendants()) do
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
        task.wait(0.05)
    end
end)

local mt = getrawmetatable(Mouse)
local old = mt.__index
setreadonly(mt, false)

mt.__index = function(self, key)
    if Ragebot.Enabled and key == "Hit" then
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not root then return old(self, key) end

        local target, closest = nil, math.huge
        for _, plr in ipairs(Ragebot.TargetList) do
            if plr ~= LocalPlayer and plr.Character and not table.find(Ragebot.WhiteList, plr) then
                local part = plr.Character:FindFirstChild(Ragebot.AimPart)
                local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                if part and hum and hum.Health > 0 then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - Camera.ViewportSize / 2).Magnitude
                        if dist < Ragebot.FOV and dist < closest then
                            target = part
                            closest = dist
                        end
                    end
                end
            end
        end

        if target then
            local vel = target.Velocity
            local dist = (target.Position - root.Position).Magnitude
            local pred = (dist / 100) * (vel.Magnitude / 50)
            local offset = vel.Unit * pred
            local hitPos = target.Position + offset

            if Ragebot.Trancer then
                local tracer = Instance.new("Part")
                tracer.Size = Vector3.new(0.1, 0.1, (hitPos - root.Position).Magnitude)
                tracer.Anchored = true
                tracer.CanCollide = false
                tracer.Material = Enum.Material.Neon
                tracer.Color = Ragebot.TrancerColor
                tracer.Transparency = 1
                tracer.CFrame = CFrame.lookAt(root.Position, hitPos)
                tracer.Parent = Workspace

                local tweenIn = TweenService:Create(tracer, TweenInfo.new(0.3), {Transparency = 0.1})
                local tweenOut = TweenService:Create(tracer, TweenInfo.new(0.4), {Transparency = 1})

                tweenIn:Play()
                tweenIn.Completed:Connect(function() tweenOut:Play() end)
                tweenOut.Completed:Connect(function() tracer:Destroy() end)
            end

            if Ragebot.Wallbang then
                local ghost = Instance.new("Part")
                ghost.Size = Vector3.new(0.2, 0.2, (hitPos - root.Position).Magnitude)
                ghost.Anchored = true
                ghost.CanCollide = false
                ghost.Material = Enum.Material.ForceField
                ghost.Color = Ragebot.TrancerColor
                ghost.Transparency = 1
                ghost.CFrame = CFrame.lookAt(root.Position, hitPos)
                ghost.Parent = Workspace

                local ghostTweenIn = TweenService:Create(ghost, TweenInfo.new(0.3), {Transparency = 0.3})
                local ghostTweenOut = TweenService:Create(ghost, TweenInfo.new(0.4), {Transparency = 1})

                ghostTweenIn:Play()
                ghostTweenIn.Completed:Connect(function() ghostTweenOut:Play() end)
                ghostTweenOut.Completed:Connect(function() ghost:Destroy() end)
            end

            return target
        end
    end

    return old(self, key)
end

setreadonly(mt, true)
