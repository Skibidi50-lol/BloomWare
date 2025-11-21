
--BEST SCRIPT???!!??!?!?!?!??!?!?!?!?!
local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

Library:Notify({
    Title = "BloomWare",
    Description = "OwO Script made by Skibidi50-lol :3",
    Time = 3,
})

local dhlock = loadstring(game:HttpGet("https://raw.githubusercontent.com/Stratxgy/DH-Lua-Lock/refs/heads/main/Main.lua"))()

local Options = Library.Options
local Toggles = Library.Toggles

Library.ShowToggleFrameInKeybinds = true -- Make toggle keybinds work inside the keybinds UI (aka adds a toggle to the UI). Good for mobile users (Default value = true)

local Window = Library:CreateWindow({
	Title = "BloomWare | ".. (identifyexecutor()),
	Footer = "Version 1.01 - All Executor Supported",
	Icon = nil,
	NotifySide = "Right",
	ShowCustomCursor = true,
})
--mobile aimbot OwO
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local mobileAim = {
    Enabled = false,
    Part = "Head",
    Smoothness = 0.24,
    TeamCheck = false,
    WallCheck = false,
    FOVCircle = false,
    FOVRadius = 120,
}

local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 3
FOVCircle.NumSides = 64
FOVCircle.Radius = mobileAim.FOVRadius
FOVCircle.Color = Color3.fromRGB(255, 0, 100)  -- Pink OwO
FOVCircle.Transparency = 0.6
FOVCircle.Filled = false
FOVCircle.Position = Vector2.new(0, 0)

-- Update FOV Circle Position (Always Center Screen)
local fovConnection
local function updateFOVCircle()
    if fovConnection then fovConnection:Disconnect() end
    fovConnection = RunService.RenderStepped:Connect(function()
        if not mobileAim.FOVCircle then 
            FOVCircle.Visible = false
            return 
        end
        
        local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        FOVCircle.Position = center
        FOVCircle.Visible = true
        FOVCircle.Radius = mobileAim.FOVRadius
    end)
end

-- FIXED Team Check
local plr = game:GetService("Players").LocalPlayer

local function isPrisonEnemy(plr)
    if plr == LocalPlayer then return false end
    if not plr.Character or not plr.Character:FindFirstChild("Humanoid") or plr.Character.Humanoid.Health <= 0 then
        return false
    end

    if not mobileAim.TeamCheck then return true end

    return plr.Team ~= LocalPlayer.Team
end

-- Get closest target WITH FOV CHECK
local function getTarget()
    local closest = nil
    local closestDist = math.huge
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, plr in Players:GetPlayers() do
        if isPrisonEnemy(plr) then  -- NOW SKIPS OTHER INMATES!
            local char = plr.Character
            if char and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
                local part = char:FindFirstChild(mobileAim.Part) or char:FindFirstChild("HumanoidRootPart")
                if part then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                    if onScreen then
                        -- FOV CHECK
                        local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                        if screenDist > mobileAim.FOVRadius then continue end
                        
                        local canSee = true
                        if mobileAim.WallCheck then
                            local direction = (part.Position - Camera.CFrame.Position)
                            local raycastParams = RaycastParams.new()
                            raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
                            raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
                            local raycastResult = Workspace:Raycast(Camera.CFrame.Position, direction.Unit * 500, raycastParams)
                            canSee = not raycastResult or raycastResult.Instance:IsDescendantOf(char)
                        end
                        
                        if canSee then
                            local dist = (root.Position - part.Position).Magnitude
                            if dist < closestDist then
                                closestDist = dist
                                closest = part
                            end
                        end
                    end
                end
            end
        end
    end
    return closest
end

local connection
local function startAim()
    if connection then connection:Disconnect() end
    connection = RunService.RenderStepped:Connect(function()
        if not mobileAim.Enabled or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
        local target = getTarget()
        if target then
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Position), mobileAim.Smoothness)
        end
    end)
end


--tabs
local Tabs = {
    Info = Window:AddTab("Information", "info"),
    Main = Window:AddTab("Main", "target"),
    Visual = Window:AddTab("Visuals", "eye"),
    World = Window:AddTab("World", "eclipse"),
    ["UI Settings"] = Window:AddTab("UI Settings", "settings"),
}
--info
local infoBox = Tabs.Info:AddLeftGroupbox("Script Information", "info")

infoBox:AddLabel("[<font color=\"rgb(73, 230, 133)\">Update Note</font>]")
infoBox:AddLabel("[+] Become Criminal")
infoBox:AddLabel("[<font color=\"rgb(230, 73, 73)\">Remove CFrame Speed</font>]")


