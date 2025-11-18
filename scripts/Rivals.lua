local VirtualInputManager = game:GetService("VirtualInputManager")
local runS = game:GetService("RunService")
local pl = game:GetService("Players")
local lp = pl.LocalPlayer
local char = lp.Character or lp.CharacterAdded:Wait()
local ws = game:GetService("Workspace")
local camera = workspace.CurrentCamera
local UIS = game:GetService("UserInputService")
local mousePPos = UIS:GetMouseLocation()
runS.RenderStepped:Connect(function() mousePPos = UIS:GetMouseLocation() end)
local Center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)

local FullSettings = {
    SilentAim = {
        Checks = {
            TeamCheck = false,
            WallCheck = false,
            AliveCheck = false
        },
        Fov = {
            Enable = false,
            Visible = false,
            Thickness = 0.6,
            Color = Color3.fromRGB(255, 255, 255),
            LockColor = Color3.fromRGB(255, 0, 0),
			OffColor = Color3.fromRGB(150, 150, 150),
            Filled = false,
            Size = 60
        },
        Values = {
            Enable = false,
            Toggle = true,
            HitPart = "HitboxHead",
			HitPartList = {"Head", "LeftFoot", "LeftHand", "LeftLowerArm", "LeftLowerLeg", "LeftUpperArm", "LowerTorso", "RightFoot", "RightHand", "RightLowerArm", "RightLowerLeg", "RightUpperArm", "RightUpperLeg", "UpperTorso", "HitboxBody", "FakeMass", "HitboxBodySmall", "HumanoidRootPart"},
            TriggerKey = Enum.KeyCode.Q,
        }
    },
	Esp = {
		Checks = {
            TeamCheck = false,
            WallCheck = false,
            AliveCheck = false
        },
		Values = {
			Enabled = false,
			FillColor = Color3.fromRGB(255, 255, 255),
			FillTransparency = 0.5,
			OutlineColor = Color3.fromRGB(200, 200, 200),
			OutlineTransparency = 0
        }
	}
}
--aimvot
local aimbotEnabled = false
local aimAtPart = "HumanoidRootPart"
local wallCheckEnabled = false
local targetNPCs = false
local teamCheckEnabled = false
local headSizeEnabled = false
local espEnabled = false

-- Functions
local function getClosestTarget()
    local closestTarget = nil
    local shortestDistance = math.huge

    for _, player in pairs(pl:GetPlayers()) do
        if player == lp then continue end
        if not player.Character then continue end
        if not player.Character:FindFirstChild("Humanoid") or player.Character.Humanoid.Health <= 0 then continue end
        if not player.Character:FindFirstChild(aimAtPart) then continue end

        local isTeammate = false
        if player.Character:FindFirstChild("HumanoidRootPart") then
            if player.Character.HumanoidRootPart:FindFirstChild("TeammateLabel") then
                isTeammate = true
            end
        end
        if teamCheckEnabled and isTeammate then continue end

        local targetPart = player.Character[aimAtPart]
        local screenPos, onScreen = camera:WorldToViewportPoint(targetPart.Position)
        
        if onScreen then
            local distance = (Vector2.new(screenPos.X, screenPos.Y) - Center).Magnitude
            
            local hit = false
            if wallCheckEnabled then
                local ray = workspace:Raycast(camera.CFrame.Position, (targetPart.Position - camera.CFrame.Position), RaycastParams.new({
                    FilterDescendantsInstances = {lp.Character},
                    FilterType = Enum.RaycastFilterType.Blacklist
                }))
                if ray and ray.Instance and ray.Instance:IsDescendantOf(player.Character) then
                    hit = true
                end
            else
                hit = true
            end

            if hit and distance < shortestDistance then
                shortestDistance = distance
                closestTarget = player.Character
            end
        end
    end

    return closestTarget
end

local function lookAt(targetPosition)
    local Cam = workspace.CurrentCamera
    if targetPosition then
        Cam.CFrame = CFrame.new(Cam.CFrame.Position, targetPosition)
    end
end

local function aimAtTarget()
    local runService = game:GetService("RunService")
    local connection
    connection = runService.RenderStepped:Connect(function()
        if not aimbotEnabled then
            connection:Disconnect()
            return
        end

        local closestTarget = getClosestTarget()
        if closestTarget and closestTarget:FindFirstChild(aimAtPart) then
            local targetRoot = closestTarget[aimAtPart]

            while aimbotEnabled and closestTarget and closestTarget:FindFirstChild(aimAtPart) and closestTarget.Humanoid.Health > 0 do
                lookAt(targetRoot.Position)
                local rayDirection = (targetRoot.Position - workspace.CurrentCamera.CFrame.Position).Unit * 1000
                local raycastParams = RaycastParams.new()
                raycastParams.FilterDescendantsInstances = {character}
                raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

                local raycastResult = workspace:Raycast(workspace.CurrentCamera.CFrame.Position, rayDirection, raycastParams)

                if not raycastResult or not raycastResult.Instance:IsDescendantOf(closestTarget) then
                    break
                end

                runService.RenderStepped:Wait()
            end
        end
    end)
