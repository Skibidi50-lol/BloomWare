local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
   Name = "BloomWare - Prison Life",
   Icon = 0, -- Icon in Topbar. Can use Lucide Icons (string) or Roblox Image (number). 0 to use no icon (default).
   LoadingTitle = "Prison Life",
   LoadingSubtitle = "by Skibidi50-lol",
   ShowText = "Bloom", -- for mobile users to unhide rayfield, change if you'd like
   Theme = "Default", -- Check https://docs.sirius.menu/rayfield/configuration/themes

   ToggleUIKeybind = "K", -- The keybind to toggle the UI visibility (string like "K" or Enum.KeyCode)

   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false, -- Prevents Rayfield from warning when the script has a version mismatch with the interface

   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil, -- Create a custom folder for your hub/game
      FileName = "Big Hub"
   },

   Discord = {
      Enabled = false, -- Prompt the user to join your Discord server if their executor supports it
      Invite = "noinvitelink", -- The Discord invite code, do not include discord.gg/. E.g. discord.gg/ ABCD would be ABCD
      RememberJoins = true -- Set this to false to make them join the discord every time they load it up
   },

   KeySystem = false, -- Set this to true to use our key system
   KeySettings = {
      Title = "Untitled",
      Subtitle = "Key System",
      Note = "No method of obtaining the key is provided", -- Use this to tell the user how to get a key
      FileName = "Key", -- It is recommended to use something unique as other scripts using Rayfield may overwrite your key file
      SaveKey = true, -- The user's key will be saved, but if you change the key, they will be unable to use your script
      GrabKeyFromSite = false, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
      Key = {"Hello"} -- List of keys that will be accepted by the system, can be RAW file links (pastebin, github etc) or simple strings ("hello","key22")
   }
})
--aimbot

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

local function GetClosestPlayer()
    local ClosestDistance = getgenv().Aimbot.FOVSettings.Radius
    local ClosestPlayer = nil

    for _, Player in ipairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and IsAlive(Player) and not IsTeamMate(Player) then
            local Character = Player.Character
            local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
            local LockPart = Character and Character:FindFirstChild(getgenv().Aimbot.Settings.LockPart)

            if HumanoidRootPart and LockPart then
                local ScreenPos, OnScreen = Camera:WorldToViewportPoint(LockPart.Position)
                if OnScreen then
                    local Distance = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(ScreenPos.X, ScreenPos.Y)).Magnitude

                    if Distance < ClosestDistance then
                        if getgenv().Aimbot.Settings.WallCheck then
                            local Ray = Ray.new(Camera.CFrame.Position, (LockPart.Position - Camera.CFrame.Position).Unit * 500)
                            local Hit = Workspace:FindPartOnRayWithIgnoreList(Ray, {LocalPlayer.Character, Character})
                            if not Hit then
                                ClosestDistance = Distance
                                ClosestPlayer = LockPart
                            end
                        else
                            ClosestDistance = Distance
                            ClosestPlayer = LockPart
                        end
                    end
                end
            end
        end
    end
    return ClosestPlayer
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


local aimbotTab = Window:CreateTab("Aimbot", "crosshair")
local Section = aimbotTab:CreateSection("Aimbot Settings")

local Toggle = aimbotTab:CreateToggle({
   Name = "AI Tracking Aimbot",
   CurrentValue = false,
   Flag = "AimbotToggle1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
        getgenv().Aimbot.Settings.Enabled = Value
   end,
})

local Toggle = aimbotTab:CreateToggle({
   Name = "Team Check",
   CurrentValue = false,
   Flag = "AimbotToggle1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
        getgenv().Aimbot.Settings.TeamCheck = Value
   end,
})

local Toggle = aimbotTab:CreateToggle({
   Name = "Alive Check",
   CurrentValue = false,
   Flag = "AimbotToggle1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
        getgenv().Aimbot.Settings.AliveCheck = Value
   end,
})

local Dropdown = aimbotTab:CreateDropdown({
   Name = "Aimbot Part",
   Options = {"Head","HumanoidRootPart"},
   CurrentOption = {"Head"},
   MultipleOptions = false,
   Flag = "Dropdown1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Options)
        getgenv().Aimbot.Settings.LockPart = Value
   end,
})

local Section = aimbotTab:CreateSection("FOV Circle Settings")

local Toggle = aimbotTab:CreateToggle({
   Name = "FOV Circle",
   CurrentValue = false,
   Flag = "FovAimbotToggle1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
        getgenv().Aimbot.FOVSettings.Enabled = Value
        getgenv().Aimbot.FOVSettings.Visible = Value
   end,
})

local Slider = aimbotTab:CreateSlider({
   Name = "FOV Radius",
   Range = {50, 500},
   Increment = 1,
   Suffix = "PX",
   CurrentValue = 90,
   Flag = "Slider1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
        getgenv().Aimbot.FOVSettings.Radius = Value
   end,
})

local Slider = aimbotTab:CreateSlider({
   Name = "FOV Transparency",
   Range = {0, 1},
   Increment = 0.1,
   Suffix = "Transparency",
   CurrentValue = 0.8,
   Flag = "Slider1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
        getgenv().Aimbot.FOVSettings.Transparency  = Value
   end,
})

local Toggle = aimbotTab:CreateToggle({
   Name = "Filled FOV",
   CurrentValue = false,
   Flag = "FovAimbotToggle1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
        getgenv().Aimbot.FOVSettings.Filled = Value
   end,
})

local ColorPicker = aimbotTab:CreateColorPicker({
    Name = "FOV Color",
    Color = Color3.fromRGB(255,255,255),
    Flag = "ColorPicker1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
    Callback = function(Value)
        getgenv().Aimbot.FOVSettings.Color = Value
    end
})

local ColorPicker = aimbotTab:CreateColorPicker({
    Name = "FOV Outline Color",
    Color = Color3.fromRGB(255,255,255),
    Flag = "ColorPicker1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
    Callback = function(Value)
        getgenv().Aimbot.FOVSettings.OutlineColor = Value
    end
})

local Toggle = aimbotTab:CreateToggle({
   Name = "Rainbow FOV",
   CurrentValue = false,
   Flag = "FovAimbotToggle1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
        getgenv().Aimbot.FOVSettings.RainbowColor = Value
   end,
})

local Toggle = aimbotTab:CreateToggle({
   Name = "Rainbow Outline FOV",
   CurrentValue = false,
   Flag = "FovAimbotToggle1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
        getgenv().Aimbot.FOVSettings.RainbowOutlineColor = Value
   end,
})

local espTab = Window:CreateTab("Visuals", "eye")
local Section = espTab:CreateSection("Chams Settings")

local chams = loadstring(game:HttpGet("https://raw.githubusercontent.com/Stratxgy/Roblox-Chams-Highlight/refs/heads/main/Highlight.lua"))()

local Toggle = espTab:CreateToggle({
   Name = "Chams",
   CurrentValue = false,
   Flag = "FovAimbotToggle1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
        getgenv().chams.enabled = Value
   end,
})
local ColorPicker = espTab:CreateColorPicker({
    Name = "Chams Outline Color",
    Color = Color3.fromRGB(255,255,255),
    Flag = "ColorPicker1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
    Callback = function(Value)
        getgenv().chams.outlineColor = Value
    end
})