-- Aimbot / Aimlock Groupbox
local aimbotBox = Tabs.Main:AddLeftGroupbox("Aimbot", "target")
-- Main Toggle
aimbotBox:AddCheckbox("AimbotToggle", {
    Text = "Enable Aimbot",
    Default = false,
    Tooltip = "Master switch for the aimbot"
}):OnChanged(function(Value)
    getgenv().dhlock.enabled = Value
end)

-- FOV Settings
aimbotBox:AddCheckbox("ShowFOV", {
    Text = "Show FOV Circle",
    Default = false,
}):OnChanged(function(Value)
    getgenv().dhlock.showfov = Value
end)

aimbotBox:AddSlider("FOVRadius", {
    Text = "FOV Radius",
    Default = 80,
    Min = 10,
    Max = 600,
    Rounding = 0,
    Suffix = "px"
}):OnChanged(function(Value)
    getgenv().dhlock.fov = Value
end)

-- Target Part
aimbotBox:AddDropdown("LockPart", {
    Values = { "Head", "HumanoidRootPart", "UpperTorso", "LowerTorso" },
    Default = "Head",
    Text = "Target Part (Ground)"
}):OnChanged(function(Value)
    getgenv().dhlock.lockpart = Value
end)

aimbotBox:AddDropdown("LockPartAir", {
    Values = { "Head", "HumanoidRootPart", "UpperTorso", "LowerTorso" },
    Default = "Head",
    Text = "Target Part (Air)"
}):OnChanged(function(Value)
    getgenv().dhlock.lockpartair = Value
end)

-- Checks
aimbotBox:AddCheckbox("TeamCheck", {
    Text = "Team Check",
    Default = false,
    Tooltip = "Won't lock onto teammates"
}):OnChanged(function(Value)
    getgenv().dhlock.teamcheck = Value
end)

aimbotBox:AddCheckbox("WallCheck", {
    Text = "Wall Check",
    Default = false,
    Tooltip = "Only locks if target is visible"
}):OnChanged(function(Value)
    getgenv().dhlock.wallcheck = Value
end)

aimbotBox:AddCheckbox("AliveCheck", {
    Text = "Alive Check",
    Default = false
}):OnChanged(function(Value)
    getgenv().dhlock.alivecheck = Value
end)

-- Prediction (very important for fast-paced games)
aimbotBox:AddDivider()
aimbotBox:AddLabel("Prediction Settings", true)

aimbotBox:AddSlider("PredictX", {
    Text = "Horizontal Prediction",
    Default = 0.13,
    Min = 0,
    Max = 0.5,
    Rounding = 3,
}):OnChanged(function(Value)
    getgenv().dhlock.predictionX = Value
end)

aimbotBox:AddSlider("PredictY", {
    Text = "Vertical Prediction",
    Default = 0.14,
    Min = 0,
    Max = 0.5,
    Rounding = 3,
}):OnChanged(function(Value)
    getgenv().dhlock.predictionY = Value
end)

-- Smoothness
aimbotBox:AddSlider("Smoothness", {
    Text = "Smoothness",
    Default = 0.04,
    Min = 0,
    Max = 1,
    Rounding = 3,
    Tooltip = "0 = instant, higher = smoother/slower"
}):OnChanged(function(Value)
    getgenv().dhlock.smoothness = Value
end)

-- Activation Mode
aimbotBox:AddDropdown("ActivationMode", {
    Values = { "Hold", "Toggle" },
    Default = "Hold",
    Text = "Activation Mode"
}):OnChanged(function(Value)
    getgenv().dhlock.toggle = (Value == "Toggle")
end)

local mobileBox = Tabs.Main:AddRightGroupbox("Mobile Aimlock", "crosshair")
mobileBox:AddCheckbox("MobileAimToggle", {
    Text = "Enable Mobile Aimlock",
    Default = false,
    Tooltip = "Silent camera aim (perfect for mobile)"
}):OnChanged(function(val)
   mobileAim.Enabled = val
    if val then
        startAim()
        Library:Notify({Title = "Mobile Aimlock", Description = "Activated!", Time = 3})
    else
        if aimConnection then aimConnection:Disconnect() end
    end
end)

mobileBox:AddCheckbox("FOVCircle", {
    Text = "Show FOV Circle",
    Default = false
}):OnChanged(function(v)
    mobileAim.FOVCircle = v
    updateFOVCircle()
end)

mobileBox:AddSlider("FOVRadius", {
    Text = "FOV Size",
    Default = 120,
    Min = 50,
    Max = 400,
    Rounding = 0,
    Suffix = "px"
}):OnChanged(function(v)
    mobileAim.FOVRadius = v
end)