end

local function resizeHeads()
    local Players = game:GetService("Players")
    local localPlayer = Players.LocalPlayer

    local function resizeHead(model)
        local head = model:FindFirstChild("Head")
        if head and head:IsA("BasePart") then
            head.Size = Vector3.new(5, 5, 5)
            head.CanCollide = false
        end
    end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character then
            resizeHead(player.Character)
        end
    end

    for _, npc in pairs(workspace:GetDescendants()) do
        if npc:IsA("Model") and npc:FindFirstChild("Head") then
            resizeHead(npc)
        end
    end
end


-- Load Orion Library
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/Skibidi50-lol/CherryWareSource/refs/heads/main/crackscript/src/ui/silentorion.lua')))()

local Window = OrionLib:MakeWindow({
    Name = "BloomWare",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "MyHub"
})

local AimFeatures = Window:MakeTab({
    Name = "Aim Features",
    Icon = "rbxassetid://7733765307",
    PremiumOnly = false
})

local VisualsTab = Window:MakeTab({
    Name = "Visuals",
    Icon = "rbxassetid://7733774602",
    PremiumOnly = false
})

local Section = AimFeatures:AddSection({
    Name = "Aimbot Settings"
})

AimFeatures:AddToggle({
    Name = "Camera Aimbot",
    Default = false,
    Callback = function(Value)
        aimbotEnabled = Value
        if aimbotEnabled then
            aimAtTarget()
        end
    end
})

AimFeatures:AddToggle({
    Name = "Wall Check",
    Default = false,
    Callback = function(Value)
        wallCheckEnabled = Value
    end
})

AimFeatures:AddToggle({
    Name = "Team Check",
    Default = false,
    Callback = function(Value)
        wallCheckEnabled = Value
    end
})

AimFeatures:AddToggle({
    Name = "Head Size",
    Default = false,
    Callback = function(Value)
        headSizeEnabled = Value
    end
})

AimFeatures:AddDropdown({
    Name = "Hit Part",
    Default = "HumanoidRootPart",
    Options = {"Head", "HumanoidRootPart"},
    Callback = function(Value)
        aimAtPart = Value
    end
})

-- Silent Aim Section
local SilentAimSection = AimFeatures:AddSection({
    Name = "Silent Aim Settings"
})

AimFeatures:AddToggle({
    Name = "Silent Aim",
    Default = FullSettings.SilentAim.Values.Enable,
    Callback = function(Value)
        FullSettings.SilentAim.Values.Enable = Value
    end
})

AimFeatures:AddBind({
    Name = "Aim Toggle Key",
    Default = FullSettings.SilentAim.Values.TriggerKey,
    Hold = false,
    Callback = function(Value)
        FullSettings.SilentAim.Values.TriggerKey = Value
    end
})

AimFeatures:AddToggle({
    Name = "Team Check",
    Default = FullSettings.SilentAim.Checks.TeamCheck,
    Callback = function(Value)
        FullSettings.SilentAim.Checks.TeamCheck = Value
    end
})

AimFeatures:AddToggle({
    Name = "Wall Check",
    Default = FullSettings.SilentAim.Checks.WallCheck,
    Callback = function(Value)
        FullSettings.SilentAim.Checks.WallCheck = Value
    end
})

AimFeatures:AddToggle({
    Name = "Alive Check",
    Default = FullSettings.SilentAim.Checks.AliveCheck,
    Callback = function(Value)
        FullSettings.SilentAim.Checks.AliveCheck = Value
    end
})

AimFeatures:AddDropdown({
    Name = "Hit Part",
    Default = FullSettings.SilentAim.Values.HitPart,
    Options = FullSettings.SilentAim.Values.HitPartList,
    Callback = function(Value)
        FullSettings.SilentAim.Values.HitPart = Value
    end
})

-- FOV Section
local FovSection = AimFeatures:AddSection({
    Name = "FOV Circle"
})

AimFeatures:AddToggle({
    Name = "Visible",
    Default = FullSettings.SilentAim.Fov.Visible,
    Callback = function(Value)
        FullSettings.SilentAim.Fov.Visible = Value
    end
})

AimFeatures:AddToggle({
    Name = "Enable (Aim Check)",
    Default = FullSettings.SilentAim.Fov.Enable,
    Callback = function(Value)
        FullSettings.SilentAim.Fov.Enable = Value
    end
})

