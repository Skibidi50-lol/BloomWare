
getgenv().Aimbot = {
    DeveloperSettings = {
        UpdateMode = "RenderStepped", -- "RenderStepped" or "Heartbeat" or "Stepped"
        TeamCheckOption = "TeamColor", -- "TeamColor" or "Team"
        RainbowSpeed = 1
    },
    Settings = {
        Enabled = false,
        TeamCheck = false,
        AliveCheck = false,
        WallCheck = false,
        OffsetToMoveDirection = false, -- Prediction
        OffsetIncrement = 16, -- Prediction strength (8-25 recommended)
        Sensitivity = 0.24, -- Smoothness (0 = instant, higher = smoother)
        Sensitivity2 = 3.5, -- mousemoverel amount (only used in LockMode 2)
        LockMode = 1, -- 1 = Camera CFrame | 2 = mousemoverel
        LockPart = "Head" -- Head, HumanoidRootPart, UpperTorso, etc.
    },
    FOVSettings = {
        Enabled = false,
        Visible = false,
        Radius = 90,
        NumSides = 60,
        Thickness = 2,
        Transparency = 0.8,
        Filled = false,
        RainbowColor = false,
        RainbowOutlineColor = false,
        Color = Color3.fromRGB(255, 255, 255),
        OutlineColor = Color3.fromRGB(0, 0, 0),
        LockedColor = Color3.fromRGB(255, 100, 100)
    }
}

-- // Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- // Variables
local FOVCircle = Drawing.new("Circle")
local Target = nil

-- // Functions
local function IsTeamMate(Player)
    if not getgenv().Aimbot.Settings.TeamCheck then return false end
    if getgenv().Aimbot.DeveloperSettings.TeamCheckOption == "TeamColor" then
        return Player.TeamColor == LocalPlayer.TeamColor
    else
        return Player.Team == LocalPlayer.Team
    end
end

local function IsAlive(Player)
    return Player.Character and Player.Character:FindFirstChild("Humanoid") and Player.Character.Humanoid.Health > 0
end

local function GetClosest()
    local Closest = nil
    local ClosestDist = getgenv().Aimbot.FOVSettings.Radius

    for _, Player in ipairs(Players:GetPlayers()) do
        if Player == LocalPlayer then continue end
        if not Player.Character or not Player.Character:FindFirstChild("Humanoid") then continue end
        if Player.Character.Humanoid.Health <= 0 then continue end
        
        -- Team Check
        if getgenv().Aimbot.Settings.TeamCheck and (Player.Team == LocalPlayer.Team or Player.TeamColor == LocalPlayer.TeamColor) then continue end

        local Part = Player.Character:FindFirstChild(getgenv().Aimbot.Settings.LockPart)
        if not Part then continue end

        local ScreenPos, OnScreen = Camera:WorldToViewportPoint(Part.Position)
        if OnScreen then
            local MousePos = Vector2.new(Mouse.X, Mouse.Y + 36)
            local Dist = (MousePos - Vector2.new(ScreenPos.X, ScreenPos.Y)).Magnitude
            
            if Dist < ClosestDist then
                local WallCheckPassed = true
                
                -- FIXED WALL CHECK - Only blocks if something OTHER than target blocks ray
                if getgenv().Aimbot.Settings.WallCheck then
                    local Direction = (Part.Position - Camera.CFrame.Position)
                    local RaycastParams = RaycastParams.new()
                    RaycastParams.FilterType = Enum.RaycastFilterType.Blacklist
                    RaycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
                    
                    local RaycastResult = workspace:Raycast(Camera.CFrame.Position, Direction.Unit * Direction.Magnitude, RaycastParams)
                    
                    if RaycastResult then
                        WallCheckPassed = RaycastResult.Instance:IsDescendantOf(Player.Character)
                    end
                end
                
                if WallCheckPassed then
                    Closest = Part
                    ClosestDist = Dist
                end
            end
        end
    end
    return Closest
end

-- // FOV Circle Update
RunService.RenderStepped:Connect(function()
    if getgenv().Aimbot.FOVSettings.Visible and getgenv().Aimbot.FOVSettings.Enabled then
        FOVCircle.Visible = true
        FOVCircle.Radius = getgenv().Aimbot.FOVSettings.Radius
        FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y + 36)
        FOVCircle.NumSides = getgenv().Aimbot.FOVSettings.NumSides
        FOVCircle.Thickness = getgenv().Aimbot.FOVSettings.Thickness
        FOVCircle.Transparency = getgenv().Aimbot.FOVSettings.Transparency
        FOVCircle.Filled = getgenv().Aimbot.FOVSettings.Filled

        if getgenv().Aimbot.FOVSettings.RainbowColor then
            FOVCircle.Color = Color3.fromHSV(tick() % 5 / 5, 1, 1)
        else
            FOVCircle.Color = getgenv().Aimbot.FOVSettings.Color
        end
    else
        FOVCircle.Visible = false
    end
end)

-- // Main Aimbot Loop
RunService[getgenv().Aimbot.DeveloperSettings.UpdateMode]:Connect(function()
    if not getgenv().Aimbot.Settings.Enabled then return end

    Target = GetClosestPlayer()

    if Target then
        local TargetPos = Target.Position
        if getgenv().Aimbot.Settings.OffsetToMoveDirection and Target.Parent:FindFirstChild("Humanoid") then
            local Velocity = Target.Parent.HumanoidRootPart.Velocity
            TargetPos = TargetPos + (Velocity * (getgenv().Aimbot.Settings.OffsetIncrement / 100))
        end

        local WorldPoint = TargetPos
        local ScreenPoint, OnScreen = Camera:WorldToViewportPoint(WorldPoint)

        if OnScreen then
            if getgenv().Aimbot.Settings.LockMode == 1 then -- Smooth CFrame
                local MousePos = UserInputService:GetMouseLocation()
                local TargetVector = Camera:WorldToViewportPoint(WorldPoint)
                local NewCameraCFrame = CFrame.new(Camera.CFrame.Position, WorldPoint)
                Camera.CFrame = Camera.CFrame:Lerp(NewCameraCFrame, getgenv().Aimbot.Settings.Sensitivity)
            elseif getgenv().Aimbot.Settings.LockMode == 2 then -- mousemoverel
                local Move = Vector2.new((ScreenPoint.X - Mouse.X) / getgenv().Aimbot.Settings.Sensitivity2, (ScreenPoint.Y - Mouse.Y - 36) / getgenv().Aimbot.Settings.Sensitivity2)
                mousemoverel(Move.X, Move.Y)
            end
        end
    end
end)