mobileBox:AddDropdown("MobileAimPart", {
    Values = {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso"},
    Default = "Head",
    Text = "Target Part"
}):OnChanged(function(val)
    mobileAim.Part = val
end)

mobileBox:AddCheckbox("MobileWallCheck", {
    Text = "Visibility Check",
    Default = false,
}):OnChanged(function(val)
    mobileAim.WallCheck = val
end)

mobileBox:AddSlider("MobileSmoothness", {
    Text = "Smoothness",
    Default = 0.25,
    Min = 0.01,
    Max = 1,
    Rounding = 2,
}):OnChanged(function(val)
    mobileAim.Smoothness = val
end)
--combat
local combatBox = Tabs.Main:AddRightGroupbox("Combat", "sword")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local me = Players.LocalPlayer
local remote = ReplicatedStorage.Remotes.ArrestPlayer

local AutoArrest = false
shared.Aura = false

combatBox:AddCheckbox("combatToggle", {
    Text = "Auto Arrest",
    Default = false,
}):OnChanged(function(Value)
    AutoArrest = Value
    RunService.Heartbeat:Connect(function()
    if not AutoArrest then return end
    local root = me.Character and me.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    for _, plr in Players:GetPlayers() do
        if plr == me then continue end
        local char = plr.Character
        if not char then continue end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChild("Humanoid")
        if not hrp or not hum or hum.Health <= 0 then continue end
        if (root.Position - hrp.Position).Magnitude <= 10 then
            task.spawn(function()
                pcall(remote.InvokeServer, remote, plr)
            end)
        end
    end
end)
end)

combatBox:AddCheckbox("auraToggle", {
    Text = "Auto Attack",
    Default = false,
}):OnChanged(function(Value)
    shared.Aura = Value
    local cloneref = cloneref or function(obj)
    return obj
end
local playersService = cloneref(game:GetService('Players'))
local replicatedStorage = cloneref(game:GetService('ReplicatedStorage'))
local lplr = playersService.LocalPlayer

local function getClosestPlayer()
    local closestdist, closestplr = math.huge, nil
    for i,v in playersService:GetPlayers() do
        if v == lplr then continue end

        pcall(function()
            local dist = lplr:DistanceFromCharacter(v.Character.PrimaryPart.Position)
            if dist < 6 and dist < closestdist then
                closestdist = dist
                closestplr = v
            end
        end)
    end

    return closestplr
end

task.spawn(function()
    repeat
        local plr = getClosestPlayer()
        if plr then
            replicatedStorage.meleeEvent:FireServer(plr)
        end

        task.wait()
    until not shared.Aura
end)
end)

_G.autore = false

combatBox:AddCheckbox("aureToggle", {
    Text = "Auto Respawn",
    Default = false,
}):OnChanged(function(Value)
    _G.autore = Value

    spawn(function()
        while task.wait() and _G.autore do
            if game.Players.LocalPlayer.Character.Humanoid.Health < 0.10 then 
                local lastCamPos = workspace.Camera.CFrame
                local lastPos = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
                wait(0.3)
                if game.Players.LocalPlayer.TeamColor.Name == "Bright blue" then
                    workspace.Remote.TeamEvent:FireServer("Bright blue")
                elseif game.Players.LocalPlayer.TeamColor.Name == "Bright orange" then
                    workspace.Remote.TeamEvent:FireServer("Bright orange")
                elseif game.Players.LocalPlayer.TeamColor.Name == "Really red" then
                    workspace.Remote.TeamEvent:FireServer("Bright blue")
                    wait(0.5)
                    if not game.Players.LocalPlayer.TeamColor.Name == "Bright blue" then
                        workspace.Remote.TeamEvent:FireServer("Bright orange")
                    end
                    wait(0.2)
                    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-975, 112, 2055)
                end
                wait(0.7)
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = lastPos
                workspace.Camera.CFrame = lastCamPos
            end
        end
    end)
end)


combatBox:AddButton({
    Text = "No Anti Jump",
    Func = function()
        local PL = game:GetService("Players").LocalPlayer
        local PC = pcall

        local CH = PL.Character or PL.CharacterAdded:Wait()

        local TS = CH:FindFirstChild("AntiJump")

        if TS and TS:IsA("LocalScript") then
            PC(function()
                TS:Destroy()
            end)
        end
        Library:Notify({
            Title = "No Anti Jump",
            Description = "Applied",
            Time = 4,
        })
    end
})
combatBox:AddDivider()
combatBox:AddLabel("Players", true)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local TargetKillAura = {
    Enabled = false,
    Target = nil,
    Connection = nil
}