AimFeatures:AddToggle({
    Name = "Filled",
    Default = FullSettings.SilentAim.Fov.Filled,
    Callback = function(Value)
        FullSettings.SilentAim.Fov.Filled = Value
    end
})

AimFeatures:AddSlider({
    Name = "Size",
    Min = 0,
    Max = 200,
    Default = FullSettings.SilentAim.Fov.Size,
    Color = Color3.fromRGB(255,255,255),
    Increment = 1,
    ValueName = "px",
    Callback = function(Value)
        FullSettings.SilentAim.Fov.Size = Value
    end
})

AimFeatures:AddSlider({
    Name = "Thickness",
    Min = 0.1,
    Max = 5,
    Default = FullSettings.SilentAim.Fov.Thickness * 10,
    Color = Color3.fromRGB(255,255,255),
    Increment = 0.1,
    ValueName = "px",
    Callback = function(Value)
        FullSettings.SilentAim.Fov.Thickness = Value / 10
    end
})

AimFeatures:AddColorpicker({
    Name = "Color",
    Default = FullSettings.SilentAim.Fov.Color,
    Callback = function(Value)
        FullSettings.SilentAim.Fov.Color = Value
    end
})

AimFeatures:AddColorpicker({
    Name = "Lock Color",
    Default = FullSettings.SilentAim.Fov.LockColor,
    Callback = function(Value)
        FullSettings.SilentAim.Fov.LockColor = Value
    end
})

AimFeatures:AddColorpicker({
    Name = "Off Color",
    Default = FullSettings.SilentAim.Fov.OffColor,
    Callback = function(Value)
        FullSettings.SilentAim.Fov.OffColor = Value
    end
})

-- ESP Section
local EspSection = VisualsTab:AddSection({
    Name = "Chams ESP"
})

VisualsTab:AddToggle({
    Name = "Enabled",
    Default = FullSettings.Esp.Values.Enabled,
    Callback = function(Value)
        FullSettings.Esp.Values.Enabled = Value
    end
})

VisualsTab:AddToggle({
    Name = "Team Check",
    Default = FullSettings.Esp.Checks.TeamCheck,
    Callback = function(Value)
        FullSettings.Esp.Checks.TeamCheck = Value
    end
})

VisualsTab:AddToggle({
    Name = "Wall Check",
    Default = FullSettings.Esp.Checks.WallCheck,
    Callback = function(Value)
        FullSettings.Esp.Checks.WallCheck = Value
    end
})

VisualsTab:AddToggle({
    Name = "Alive Check",
    Default = FullSettings.Esp.Checks.AliveCheck,
    Callback = function(Value)
        FullSettings.Esp.Checks.AliveCheck = Value
    end
})

VisualsTab:AddColorpicker({
    Name = "Fill Color",
    Default = FullSettings.Esp.Values.FillColor,
    Callback = function(Value)
        FullSettings.Esp.Values.FillColor = Value
    end
})

VisualsTab:AddSlider({
    Name = "Fill Transparency",
    Min = 0,
    Max = 1,
    Default = FullSettings.Esp.Values.FillTransparency,
    Color = Color3.fromRGB(255,255,255),
    Increment = 0.01,
    ValueName = "",
    Callback = function(Value)
        FullSettings.Esp.Values.FillTransparency = Value
    end
})

VisualsTab:AddColorpicker({
    Name = "Outline Color",
    Default = FullSettings.Esp.Values.OutlineColor,
    Callback = function(Value)
        FullSettings.Esp.Values.OutlineColor = Value
    end
})

VisualsTab:AddSlider({
    Name = "Outline Transparency",
    Min = 0,
    Max = 1,
    Default = FullSettings.Esp.Values.OutlineTransparency,
    Color = Color3.fromRGB(255,255,255),
    Increment = 0.01,
    ValueName = "",
    Callback = function(Value)
        FullSettings.Esp.Values.OutlineTransparency = Value
    end
})

