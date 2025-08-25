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

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

getgenv().Ragebot = {
	Enabled = true,
	AimPart = "HumanoidRootPart",
	FOV = 2500,
	Wallbang = true,
	Trancer = true,
	TrancerColor = Color3.fromRGB(199, 120, 221),
	FOVCircle = true,
	TargetList = {},
	WhiteList = {},
	PlayerNames = {}
}

local ColorThemes = {
	["Tokyo Night"] = Color3.fromRGB(199, 120, 221),
	["Midnight"] = Color3.fromRGB(25, 25, 112),
	["Ice Blue"] = Color3.fromRGB(173, 216, 230),
	["Sunset"] = Color3.fromRGB(255, 99, 71),
	["Matrix Green"] = Color3.fromRGB(0, 255, 0),
	["Cyberpunk"] = Color3.fromRGB(255, 0, 255),
	["Pastel Dream"] = Color3.fromRGB(255, 182, 193),
	["Blood Red"] = Color3.fromRGB(139, 0, 0),
	["Solar Flare"] = Color3.fromRGB(255, 165, 0),
	["Ocean Depth"] = Color3.fromRGB(0, 105, 148),
	["Ghost White"] = Color3.fromRGB(248, 248, 255),
	["Void"] = Color3.fromRGB(0, 0, 0)
}

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/Revenant", true))()
local CombatWindow = Library:Window({Text = "Combat"})
local TargetWindow = Library:Window({Text = "Targeting"})

CombatWindow:Toggle({
	Text = "Ragebot",
	Flag = "RageEnabled",
	Callback = function(bool)
		Ragebot.Enabled = bool
	end
})

CombatWindow:Toggle({
	Text = "Wallbang",
	Flag = "WallbangEnabled",
	Callback = function(bool)
		Ragebot.Wallbang = bool
	end
})

CombatWindow:Toggle({
	Text = "Trancer Setting",
	Flag = "TrancerEnabled",
	Callback = function(bool)
		Ragebot.Trancer = bool
	end
})

CombatWindow:Dropdown({
	Text = "Trancer style",
	Flag = "TrancerColorStyle",
	List = table.keys(ColorThemes),
	Callback = function(selected)
		local color = ColorThemes[selected]
		if color then
			Ragebot.TrancerColor = color
		end
	end
})

CombatWindow:Slider({
	Text = "FOV Range",
	Flag = "FOVSlider",
	Default = 150,
	Minimum = 50,
	Maximum = 2500,
	Callback = function(val)
		Ragebot.FOV = val
	end
})

CombatWindow:Toggle({
	Text = "Show FOV Circle",
	Flag = "FOVCircleEnabled",
	Callback = function(bool)
		Ragebot.FOVCircle = bool
	end
})

local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Color = Ragebot.TrancerColor
FOVCircle.Thickness = 2
FOVCircle.Filled = false
FOVCircle.Transparency = 1

RunService.RenderStepped:Connect(function()
	if Ragebot.FOVCircle then
		FOVCircle.Visible = true
		FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
		FOVCircle.Radius = Ragebot.FOV
		FOVCircle.Color = Ragebot.TrancerColor
	else
		FOVCircle.Visible = false
	end
end)

local function RefreshPlayerNames()
	Ragebot.PlayerNames = {}
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer then
			table.insert(Ragebot.PlayerNames, plr.Name)
		end
	end
end

task.spawn(function()
	while true do
		RefreshPlayerNames()
		task.wait(5)
	end
end)

TargetWindow:Dropdown({
	Text = "Add to TargetList",
	List = Ragebot.PlayerNames,
	Callback = function(name)
		local plr = Players:FindFirstChild(name)
		if plr and not table.find(Ragebot.TargetList, plr) then
			table.insert(Ragebot.TargetList, plr)
			Library:Notification({Text = "Added to TargetList: " .. name, Duration = 3})
		end
	end
})

TargetWindow:Dropdown({
	Text = "Add to WhiteList",
	List = Ragebot.PlayerNames,
	Callback = function(name)
		local plr = Players:FindFirstChild(name)
		if plr and not table.find(Ragebot.WhiteList, plr) then
			table.insert(Ragebot.WhiteList, plr)
			Library:Notification({Text = "Added to WhiteList: " .. name, Duration = 3})
		end
	end
})

TargetWindow:Button({
	Text = "Clear TargetList",
	Callback = function()
		Ragebot.TargetList = {}
		Library:Notification({Text = "TargetList Cleared", Duration = 2})
	end
})

TargetWindow:Button({
	Text = "Clear WhiteList",
	Callback = function()
		Ragebot.WhiteList = {}
		Library:Notification({Text = "WhiteList Cleared", Duration = 2})
	end
})

local mt = getrawmetatable(Mouse)
local oldIndex = mt.__index
setreadonly(mt, false)

mt.__index = function(self, key)
	if Ragebot.Enabled and key == "Hit" then
		local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		if not root then return oldIndex(self, key) end

		local target, closest = nil, math.huge
		for _, plr in ipairs(Ragebot.TargetList) do
			if plr ~= LocalPlayer and plr.Character and not table.find(Ragebot.WhiteList, plr) then
				local part = plr.Character:FindFirstChild(Ragebot.AimPart)
				local hum = plr.Character:FindFirstChildOfClass("Humanoid")
				if part and hum and hum.Health > 0 then
					local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
					if onScreen then
						local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)).Magnitude
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
			local lastVel = vel
			local acc = (vel - lastVel) / 0.1
		   
			local mag = vel.Magnitude
			local dir = vel.Unit
			local dist = (target.Position - root.Position).Magnitude
			local pred = (dist / 100) * (mag / 50)
			local offset = dir * pred + acc * 0.01
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

	return oldIndex(self, key)
end

setreadonly(mt, true)

task.spawn(function()
	while true do
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

		task.wait(0.05)
	end
end)