-- Get player names (exclude self)
local function getPlayerNames()
    local names = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            table.insert(names, plr.Name)
        end
    end
    return names
end

-- Dropdown + Refresh
local targetDropdown = combatBox:AddDropdown("TargetKillPlayer", {
    Values = getPlayerNames(),
    Default = 1,
    Text = "Select Player",
})

combatBox:AddButton({
    Text = "Refresh Players",
    Func = function()
        targetDropdown:SetValues(getPlayerNames())
        Library:Notify({Title = "Target Kill Aura", Description = "Player list updated!", Time = 2})
    end
})

combatBox:AddDivider()

combatBox:AddCheckbox("TargetKillAuraToggle", {
    Text = "Target Kill",
    Default = false,
    Tooltip = "Teleports under the selected player's feet and kills them safely"
}):OnChanged(function(state)
    TargetKillAura.Enabled = state

    if state then
        local targetName = targetDropdown.Value
        if not targetName then
            Library:Notify({Title = "Error", Description = "Select a player first!", Time = 3})
            Options.TargetKillAuraToggle.Value = false
            return
        end

        local targetPlr = Players:FindFirstChild(targetName)
        if not targetPlr or not targetPlr.Character or not targetPlr.Character:FindFirstChild("HumanoidRootPart") then
            Library:Notify({Title = "Error", Description = "Target not spawned or invalid!", Time = 3})
            Options.TargetKillAuraToggle.Value = false
            return
        end

        TargetKillAura.Target = targetPlr

        Library:Notify({
            Title = "Target Kill ON",
            Description = "Now hunting " .. targetName .. " (under feet mode)",
            Time = 4
        })

        -- MAIN LOOP - TP UNDER FEET (SAFE)
        TargetKillAura.Connection = RunService.Heartbeat:Connect(function()
            if not TargetKillAura.Enabled or not TargetKillAura.Target then return end

            local targetChar = TargetKillAura.Target.Character
            local myChar = LocalPlayer.Character
            if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end

            local myRoot = myChar.HumanoidRootPart
            local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
            local targetHum = targetChar:FindFirstChild("Humanoid")

            -- Target died or left
            if not targetRoot or not targetHum or targetHum.Health <= 0 then
                Library:Notify({
                    Title = "Target Killed!",
                    Description = TargetKillAura.Target.Name .. " has been eliminated!",
                    Time = 5
                })
                TargetKillAura.Enabled = false
                Options.TargetKillAuraToggle.Value = false
                return
            end

            local underFeetY = targetRoot.Position.Y - 4

            -- Tiny random offset so it doesn't look robotic
            local offset = Vector3.new(
                math.random(-60, 60) / 100,  -- -0.6 to +0.6 studs
                0,
                math.random(-60, 60) / 100
            )

            local underPos = Vector3.new(
                targetRoot.Position.X + offset.X,
                underFeetY,
                targetRoot.Position.Z + offset.Z
            )

            -- Teleport + look up at target
            myRoot.CFrame = CFrame.new(underPos, targetRoot.Position + Vector3.new(0, 2, 0))

            -- Spam melee only when close enough
            if (myRoot.Position - targetRoot.Position).Magnitude <= 9 then
                pcall(function()
                    ReplicatedStorage.meleeEvent:FireServer(TargetKillAura.Target)
                end)
            end

            task.wait()
        end)

    else
        -- Turn off
        if TargetKillAura.Connection then
            TargetKillAura.Connection:Disconnect()
            TargetKillAura.Connection = nil
        end
        TargetKillAura.Target = nil
        Library:Notify({Title = "Target Kill", Description = "Disabled", Time = 2})
    end
end)

local TargetArrest = {
    Enabled = false,
    Target = nil,
    Connection = nil
}

combatBox:AddDivider()