-- Now the original code blocks, with FOV updates in RenderStepped
do
	local FOV = Drawing.new("Circle")
	FOV.Thickness = FullSettings.SilentAim.Fov.Thickness
	FOV.Color = FullSettings.SilentAim.Fov.Color
	FOV.Filled = FullSettings.SilentAim.Fov.Filled
	FOV.Radius = FullSettings.SilentAim.Fov.Size
	FOV.Position = mousePPos
	FOV.Visible = FullSettings.SilentAim.Fov.Visible

	runS.RenderStepped:Connect(function() 
		mousePPos = UIS:GetMouseLocation()
		FOV.Position = mousePPos
		FOV.Radius = FullSettings.SilentAim.Fov.Size
		FOV.Filled = FullSettings.SilentAim.Fov.Filled
		FOV.Thickness = FullSettings.SilentAim.Fov.Thickness
		FOV.Visible = FullSettings.SilentAim.Fov.Visible
	end)

	coroutine.wrap(function ()
		local lock = false

		local function GetPartToFov(Part)
			for _, v in ipairs(pl:GetPlayers()) do
				if v ~= lp and v.Character and v.Character:FindFirstChild(Part) then
					if FullSettings.SilentAim.Checks.AliveCheck and v.Character:FindFirstChildOfClass("Humanoid") and v.Character.Humanoid.Health <= 0 then continue end

					local ray = workspace:FindPartOnRayWithIgnoreList(
						Ray.new(camera.CFrame.Position, 
						(v.Character[Part].Position - camera.CFrame.Position).Unit * 
						(v.Character[Part].Position - camera.CFrame.Position).Magnitude),
							{lp.Character, camera}
					)

					if FullSettings.SilentAim.Checks.WallCheck and (not ray or not ray:IsDescendantOf(v.Character)) then continue end
					if FullSettings.SilentAim.Checks.TeamCheck and v.Character:FindFirstChild("HumanoidRootPart") and v.Character.HumanoidRootPart:FindFirstChild("TeammateLabel") then continue end
					local vPos = camera:WorldToViewportPoint(v.Character[Part].Position)
					local distance = (Vector2.new(vPos.X, vPos.Y) - mousePPos).Magnitude
					
					if FullSettings.SilentAim.Fov.Enable and (distance > FullSettings.SilentAim.Fov.Size) then continue end
					return v
				end
			end
		end

		UIS.InputBegan:Connect(function(input, gameProcessedEvent)
			if gameProcessedEvent then return end
			if input.KeyCode == FullSettings.SilentAim.Values.TriggerKey then
				lock = not lock
			end
		end)

		while task.wait() do
			if FullSettings.SilentAim.Values.Enable then
				if not lp.PlayerGui.MainGui.MainFrame.Lobby.Currency.Visible then
					local Target = nil
					Target = GetPartToFov(FullSettings.SilentAim.Values.HitPart)

					if Target ~= nil then
						FOV.Color = FullSettings.SilentAim.Fov.LockColor
					else
						FOV.Color = FullSettings.SilentAim.Fov.Color
					end

					if lock == false then
						FOV.Color = FullSettings.SilentAim.Fov.OffColor
					end

					if Target and Target.Character and Target.Character:FindFirstChild(FullSettings.SilentAim.Values.HitPart) and lock and camera:WorldToViewportPoint(Target.Character[FullSettings.SilentAim.Values.HitPart].Position).Z > 0 then
						camera.CFrame = CFrame.new(camera.CFrame.Position + (Target.Character[FullSettings.SilentAim.Values.HitPart].Position - camera.CFrame.Position).Unit * 0.5, Target.Character[FullSettings.SilentAim.Values.HitPart].Position)
						
						VirtualInputManager:SendMouseButtonEvent(Center.X, Center.Y, 0, true, game, 0)
						task.wait()
						VirtualInputManager:SendMouseButtonEvent(Center.X, Center.Y, 0, false, game, 0)
					end
				end
			else
				FOV.Color = FullSettings.SilentAim.Fov.OffColor
			end
		end
	end)()
end

do
	coroutine.wrap(function ()
		while task.wait() do
			for _, v in pairs(pl:GetPlayers()) do
				if v ~= lp and v.Character then
					local Esp = v.Character:FindFirstChild("Esp")

					if FullSettings.Esp.Checks.AliveCheck and v.Character:FindFirstChildOfClass("Humanoid") and v.Character.Humanoid.Health <= 0 then  if Esp then Esp:Destroy() end continue end
					if FullSettings.Esp.Checks.TeamCheck and v.Character:FindFirstChild("HumanoidRootPart") and v.Character.HumanoidRootPart:FindFirstChild("TeammateLabel") then if Esp then Esp:Destroy() end continue end
					if not Esp then
						Esp = Instance.new("Highlight")
						Esp.RobloxLocked = true
						Esp.Name = "Esp"
						Esp.Adornee = v.Character
						Esp.Parent = v.Character
					end

					if Esp then
						if FullSettings.Esp.Checks.WallCheck then
							Esp.DepthMode = Enum.HighlightDepthMode.Occluded
						else
							Esp.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
						end
						
						Esp.Enabled = FullSettings.Esp.Values.Enabled
						Esp.FillColor = FullSettings.Esp.Values.FillColor
						Esp.FillTransparency = FullSettings.Esp.Values.FillTransparency
						Esp.OutlineColor = FullSettings.Esp.Values.OutlineColor
						Esp.OutlineTransparency = FullSettings.Esp.Values.OutlineTransparency
					end
				end
			end
		end
	end)()
end

OrionLib:Init()