combatBox:AddCheckbox("TargetArrestToggle", {
    Text = "Target Arrest",
    Default = false,
    Tooltip = "Arrests ONLY the player in the dropdown"
}):OnChanged(function(state)
    TargetArrest.Enabled = state

    if state then
        local targetName = targetDropdown.Value
        if not targetName then
            Library:Notify({Title = "Target Arrest", Description = "Select a player first!", Time = 3})
            Options.TargetArrestToggle.Value = false
            return
        end

        local targetPlr = Players:FindFirstChild(targetName)
        if not targetPlr or not targetPlr.Character or not targetPlr.Character:FindFirstChild("HumanoidRootPart") then
            Library:Notify({Title = "Target Arrest", Description = "Target not in game!", Time = 3})
            Options.TargetArrestToggle.Value = false
            return
        end

        TargetArrest.Target = targetPlr

        Library:Notify({
            Title = "Target Arrest ON",
            Description = "Now arresting only: " .. targetName,
            Time = 4
        })

        -- EXACT SAME METHOD AS YOUR ORIGINAL AUTO ARREST (just filtered)
        TargetArrest.Connection = RunService.Heartbeat:Connect(function()
            if not TargetArrest.Enabled or not TargetArrest.Target then return end

            local myChar = LocalPlayer.Character
            local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
            if not myRoot then return end

            local targetChar = TargetArrest.Target.Character
            local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
            local targetHum = targetChar and targetChar:FindFirstChild("Humanoid")

            if not targetRoot or not targetHum or targetHum.Health <= 0 then
                Library:Notify({Title = "Target Arrest", Description = "Player died or arrested!", Time = 3})
                TargetArrest.Enabled = false
                Options.TargetArrestToggle.Value = false
                return
            end

            -- Safe under-feet TP (same as Target Kill)
            local underY = targetRoot.Position.Y - 3.8
            local offset = Vector3.new(math.random(-50,50)/100, 0, math.random(-50,50)/100)
            local safePos = Vector3.new(targetRoot.Position.X + offset.X, underY, targetRoot.Position.Z + offset.Z)

            myRoot.CFrame = CFrame.new(safePos, targetRoot.Position)

            -- Your ORIGINAL arrest remote (exactly as Auto Arrest uses)
            if (myRoot.Position - targetRoot.Position).Magnitude <= 12 then
                task.spawn(function()
                    pcall(function()
                        ReplicatedStorage.Remotes.ArrestPlayer:InvokeServer(TargetArrest.Target)
                    end)
                end)
            end

            task.wait()
        end)

    else
        if TargetArrest.Connection then
            TargetArrest.Connection:Disconnect()
            TargetArrest.Connection = nil
        end
        TargetArrest.Target = nil
        Library:Notify({Title = "Target Arrest", Description = "Disabled", Time = 2})
    end
end)

local giverBox = Tabs.Main:AddRightGroupbox("Teleporter", "circle-small")

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

local TWEEN_TIME = 5
local tweenInfo = TweenInfo.new(TWEEN_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local GUN_NAME = "AK-47"

local function getGiverPosition(giver)
    if giver:IsA("Model") then
        if giver.PrimaryPart then
            return giver.PrimaryPart.Position
        else
            return giver:GetPivot().Position
        end
    else
        return giver.Position
    end
end

local function findGunGiver(gunName)
    for _, obj in workspace:GetDescendants() do
        if obj.Name == "TouchGiver" and obj:GetAttribute("ToolName") == gunName then
            return obj
        end
    end
    return nil
end

local function tweenTo(pos)
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    local tween = TweenService:Create(hrp, tweenInfo, {CFrame = CFrame.new(pos)})
    tween:Play()
    tween.Completed:Wait()
end

local function getSingleGun()
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    local originalPos = hrp.Position

    local giver = findGunGiver(GUN_NAME)
    if not giver then
        print("❌ " .. GUN_NAME .. " not found! Check name or wait for spawner.")
        return
    end

    print("Getting " .. GUN_NAME .. "...")
    local pos = getGiverPosition(giver) + Vector3.new(0, 5, 0)
    
    tweenTo(pos)
    
    if player.Backpack:FindFirstChild(GUN_NAME) or char:FindFirstChild(GUN_NAME) then
        print("✅ Successfully got " .. GUN_NAME .. "!")
    else
        print("❌ Failed to get " .. GUN_NAME)
    end
end

giverBox:AddButton({
    Text = "Get AK-47",
    Func = function()
        GUN_NAME = "AK-47"
        Library:Notify({
            Title = "Escape Prison",
            Description = "Try To Tween To Gun.....",
            Time = 4,
        })
        -- Run now
        getSingleGun()
        
    end
})

giverBox:AddButton({
    Text = "Get Remington 870",
    Func = function()
        GUN_NAME = "Remington 870"
        Library:Notify({
            Title = "Escape Prison",
            Description = "Try To Tween To Gun.....",
            Time = 4,
        })
        -- Run now
        getSingleGun()
    end
})

giverBox:AddButton({
    Text = "Get M9",
    Func = function()
        GUN_NAME = "M9"
        Library:Notify({
            Title = "Escape Prison",
            Description = "Try To Tween To Gun.....",
            Time = 4,
        })
        -- Run now
        getSingleGun()
    end
})

giverBox:AddButton({
    Text = "Get M4A1",
    Func = function()
        GUN_NAME = "M4A1"
        Library:Notify({
            Title = "Escape Prison",
            Description = "Try To Tween To Gun.....",
            Time = 4,
        })
        -- Run now
        getSingleGun()
    end
})

local player = game.Players.LocalPlayer


local function instantTP(cf)
	local char = player.Character or player.CharacterAdded:Wait()
	local root = char:FindFirstChild("HumanoidRootPart")
	local hum = char:FindFirstChild("Humanoid")
	if not root or not hum then return end
	hum.Health = 100
	root.Anchored = true
	root.CFrame = cf + Vector3.new(0,5,0)
	task.wait(0.05)
	root.Anchored = false
end

giverBox:AddButton({
    Text = "Escape Prison",
    Func = function()
        instantTP(CFrame.new(-927.7, 94.1, 2055.3))
    end
})

local targethud = loadstring(game:HttpGet("https://raw.githubusercontent.com/Stratxgy/Lua-TargetHud/refs/heads/main/targethud.lua"))()

local targethudBox = Tabs.Visual:AddLeftGroupbox("Target Hud", "building")

targethudBox:AddCheckbox("hudToggle", {
    Text = "Target Hud",
    Default = false,
}):OnChanged(function(Value)
    getgenv().targethud.enabled = Value
end)

local Chams = { 
    Enabled = false,
    FillTrans = 0.6,
    OutlineTrans = 0.1,
}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

local TEAM_COLORS = {
    Inmates = Color3.fromRGB(255, 138, 0),
    Guards = Color3.fromRGB(0, 119, 255),
    Criminals = Color3.fromRGB(255, 51, 51)
}

local function removeHighlight(char)
    local h = char:FindFirstChild("TeamESP")
    if h then h:Destroy() end
end

local function applyHighlight(player, char)
    if player == LocalPlayer then return end
    if not player.Team then return end

    local color = TEAM_COLORS[player.Team.Name]
    if not color then return end

    -- remove old one if exists
    removeHighlight(char)

    local h = Instance.new("Highlight")
    h.Name = "TeamESP"
    h.Adornee = char
    h.FillColor = color
    h.OutlineColor = color
    h.FillTransparency = Chams.FillTrans
    h.OutlineTransparency = Chams.OutlineTrans
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    h.Parent = char
end

--Auto-update every frame to check if Chams is toggled on/off
RunService.RenderStepped:Connect(function()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local char = player.Character
            local highlight = char:FindFirstChild("TeamESP")

            if Chams.Enabled then
                -- Make sure highlight exists
                if not highlight then
                    applyHighlight(player, char)
                else
                    highlight.FillTransparency = Chams.FillTrans
                    highlight.OutlineTransparency = Chams.OutlineTrans
                    highlight.Enabled = true
                end
            else
                -- Chams disabled
                if highlight then
                    highlight.Enabled = false
                end
            end
        end
    end
end)

-- Apply ESP on join/respawn
local function onPlayer(player)
    player.CharacterAdded:Connect(function(char)
        task.wait(0.1)
        if Chams.Enabled then
            applyHighlight(player, char)
        end
    end)
end

for _, p in ipairs(Players:GetPlayers()) do
    onPlayer(p)
end
Players.PlayerAdded:Connect(onPlayer)

local chamsBox = Tabs.Visual:AddLeftGroupbox("Chams", "user")

local chamsToggle = chamsBox:AddCheckbox("chamsToggle", {
    Text = "Chams",
    Default = false,
}):OnChanged(function(Value)
    Chams.Enabled = Value
end)
 
chamsBox:AddSlider("FillTrans", {
    Text = "Fill Transparency",
    Default = 0.6,
    Min = 0,
    Max = 1,
    Rounding = 1,
}):OnChanged(function(Value)
    Chams.FillTrans = Value
end)

local outline = chamsBox:AddSlider("OutlineTrans", {
    Text = "Outline Transparency",
    Default = 0,
    Min = 0,
    Max = 1,
    Rounding = 1,
}):OnChanged(function(Value)
    Chams.OutlineTrans = Value
end)

local Dots = {
    Enabled = false,
    DotSize = 10,
    FillColor = Color3.fromRGB(255, 138, 0),
    OutlineColor = Color3.fromRGB(0,0,0),
    FillTrans = 0.6,
    OutlineTrans = 0.1,
    OffsetY = 2
}

local function createBillboardDot(character, color)
    local head = character:FindFirstChild("Head")
    if not head then return end

    -- remove existing
    local oldGui = head:FindFirstChild("HeadDotGui")
    if oldGui then oldGui:Destroy() end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "HeadDotGui"
    billboard.Adornee = head
    billboard.Size = UDim2.new(0, Dots.DotSize, 0, Dots.DotSize)
    billboard.StudsOffset = Vector3.new(0, Dots.OffsetY, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = head

    local outline = Instance.new("Frame")
    outline.Size = UDim2.new(1,0,1,0)
    outline.BackgroundColor3 = Dots.OutlineColor
    outline.BackgroundTransparency = Dots.OutlineTrans
    outline.BorderSizePixel = 0
    outline.Parent = billboard

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0.6,0,0.6,0)
    fill.Position = UDim2.new(0.2,0,0.2,0)
    fill.BackgroundColor3 = color
    fill.BackgroundTransparency = Dots.FillTrans
    fill.BorderSizePixel = 0
    fill.AnchorPoint = Vector2.new(0.5,0.5)
    fill.Position = UDim2.new(0.5,0,0.5,0)
    fill.Parent = billboard
end

local function updateDot(player)
    if player == LocalPlayer then return end
    if not player.Character or not player.Team then return end
    local color = TEAM_COLORS[player.Team.Name]
    if not color then return end

    if Dots.Enabled then
        createBillboardDot(player.Character, color)
    else
        local head = player.Character:FindFirstChild("Head")
        if head then
            local old = head:FindFirstChild("HeadDotGui")
            if old then old:Destroy() end
        end
    end
end

local function onPlayer(player)
    player.CharacterAdded:Connect(function()
        task.wait(0.1)
        updateDot(player)
    end)
end

for _, p in ipairs(Players:GetPlayers()) do
    onPlayer(p)
    updateDot(p)
end
Players.PlayerAdded:Connect(onPlayer)

-- continuously update visibility for toggling
RunService.RenderStepped:Connect(function()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            updateDot(player)
        end
    end
end)

local dotBox = Tabs.Visual:AddRightGroupbox("Dot ESP", "circle")

dotBox:AddCheckbox("dotToggle", {
    Text = "Dot ESP",
    Default = false,
}):OnChanged(function(Value)
    Dots.Enabled = Value
end)

dotBox:AddSlider("FillTrans", {
    Text = "Fill Transparency",
    Default = 0.6,
    Min = 0,
    Max = 1,
    Rounding = 1,
}):OnChanged(function(Value)
    Dots.FillTrans = Value
end)

local outline = dotBox:AddSlider("OutlineTrans", {
    Text = "Outline Transparency",
    Default = 0.1,
    Min = 0,
    Max = 1,
    Rounding = 1,
}):OnChanged(function(Value)
    Dots.OutlineTrans = Value
end)

local tpBox = Tabs.World:AddLeftGroupbox("Teleport OwO :3", "earth")

local locations = {
	["Criminal Base"] = CFrame.new(-927.7, 94.1, 2055.3),
	["Prison Yard"] = CFrame.new(791.5, 98, 2498.5),
	["Police Spawn"] = CFrame.new(837.9, 99.8, 2267.3),
}

for name, cf in pairs(locations) do
	tpBox:AddButton(name, function()
		Library:Notify({Title="Teleport", Description="→ "..name, Time=2})
		instantTP(cf)
	end)
end

tpBox:AddDivider()
tpBox:AddDropdown("TPToPlayer", {
	SpecialType = "Player",
	Text = "Teleport to Player",
	Callback = function(p)
		if p and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
			Library:Notify({Title="Teleport", Description="→ "..p.Name, Time=2})
			instantTP(p.Character.HumanoidRootPart.CFrame + Vector3.new(0,4,0))
		end
	end
})

local workspaceBox = Tabs.World:AddRightGroupbox("Workspace :3", "earth")

workspaceBox:AddButton({
    Text = "Delete All Doors OwO",
    Func = function()
        game.workspace.Doors:Destroy()
    end
})

workspaceBox:AddButton({
    Text = "Delete All Cells :3",
    Func = function()
        game.workspace.Prison_Cellblock:Destroy()
    end
})

workspaceBox:AddButton({
    Text = "Delete All Cell Doors :3",
    Func = function()
        game.workspace.CellDoors:Destroy()
    end
})



workspaceBox:AddButton({
    Text = "Btools UwU",
    Func = function()
        backpack = game:GetService("Players").LocalPlayer.Backpack

        hammer = Instance.new("HopperBin")
        hammer.Name = "Hammer"
        hammer.BinType = 4
        hammer.Parent = backpack

        cloneTool = Instance.new("HopperBin")
        cloneTool.Name = "Clone"
        cloneTool.BinType = 3
        cloneTool.Parent = backpack

        grabTool = Instance.new("HopperBin")
        grabTool.Name = "Grab"
        grabTool.BinType = 2
        grabTool.Parent = backpack
    end
})

local RunService = game:GetService("RunService")

local TPWalk = {
    Enabled = false,
    StepSize = 0.25,
}

RunService.RenderStepped:Connect(function()
    if not TPWalk.Enabled then return end

    local char = game.Players.LocalPlayer.Character
	    local hum = char:FindFirstChild("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")

    if not hum or not hrp then return end

    local dir = hum.MoveDirection
    if dir.Magnitude > 0 then
        hrp.CFrame = hrp.CFrame + (dir * TPWalk.StepSize)
    end
end)

local plrBox = Tabs.World:AddLeftGroupbox("LocalPlayer", "user")


--[[plrBox:AddCheckbox("plrCframeToggle", {
    Text = "CFrame Speed",
    Default = false,
}):OnChanged(function(Value)
    TPWalk.Enabled = Value
end)

plrBox:AddSlider("MulCframe", {
    Text = "CFrame Multiplier",
    Default = 0.25,
    Min = 0,
    Max = 0.3,
    Rounding = 2,
}):OnChanged(function(Value)
    TPWalk.StepSize = Value
end)
]]
getgenv().Noclip = false

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local lplr = Players.LocalPlayer

-- Main noclip loop
RunService.Stepped:Connect(function()
    if not getgenv().Noclip then return end
    if not lplr.Character then return end
    
    for _, part in pairs(lplr.Character:GetDescendants()) do
        if part:IsA("BasePart") and part.CanCollide then
            part.CanCollide = false
        end
    end
end)

plrBox:AddCheckbox("noclipToggle", {
    Text = "Noclip",
    Default = false,
}):OnChanged(function(Value)
    getgenv().Noclip = Value
end)

local savedPosition = nil

plrBox:AddButton({
    Text = "Become Criminal",
    Func = function()
        local plr = game.Players.LocalPlayer
        local char = plr.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then
            Library:Notify({Title = "Error", Description = "Spawn first!", Time = 3})
            return
        end

        local root = char.HumanoidRootPart
        
        savedPosition = {
            pos = root.CFrame,
            camera = workspace.CurrentCamera.CFrame
        }
        
        Library:Notify({Title = "Become Criminal", Description = "Position saved → Going to Crim Base...", Time = 3})

        instantTP(CFrame.new(-927.7, 94.1, 2055.3))
        task.wait(0.5)

        if plr.TeamColor.Name == "Bright orange" then
            pcall(function()
                game:GetService("ReplicatedStorage").Remote.TeamEvent:FireServer("Really red")
            end)
            task.wait(1.2)
        end

        task.wait(0.3)
        root.CFrame = savedPosition.pos
        workspace.CurrentCamera.CFrame = savedPosition.camera
        
        Library:Notify({
            Title = "Criminal Complete!", 
            Description = "Back to your position as Criminal!", 
            Time = 5
        })
        
        savedPosition = nil
    end
})


local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu", "wrench")

MenuGroup:AddToggle("KeybindMenuOpen", {
	Default = Library.KeybindFrame.Visible,
	Text = "Open Keybind Menu",
	Callback = function(value)
		Library.KeybindFrame.Visible = value
	end,
})
MenuGroup:AddToggle("ShowCustomCursor", {
	Text = "Custom Cursor",
	Default = true,
	Callback = function(Value)
		Library.ShowCustomCursor = Value
	end,
})
MenuGroup:AddDropdown("NotificationSide", {
	Values = { "Left", "Right" },
	Default = "Right",

	Text = "Notification Side",

	Callback = function(Value)
		Library:SetNotifySide(Value)
	end,
})


MenuGroup:AddDropdown("DPIDropdown", {
	Values = { "50%", "75%", "100%", "125%", "150%", "175%", "200%" },
	Default = "100%",

	Text = "DPI Scale",

	Callback = function(Value)
		Value = Value:gsub("%%", "")
		local DPI = tonumber(Value)

		Library:SetDPIScale(DPI)
	end,
})
MenuGroup:AddDivider()
MenuGroup:AddLabel("Menu bind")
	:AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })

MenuGroup:AddButton("Unload", function()
	Library:Unload()
end)

Library.ToggleKeybind = Options.MenuKeybind -- Allows you to have a custom keybind for the menu


SaveManager:SetLibrary(Library)
ThemeManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
ThemeManager:SetFolder("MyScriptHub")
SaveManager:SetFolder("MyScriptHub/specific-game")
SaveManager:SetSubFolder("specific-place") -- if the game has multiple places inside of it (for example: DOORS)
SaveManager:BuildConfigSection(Tabs["UI Settings"])
ThemeManager:ApplyToTab(Tabs["UI Settings"])
